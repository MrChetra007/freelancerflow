-- ============================================================
-- FreelanceFlow — Migration v1 → v2
-- File: migration_to_v2.sql
-- Run this ONLY if you already ran 001_initial_schema.sql (v1)
-- Safe to run: uses IF NOT EXISTS and IF EXISTS guards
-- ============================================================

-- ============================================================
-- STEP 1 — ALTER EXISTING TABLES
-- Add new columns to profiles and clients
-- ============================================================

-- Profiles: add tax ID for invoice compliance
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS tax_id TEXT;

-- Profiles: add default hourly rate (used as fallback in time tracking)
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS default_hourly_rate NUMERIC(10, 2) NOT NULL DEFAULT 0;

-- Profiles: invoice payment terms preset (e.g. "Net 30", "Due on receipt")
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS default_payment_terms TEXT;

-- Clients: per-client hourly rate (overrides profile default)
ALTER TABLE clients
  ADD COLUMN IF NOT EXISTS default_hourly_rate NUMERIC(10, 2) NOT NULL DEFAULT 0;

-- Clients: tags array for segmentation (e.g. 'retainer', 'agency', 'one-time')
ALTER TABLE clients
  ADD COLUMN IF NOT EXISTS tags TEXT[] NOT NULL DEFAULT '{}';


-- ============================================================
-- STEP 2 — EXTEND EXISTING ENUMS
-- PostgreSQL does not support removing enum values,
-- only adding. Use ADD VALUE IF NOT EXISTS (Postgres 14+).
-- ============================================================

-- notification_type enum additions
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'milestone_due';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'recurring_invoice_generated';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'time_entry_reminder';

-- activity_type enum additions
ALTER TYPE activity_type ADD VALUE IF NOT EXISTS 'time_logged';
ALTER TYPE activity_type ADD VALUE IF NOT EXISTS 'expense_logged';
ALTER TYPE activity_type ADD VALUE IF NOT EXISTS 'recurring_invoice_created';


-- ============================================================
-- STEP 3 — NEW TABLE: time_entries
-- Track billable/non-billable hours per project
-- ============================================================
CREATE TABLE IF NOT EXISTS time_entries (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  project_id       UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  client_id        UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  description      TEXT,
  started_at       TIMESTAMPTZ NOT NULL,
  ended_at         TIMESTAMPTZ,
  -- Stored in seconds. Can be set directly for manual entries.
  duration_seconds INTEGER GENERATED ALWAYS AS (
    CASE
      WHEN ended_at IS NOT NULL
      THEN EXTRACT(EPOCH FROM (ended_at - started_at))::INTEGER
      ELSE NULL
    END
  ) STORED,
  hourly_rate      NUMERIC(10, 2) NOT NULL DEFAULT 0,
  -- amount = (duration_seconds / 3600) * hourly_rate, computed on read
  is_billable      BOOLEAN NOT NULL DEFAULT TRUE,
  is_billed        BOOLEAN NOT NULL DEFAULT FALSE,
  -- Set when this entry is added to an invoice
  invoice_id       UUID REFERENCES invoices(id) ON DELETE SET NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- A timer session must have a start; if running, ended_at is NULL
  CONSTRAINT valid_time_range CHECK (ended_at IS NULL OR ended_at > started_at)
);

CREATE INDEX IF NOT EXISTS idx_time_entries_user_id    ON time_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_time_entries_project_id ON time_entries(project_id);
CREATE INDEX IF NOT EXISTS idx_time_entries_client_id  ON time_entries(client_id);
CREATE INDEX IF NOT EXISTS idx_time_entries_is_billed  ON time_entries(user_id, is_billed);
CREATE INDEX IF NOT EXISTS idx_time_entries_started_at ON time_entries(user_id, started_at DESC);
-- Index to enforce only one active timer per user at a time (ended_at IS NULL)
CREATE UNIQUE INDEX IF NOT EXISTS idx_time_entries_active_timer
  ON time_entries(user_id)
  WHERE ended_at IS NULL;

