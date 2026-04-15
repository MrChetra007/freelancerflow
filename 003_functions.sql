-- ============================================================
-- FreelanceFlow — Database Functions & Views
-- File: 003_functions.sql
-- Run AFTER 002_rls_policies.sql
-- ============================================================

-- ============================================================
-- FUNCTION: Auto-create profile on user sign-up
-- Triggered automatically when a new user registers
-- ============================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url, email)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url',
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- FUNCTION: Get next invoice number for a user
-- Returns: 'INV-0001', 'INV-0042', etc.
-- ============================================================
CREATE OR REPLACE FUNCTION get_next_invoice_number(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
  v_count INTEGER;
  v_number TEXT;
BEGIN
  SELECT COUNT(*) + 1
  INTO v_count
  FROM invoices
  WHERE user_id = p_user_id;

  v_number := 'INV-' || LPAD(v_count::TEXT, 4, '0');
  RETURN v_number;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Get dashboard stats for a user
-- Returns summary data for the dashboard screen
-- ============================================================
CREATE OR REPLACE FUNCTION get_dashboard_stats(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  v_result JSON;
BEGIN
  SELECT json_build_object(
    -- This month earnings (paid payments)
    'this_month_earned', COALESCE((
      SELECT SUM(amount_paid)
      FROM payments
      WHERE user_id = p_user_id
        AND status = 'paid'
        AND DATE_TRUNC('month', paid_date) = DATE_TRUNC('month', CURRENT_DATE)
    ), 0),

    -- Total unpaid amount
    'total_unpaid', COALESCE((
      SELECT SUM(amount - amount_paid)
      FROM payments
      WHERE user_id = p_user_id
        AND status IN ('unpaid', 'partial')
    ), 0),

    -- Overdue count and amount
    'overdue_count', COALESCE((
      SELECT COUNT(*)
      FROM payments
      WHERE user_id = p_user_id
        AND status IN ('unpaid', 'partial')
        AND due_date < CURRENT_DATE
    ), 0),

    'overdue_amount', COALESCE((
      SELECT SUM(amount - amount_paid)
      FROM payments
      WHERE user_id = p_user_id
        AND status IN ('unpaid', 'partial')
        AND due_date < CURRENT_DATE
    ), 0),

    -- Active projects
    'active_projects', COALESCE((
      SELECT COUNT(*)
      FROM projects
      WHERE user_id = p_user_id
        AND status = 'in_progress'
    ), 0),

    -- Total clients
    'total_clients', COALESCE((
      SELECT COUNT(*)
      FROM clients
      WHERE user_id = p_user_id
        AND is_archived = FALSE
    ), 0),

    -- Pending invoices
    'pending_invoices', COALESCE((
      SELECT COUNT(*)
      FROM invoices
      WHERE user_id = p_user_id
        AND status IN ('sent', 'overdue')
    ), 0)
  ) INTO v_result;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Get monthly earnings for chart (last 6 months)
-- ============================================================
CREATE OR REPLACE FUNCTION get_monthly_earnings(p_user_id UUID)
RETURNS TABLE (
  month       TEXT,
  year        INTEGER,
  month_num   INTEGER,
  total       NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    TO_CHAR(gs.month_start, 'Mon') AS month,
    EXTRACT(YEAR FROM gs.month_start)::INTEGER AS year,
    EXTRACT(MONTH FROM gs.month_start)::INTEGER AS month_num,
    COALESCE(SUM(p.amount_paid), 0) AS total
  FROM
    GENERATE_SERIES(
      DATE_TRUNC('month', CURRENT_DATE - INTERVAL '5 months'),
      DATE_TRUNC('month', CURRENT_DATE),
      '1 month'::INTERVAL
    ) AS gs(month_start)
  LEFT JOIN payments p
    ON p.user_id = p_user_id
    AND p.status = 'paid'
    AND DATE_TRUNC('month', p.paid_date) = gs.month_start
  GROUP BY gs.month_start
  ORDER BY gs.month_start ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Mark overdue payments automatically
-- Call this via a scheduled Edge Function (daily cron)
-- ============================================================
CREATE OR REPLACE FUNCTION mark_overdue_payments()
RETURNS INTEGER AS $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE payments
  SET status = 'overdue', updated_at = NOW()
  WHERE status IN ('unpaid', 'partial')
    AND due_date < CURRENT_DATE
    AND due_date IS NOT NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RETURN v_updated;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Mark overdue invoices automatically
-- ============================================================
CREATE OR REPLACE FUNCTION mark_overdue_invoices()
RETURNS INTEGER AS $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE invoices
  SET status = 'overdue', updated_at = NOW()
  WHERE status = 'sent'
    AND due_date < CURRENT_DATE
    AND due_date IS NOT NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RETURN v_updated;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- VIEW: Client summary (with aggregated data)
-- Useful for client list screen
-- ============================================================
CREATE OR REPLACE VIEW client_summary AS
SELECT
  c.id,
  c.user_id,
  c.name,
  c.email,
  c.phone,
  c.company,
  c.country,
  c.currency,
  c.avatar_color,
  c.is_archived,
  c.created_at,
  -- Project counts
  COUNT(DISTINCT p.id) FILTER (WHERE p.status = 'in_progress') AS active_projects,
  COUNT(DISTINCT p.id) AS total_projects,
  -- Financial summary
  COALESCE(SUM(pay.amount_paid) FILTER (WHERE pay.status = 'paid'), 0) AS total_earned,
  COALESCE(SUM(pay.amount - pay.amount_paid) FILTER (WHERE pay.status IN ('unpaid', 'partial', 'overdue')), 0) AS total_outstanding
FROM clients c
LEFT JOIN projects p ON p.client_id = c.id
LEFT JOIN payments pay ON pay.client_id = c.id
GROUP BY c.id;

-- ============================================================
-- VIEW: Project summary (with milestone progress)
-- ============================================================
CREATE OR REPLACE VIEW project_summary AS
SELECT
  p.id,
  p.user_id,
  p.client_id,
  p.title,
  p.description,
  p.status,
  p.budget,
  p.currency,
  p.start_date,
  p.deadline,
  p.completed_at,
  p.is_archived,
  p.created_at,
  p.updated_at,
  -- Client info
  c.name AS client_name,
  c.company AS client_company,
  c.avatar_color AS client_avatar_color,
  -- Milestone progress
  COUNT(m.id) AS total_milestones,
  COUNT(m.id) FILTER (WHERE m.is_completed = TRUE) AS completed_milestones,
  CASE
    WHEN COUNT(m.id) = 0 THEN 0
    ELSE ROUND(
      (COUNT(m.id) FILTER (WHERE m.is_completed = TRUE) * 100.0) / COUNT(m.id)
    )
  END AS progress_percent,
  -- Payment info
  COALESCE(SUM(pay.amount_paid), 0) AS total_paid,
  -- Overdue flag
  CASE
    WHEN p.deadline < CURRENT_DATE AND p.status = 'in_progress' THEN TRUE
    ELSE FALSE
  END AS is_overdue
FROM projects p
LEFT JOIN clients c ON c.id = p.client_id
LEFT JOIN milestones m ON m.project_id = p.id
LEFT JOIN payments pay ON pay.project_id = p.id AND pay.status = 'paid'
GROUP BY p.id, c.id;

-- ============================================================
-- GRANT access to authenticated users for views
-- ============================================================
GRANT SELECT ON client_summary  TO authenticated;
GRANT SELECT ON project_summary TO authenticated;

-- ============================================================
-- RLS on views (security barrier)
-- ============================================================
ALTER VIEW client_summary  SET (security_barrier = true);
ALTER VIEW project_summary SET (security_barrier = true);