-- updated_at trigger
CREATE TRIGGER set_updated_at BEFORE UPDATE ON time_entries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================================
-- STEP 4 — NEW TABLE: expenses
-- Track business costs per project/client
-- ============================================================
DO $$ BEGIN
  CREATE TYPE expense_category AS ENUM (
    'software',
    'hardware',
    'travel',
    'accommodation',
    'meals',
    'marketing',
    'freelancer',
    'office',
    'other'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS expenses (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  project_id   UUID REFERENCES projects(id) ON DELETE SET NULL,
  client_id    UUID REFERENCES clients(id) ON DELETE SET NULL,
  category     expense_category NOT NULL DEFAULT 'other',
  description  TEXT NOT NULL,
  amount       NUMERIC(12, 2) NOT NULL,
  currency     TEXT NOT NULL DEFAULT 'USD',
  date         DATE NOT NULL DEFAULT CURRENT_DATE,
  receipt_url  TEXT,    -- Supabase Storage path
  is_billable  BOOLEAN NOT NULL DEFAULT FALSE,
  is_billed    BOOLEAN NOT NULL DEFAULT FALSE,
  invoice_id   UUID REFERENCES invoices(id) ON DELETE SET NULL,
  notes        TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_expenses_user_id    ON expenses(user_id);
CREATE INDEX IF NOT EXISTS idx_expenses_project_id ON expenses(project_id);
CREATE INDEX IF NOT EXISTS idx_expenses_client_id  ON expenses(client_id);
CREATE INDEX IF NOT EXISTS idx_expenses_date       ON expenses(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_category   ON expenses(user_id, category);
CREATE INDEX IF NOT EXISTS idx_expenses_is_billed  ON expenses(user_id, is_billed);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================================
-- STEP 5 — NEW TABLE: recurring_invoices
-- Invoice templates that auto-generate on a schedule
-- ============================================================
DO $$ BEGIN
  CREATE TYPE recurrence_frequency AS ENUM (
    'weekly',
    'biweekly',
    'monthly',
    'quarterly',
    'yearly'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS recurring_invoices (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_id         UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  project_id        UUID REFERENCES projects(id) ON DELETE SET NULL,
  frequency         recurrence_frequency NOT NULL DEFAULT 'monthly',
  -- Next date an invoice should be auto-generated
  next_issue_date   DATE NOT NULL,
  -- How many days after issue_date the invoice is due (e.g. 30 = Net 30)
  due_days          INTEGER NOT NULL DEFAULT 30,
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  -- Line items stored as JSONB — copied to invoice_items on generation
  -- Format: [{"description": "...", "quantity": 1, "unit_price": 100.00}]
  line_items        JSONB NOT NULL DEFAULT '[]',
  tax_percent       NUMERIC(5, 2) NOT NULL DEFAULT 0,
  discount_percent  NUMERIC(5, 2) NOT NULL DEFAULT 0,
  currency          TEXT NOT NULL DEFAULT 'USD',
  notes             TEXT,
  payment_terms     TEXT,
  -- Count and last generated tracking
  times_generated   INTEGER NOT NULL DEFAULT 0,
  last_generated_at TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recurring_invoices_user_id        ON recurring_invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_recurring_invoices_client_id      ON recurring_invoices(client_id);
CREATE INDEX IF NOT EXISTS idx_recurring_invoices_next_issue     ON recurring_invoices(next_issue_date) WHERE is_active = TRUE;

CREATE TRIGGER set_updated_at BEFORE UPDATE ON recurring_invoices
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ============================================================
-- STEP 6 — RLS POLICIES FOR NEW TABLES
-- ============================================================

-- time_entries
ALTER TABLE time_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own time entries"
  ON time_entries FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own time entries"
  ON time_entries FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own time entries"
  ON time_entries FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own time entries"
  ON time_entries FOR DELETE
  USING (auth.uid() = user_id);

-- expenses
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own expenses"
  ON expenses FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own expenses"
  ON expenses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own expenses"
  ON expenses FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own expenses"
  ON expenses FOR DELETE
  USING (auth.uid() = user_id);

-- recurring_invoices
ALTER TABLE recurring_invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own recurring invoices"
  ON recurring_invoices FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recurring invoices"
  ON recurring_invoices FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recurring invoices"
  ON recurring_invoices FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own recurring invoices"
  ON recurring_invoices FOR DELETE
  USING (auth.uid() = user_id);

-- expenses storage bucket (for receipts)
INSERT INTO storage.buckets (id, name, public)
VALUES ('receipts', 'receipts', false)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Users can upload own receipts"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'receipts'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can read own receipts"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'receipts'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own receipts"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'receipts'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );


-- ============================================================
-- STEP 7 — NEW VIEWS
-- ============================================================

-- View: time entry details with project and client names
CREATE OR REPLACE VIEW time_entry_summary AS
SELECT
  te.id,
  te.user_id,
  te.project_id,
  te.client_id,
  te.description,
  te.started_at,
  te.ended_at,
  te.duration_seconds,
  te.hourly_rate,
  te.is_billable,
  te.is_billed,
  te.invoice_id,
  te.created_at,
  -- Computed billable amount
  ROUND(
    (COALESCE(te.duration_seconds, 0)::NUMERIC / 3600) * te.hourly_rate,
    2
  ) AS billable_amount,
  -- Project info
  p.title AS project_title,
  p.status AS project_status,
  -- Client info
  c.name AS client_name,
  c.company AS client_company,
  c.avatar_color AS client_avatar_color
FROM time_entries te
LEFT JOIN projects p ON p.id = te.project_id
LEFT JOIN clients  c ON c.id = te.client_id;

GRANT SELECT ON time_entry_summary TO authenticated;
ALTER VIEW time_entry_summary SET (security_barrier = true);

-- View: expense details with project and client names
CREATE OR REPLACE VIEW expense_summary AS
SELECT
  e.id,
  e.user_id,
  e.project_id,
  e.client_id,
  e.category,
  e.description,
  e.amount,
  e.currency,
  e.date,
  e.receipt_url,
  e.is_billable,
  e.is_billed,
  e.invoice_id,
  e.notes,
  e.created_at,
  p.title AS project_title,
  c.name  AS client_name,
  c.avatar_color AS client_avatar_color
FROM expenses e
LEFT JOIN projects p ON p.id = e.project_id
LEFT JOIN clients  c ON c.id = e.client_id;

GRANT SELECT ON expense_summary TO authenticated;
ALTER VIEW expense_summary SET (security_barrier = true);


-- ============================================================
-- STEP 8 — NEW & UPDATED FUNCTIONS
-- ============================================================

-- FUNCTION: Get unbilled billable hours value for a user
-- Useful for dashboard "pending billable" stat
CREATE OR REPLACE FUNCTION get_unbilled_time_value(p_user_id UUID)
RETURNS NUMERIC AS $$
BEGIN
  RETURN COALESCE((
    SELECT SUM(
      ROUND((duration_seconds::NUMERIC / 3600) * hourly_rate, 2)
    )
    FROM time_entries
    WHERE user_id = p_user_id
      AND is_billable = TRUE
      AND is_billed = FALSE
      AND ended_at IS NOT NULL
  ), 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FUNCTION: Get active timer for a user (if any)
CREATE OR REPLACE FUNCTION get_active_timer(p_user_id UUID)
RETURNS TABLE (
  id          UUID,
  project_id  UUID,
  client_id   UUID,
  description TEXT,
  started_at  TIMESTAMPTZ,
  hourly_rate NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    te.id, te.project_id, te.client_id,
    te.description, te.started_at, te.hourly_rate
  FROM time_entries te
  WHERE te.user_id = p_user_id
    AND te.ended_at IS NULL
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FUNCTION: Get expense totals by category for a user (last N months)
CREATE OR REPLACE FUNCTION get_expense_breakdown(
  p_user_id UUID,
  p_months  INTEGER DEFAULT 6
)
RETURNS TABLE (
  category      TEXT,
  total         NUMERIC,
  entry_count   BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    e.category::TEXT,
    COALESCE(SUM(e.amount), 0) AS total,
    COUNT(*) AS entry_count
  FROM expenses e
  WHERE e.user_id = p_user_id
    AND e.date >= (CURRENT_DATE - (p_months || ' months')::INTERVAL)::DATE
  GROUP BY e.category
  ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FUNCTION: Get recurring invoices due today or earlier (for workmanager check)
CREATE OR REPLACE FUNCTION get_due_recurring_invoices(p_user_id UUID)
RETURNS TABLE (
  id          UUID,
  client_id   UUID,
  client_name TEXT,
  frequency   TEXT,
  line_items  JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    ri.id,
    ri.client_id,
    c.name AS client_name,
    ri.frequency::TEXT,
    ri.line_items
  FROM recurring_invoices ri
  JOIN clients c ON c.id = ri.client_id
  WHERE ri.user_id = p_user_id
    AND ri.is_active = TRUE
    AND ri.next_issue_date <= CURRENT_DATE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FUNCTION: Advance recurring invoice to next date after generation
-- Call this after successfully creating the invoice from the template
CREATE OR REPLACE FUNCTION advance_recurring_invoice(p_recurring_id UUID)
RETURNS VOID AS $$
DECLARE
  v_freq      recurrence_frequency;
  v_next_date DATE;
BEGIN
  SELECT frequency, next_issue_date
  INTO v_freq, v_next_date
  FROM recurring_invoices
  WHERE id = p_recurring_id;

  v_next_date := CASE v_freq
    WHEN 'weekly'    THEN v_next_date + INTERVAL '7 days'
    WHEN 'biweekly'  THEN v_next_date + INTERVAL '14 days'
    WHEN 'monthly'   THEN v_next_date + INTERVAL '1 month'
    WHEN 'quarterly' THEN v_next_date + INTERVAL '3 months'
    WHEN 'yearly'    THEN v_next_date + INTERVAL '1 year'
  END;

  UPDATE recurring_invoices
  SET
    next_issue_date   = v_next_date,
    times_generated   = times_generated + 1,
    last_generated_at = NOW(),
    updated_at        = NOW()
  WHERE id = p_recurring_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FUNCTION: Updated get_dashboard_stats — now includes profit and time data
-- Replaces the v1 version of this function
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

    -- This month expenses
    'this_month_expenses', COALESCE((
      SELECT SUM(amount)
      FROM expenses
      WHERE user_id = p_user_id
        AND DATE_TRUNC('month', date) = DATE_TRUNC('month', CURRENT_DATE)
    ), 0),

    -- Net profit this month (earned - expenses)
    'this_month_profit', COALESCE((
      SELECT SUM(amount_paid)
      FROM payments
      WHERE user_id = p_user_id
        AND status = 'paid'
        AND DATE_TRUNC('month', paid_date) = DATE_TRUNC('month', CURRENT_DATE)
    ), 0) - COALESCE((
      SELECT SUM(amount)
      FROM expenses
      WHERE user_id = p_user_id
        AND DATE_TRUNC('month', date) = DATE_TRUNC('month', CURRENT_DATE)
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
    ), 0),

    -- Unbilled time value (new in v2)
    'unbilled_time_value', get_unbilled_time_value(p_user_id),

    -- Active timer running? (new in v2)
    'has_active_timer', EXISTS (
      SELECT 1 FROM time_entries
      WHERE user_id = p_user_id AND ended_at IS NULL
    )

  ) INTO v_result;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- DONE
-- v1 → v2 migration complete
-- ============================================================