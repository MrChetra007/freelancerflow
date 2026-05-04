-- ============================================================
-- FreelanceFlow — Complete Schema v2
-- File: schema_v2.sql
-- Run this on a FRESH Supabase project (no prior migrations)
-- Includes: all v1 tables + time_entries, expenses,
--           recurring_invoices, and all updated functions/views
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PROFILES
-- ============================================================
CREATE TABLE profiles (
  id                    UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name             TEXT,
  avatar_url            TEXT,
  email                 TEXT,
  currency              TEXT NOT NULL DEFAULT 'USD',
  timezone              TEXT NOT NULL DEFAULT 'UTC',
  business_name         TEXT,
  business_email        TEXT,
  business_phone        TEXT,
  business_address      TEXT,
  logo_url              TEXT,
  tax_id                TEXT,                          -- v2: for invoice compliance
  default_hourly_rate   NUMERIC(10, 2) NOT NULL DEFAULT 0,  -- v2: fallback for time tracking
  default_payment_terms TEXT,                          -- v2: e.g. "Net 30", "Due on receipt"
  is_pro                BOOLEAN NOT NULL DEFAULT FALSE,
  pro_expires_at        TIMESTAMPTZ,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- CLIENTS
-- ============================================================
CREATE TABLE clients (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name                TEXT NOT NULL,
  email               TEXT,
  phone               TEXT,
  company             TEXT,
  country             TEXT,
  currency            TEXT NOT NULL DEFAULT 'USD',
  notes               TEXT,
  avatar_color        TEXT NOT NULL DEFAULT '#2563EB',
  default_hourly_rate NUMERIC(10, 2) NOT NULL DEFAULT 0,  -- v2: overrides profile default
  tags                TEXT[] NOT NULL DEFAULT '{}',        -- v2: e.g. {'retainer','agency'}
  is_archived         BOOLEAN NOT NULL DEFAULT FALSE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_clients_user_id ON clients(user_id);
CREATE INDEX idx_clients_name    ON clients(user_id, name);

-- ============================================================
-- PROJECTS
-- ============================================================
CREATE TYPE project_status AS ENUM (
  'in_progress',
  'completed',
  'on_hold',
  'cancelled'
);

CREATE TABLE projects (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_id    UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  title        TEXT NOT NULL,
  description  TEXT,
  status       project_status NOT NULL DEFAULT 'in_progress',
  budget       NUMERIC(12, 2) NOT NULL DEFAULT 0,
  currency     TEXT NOT NULL DEFAULT 'USD',
  start_date   DATE,
  deadline     DATE,
  completed_at TIMESTAMPTZ,
  is_archived  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_projects_user_id   ON projects(user_id);
CREATE INDEX idx_projects_client_id ON projects(client_id);
CREATE INDEX idx_projects_status    ON projects(user_id, status);
CREATE INDEX idx_projects_deadline  ON projects(user_id, deadline);

-- ============================================================
-- MILESTONES
-- ============================================================
CREATE TABLE milestones (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id   UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title        TEXT NOT NULL,
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  due_date     DATE,
  sort_order   INTEGER NOT NULL DEFAULT 0,
  completed_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_milestones_project_id ON milestones(project_id);
CREATE INDEX idx_milestones_due_date   ON milestones(user_id, due_date);  -- v2: for notifications

-- ============================================================
-- PAYMENTS
-- ============================================================
CREATE TYPE payment_status AS ENUM (
  'paid',
  'unpaid',
  'partial',
  'overdue',
  'refunded'
);

CREATE TYPE payment_method AS ENUM (
  'bank_transfer',
  'paypal',
  'wise',
  'crypto',
  'cash',
  'stripe',
  'other'
);

CREATE TABLE payments (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_id    UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  project_id   UUID REFERENCES projects(id) ON DELETE SET NULL,
  amount       NUMERIC(12, 2) NOT NULL,
  amount_paid  NUMERIC(12, 2) NOT NULL DEFAULT 0,
  currency     TEXT NOT NULL DEFAULT 'USD',
  status       payment_status NOT NULL DEFAULT 'unpaid',
  method       payment_method,
  due_date     DATE,
  paid_date    DATE,
  description  TEXT,
  reference_no TEXT,
  notes        TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_user_id   ON payments(user_id);
CREATE INDEX idx_payments_client_id ON payments(client_id);
CREATE INDEX idx_payments_status    ON payments(user_id, status);
CREATE INDEX idx_payments_due_date  ON payments(user_id, due_date);
CREATE INDEX idx_payments_paid_date ON payments(user_id, paid_date);

-- ============================================================
-- INVOICES
-- ============================================================
CREATE TYPE invoice_status AS ENUM (
  'draft',
  'sent',
  'paid',
  'overdue',
  'cancelled'
);

CREATE TABLE invoices (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_id        UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  project_id       UUID REFERENCES projects(id) ON DELETE SET NULL,
  recurring_id     UUID,   -- v2: reference to recurring_invoices if auto-generated
  invoice_number   TEXT NOT NULL,
  status           invoice_status NOT NULL DEFAULT 'draft',
  issue_date       DATE NOT NULL DEFAULT CURRENT_DATE,
  due_date         DATE,
  subtotal         NUMERIC(12, 2) NOT NULL DEFAULT 0,
  tax_percent      NUMERIC(5, 2) NOT NULL DEFAULT 0,
  tax_amount       NUMERIC(12, 2) NOT NULL DEFAULT 0,
  discount_percent NUMERIC(5, 2) NOT NULL DEFAULT 0,
  discount_amount  NUMERIC(12, 2) NOT NULL DEFAULT 0,
  total            NUMERIC(12, 2) NOT NULL DEFAULT 0,
  currency         TEXT NOT NULL DEFAULT 'USD',
  notes            TEXT,
  payment_terms    TEXT,
  pdf_url          TEXT,
  sent_at          TIMESTAMPTZ,
  paid_at          TIMESTAMPTZ,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, invoice_number)
);

CREATE INDEX idx_invoices_user_id   ON invoices(user_id);
CREATE INDEX idx_invoices_client_id ON invoices(client_id);
CREATE INDEX idx_invoices_status    ON invoices(user_id, status);
CREATE INDEX idx_invoices_due_date  ON invoices(user_id, due_date);

-- ============================================================
-- INVOICE LINE ITEMS
-- ============================================================
CREATE TABLE invoice_items (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  invoice_id  UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  description TEXT NOT NULL,
  quantity    NUMERIC(10, 2) NOT NULL DEFAULT 1,
  unit_price  NUMERIC(12, 2) NOT NULL DEFAULT 0,
  total       NUMERIC(12, 2) NOT NULL DEFAULT 0,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_invoice_items_invoice_id ON invoice_items(invoice_id);

-- ============================================================
-- TIME ENTRIES  (v2)
-- ============================================================
CREATE TABLE time_entries (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  project_id       UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  client_id        UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  description      TEXT,
  started_at       TIMESTAMPTZ NOT NULL,
  ended_at         TIMESTAMPTZ,
  -- Auto-computed from start/end. NULL if timer is still running.
  duration_seconds INTEGER GENERATED ALWAYS AS (
    CASE
      WHEN ended_at IS NOT NULL
      THEN EXTRACT(EPOCH FROM (ended_at - started_at))::INTEGER
      ELSE NULL
    END
  ) STORED,
  hourly_rate      NUMERIC(10, 2) NOT NULL DEFAULT 0,
  is_billable      BOOLEAN NOT NULL DEFAULT TRUE,
  is_billed        BOOLEAN NOT NULL DEFAULT FALSE,
  invoice_id       UUID REFERENCES invoices(id) ON DELETE SET NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT valid_time_range CHECK (ended_at IS NULL OR ended_at > started_at)
);

CREATE INDEX idx_time_entries_user_id    ON time_entries(user_id);
CREATE INDEX idx_time_entries_project_id ON time_entries(project_id);
CREATE INDEX idx_time_entries_client_id  ON time_entries(client_id);
CREATE INDEX idx_time_entries_is_billed  ON time_entries(user_id, is_billed);
CREATE INDEX idx_time_entries_started_at ON time_entries(user_id, started_at DESC);
-- Enforce one active timer per user
CREATE UNIQUE INDEX idx_time_entries_active_timer
  ON time_entries(user_id)
  WHERE ended_at IS NULL;

-- ============================================================
-- EXPENSES  (v2)
-- ============================================================
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

CREATE TABLE expenses (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  project_id  UUID REFERENCES projects(id) ON DELETE SET NULL,
  client_id   UUID REFERENCES clients(id) ON DELETE SET NULL,
  category    expense_category NOT NULL DEFAULT 'other',
  description TEXT NOT NULL,
  amount      NUMERIC(12, 2) NOT NULL,
  currency    TEXT NOT NULL DEFAULT 'USD',
  date        DATE NOT NULL DEFAULT CURRENT_DATE,
  receipt_url TEXT,
  is_billable BOOLEAN NOT NULL DEFAULT FALSE,
  is_billed   BOOLEAN NOT NULL DEFAULT FALSE,
  invoice_id  UUID REFERENCES invoices(id) ON DELETE SET NULL,
  notes       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_expenses_user_id    ON expenses(user_id);
CREATE INDEX idx_expenses_project_id ON expenses(project_id);
CREATE INDEX idx_expenses_client_id  ON expenses(client_id);
CREATE INDEX idx_expenses_date       ON expenses(user_id, date DESC);
CREATE INDEX idx_expenses_category   ON expenses(user_id, category);
CREATE INDEX idx_expenses_is_billed  ON expenses(user_id, is_billed);

-- ============================================================
-- RECURRING INVOICES  (v2)
-- ============================================================
CREATE TYPE recurrence_frequency AS ENUM (
  'weekly',
  'biweekly',
  'monthly',
  'quarterly',
  'yearly'
);

CREATE TABLE recurring_invoices (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_id         UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  project_id        UUID REFERENCES projects(id) ON DELETE SET NULL,
  frequency         recurrence_frequency NOT NULL DEFAULT 'monthly',
  next_issue_date   DATE NOT NULL,
  due_days          INTEGER NOT NULL DEFAULT 30,
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  -- Line items as JSONB. Copied into invoice_items on generation.
  -- Format: [{"description":"...", "quantity":1, "unit_price":100.00}]
  line_items        JSONB NOT NULL DEFAULT '[]',
  tax_percent       NUMERIC(5, 2) NOT NULL DEFAULT 0,
  discount_percent  NUMERIC(5, 2) NOT NULL DEFAULT 0,
  currency          TEXT NOT NULL DEFAULT 'USD',
  notes             TEXT,
  payment_terms     TEXT,
  times_generated   INTEGER NOT NULL DEFAULT 0,
  last_generated_at TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_recurring_invoices_user_id    ON recurring_invoices(user_id);
CREATE INDEX idx_recurring_invoices_client_id  ON recurring_invoices(client_id);
CREATE INDEX idx_recurring_invoices_next_issue ON recurring_invoices(next_issue_date)
  WHERE is_active = TRUE;

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TYPE notification_type AS ENUM (
  'payment_overdue',
  'payment_received',
  'invoice_sent',
  'invoice_overdue',
  'project_deadline',
  'project_completed',
  'milestone_due',                  -- v2
  'recurring_invoice_generated',    -- v2
  'time_entry_reminder',            -- v2
  'weekly_summary',
  'system'
);

CREATE TABLE notifications (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type       notification_type NOT NULL,
  title      TEXT NOT NULL,
  body       TEXT NOT NULL,
  is_read    BOOLEAN NOT NULL DEFAULT FALSE,
  action_url TEXT,
  metadata   JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id  ON notifications(user_id);
CREATE INDEX idx_notifications_is_read  ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_created  ON notifications(user_id, created_at DESC);

-- ============================================================
-- ACTIVITY LOG
-- ============================================================
CREATE TYPE activity_type AS ENUM (
  'client_added',
  'client_updated',
  'project_created',
  'project_completed',
  'payment_logged',
  'payment_received',
  'invoice_created',
  'invoice_sent',
  'invoice_paid',
  'milestone_completed',
  'time_logged',            -- v2
  'expense_logged',         -- v2
  'recurring_invoice_created'  -- v2
);

CREATE TABLE activity_log (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type        activity_type NOT NULL,
  title       TEXT NOT NULL,
  entity_id   UUID,
  entity_type TEXT,   -- 'client' | 'project' | 'payment' | 'invoice' | 'time_entry' | 'expense'
  metadata    JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_activity_user_id ON activity_log(user_id);
CREATE INDEX idx_activity_created ON activity_log(user_id, created_at DESC);

-- ============================================================
-- UPDATED_AT TRIGGER FUNCTION
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON clients
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON projects
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON milestones
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON payments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON invoices
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON time_entries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON recurring_invoices
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients           ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects          ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestones        ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments          ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices          ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items     ENABLE ROW LEVEL SECURITY;
ALTER TABLE time_entries      ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses          ENABLE ROW LEVEL SECURITY;
ALTER TABLE recurring_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications     ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_log      ENABLE ROW LEVEL SECURITY;

-- profiles
CREATE POLICY "Users can view own profile"   ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- clients
CREATE POLICY "Users can view own clients"   ON clients FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own clients" ON clients FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own clients" ON clients FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own clients" ON clients FOR DELETE USING (auth.uid() = user_id);

-- projects
CREATE POLICY "Users can view own projects"   ON projects FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own projects" ON projects FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own projects" ON projects FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own projects" ON projects FOR DELETE USING (auth.uid() = user_id);

-- milestones
CREATE POLICY "Users can view own milestones"   ON milestones FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own milestones" ON milestones FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own milestones" ON milestones FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own milestones" ON milestones FOR DELETE USING (auth.uid() = user_id);

-- payments
CREATE POLICY "Users can view own payments"   ON payments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own payments" ON payments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own payments" ON payments FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own payments" ON payments FOR DELETE USING (auth.uid() = user_id);

-- invoices
CREATE POLICY "Users can view own invoices"   ON invoices FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own invoices" ON invoices FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own invoices" ON invoices FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own invoices" ON invoices FOR DELETE USING (auth.uid() = user_id);

-- invoice_items
CREATE POLICY "Users can view own invoice items"   ON invoice_items FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own invoice items" ON invoice_items FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own invoice items" ON invoice_items FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own invoice items" ON invoice_items FOR DELETE USING (auth.uid() = user_id);

-- time_entries
CREATE POLICY "Users can view own time entries"   ON time_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own time entries" ON time_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own time entries" ON time_entries FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own time entries" ON time_entries FOR DELETE USING (auth.uid() = user_id);

-- expenses
CREATE POLICY "Users can view own expenses"   ON expenses FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own expenses" ON expenses FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own expenses" ON expenses FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own expenses" ON expenses FOR DELETE USING (auth.uid() = user_id);

-- recurring_invoices
CREATE POLICY "Users can view own recurring invoices"   ON recurring_invoices FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own recurring invoices" ON recurring_invoices FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own recurring invoices" ON recurring_invoices FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own recurring invoices" ON recurring_invoices FOR DELETE USING (auth.uid() = user_id);

-- notifications
CREATE POLICY "Users can view own notifications"   ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own notifications" ON notifications FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "Service role can insert notifications" ON notifications FOR INSERT WITH CHECK (true);

-- activity_log
CREATE POLICY "Users can view own activity"   ON activity_log FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own activity" ON activity_log FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- STORAGE BUCKETS
-- ============================================================

-- Invoices bucket (private)
CREATE POLICY "Users can upload own invoice PDFs" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'invoices' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can read own invoice PDFs"   ON storage.objects FOR SELECT
  USING (bucket_id = 'invoices' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can delete own invoice PDFs" ON storage.objects FOR DELETE
  USING (bucket_id = 'invoices' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Avatars bucket (public read)
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true) ON CONFLICT (id) DO NOTHING;
CREATE POLICY "Public Read Access"          ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "Users can upload own avatars" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can update own avatars" ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can delete own avatars" ON storage.objects FOR DELETE
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Receipts bucket (private) — v2
INSERT INTO storage.buckets (id, name, public) VALUES ('receipts', 'receipts', false) ON CONFLICT (id) DO NOTHING;
CREATE POLICY "Users can upload own receipts" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'receipts' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can read own receipts"   ON storage.objects FOR SELECT
  USING (bucket_id = 'receipts' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can delete own receipts" ON storage.objects FOR DELETE
  USING (bucket_id = 'receipts' AND auth.uid()::text = (storage.foldername(name))[1]);

-- ============================================================
-- FUNCTION: Auto-create profile on sign-up
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
-- FUNCTION: Get next invoice number
-- ============================================================
CREATE OR REPLACE FUNCTION get_next_invoice_number(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
  v_count  INTEGER;
  v_number TEXT;
BEGIN
  SELECT COUNT(*) + 1 INTO v_count
  FROM invoices WHERE user_id = p_user_id;
  v_number := 'INV-' || LPAD(v_count::TEXT, 4, '0');
  RETURN v_number;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Mark overdue payments
-- ============================================================
CREATE OR REPLACE FUNCTION mark_overdue_payments()
RETURNS INTEGER AS $$
DECLARE v_updated INTEGER;
BEGIN
  UPDATE payments SET status = 'overdue', updated_at = NOW()
  WHERE status IN ('unpaid', 'partial')
    AND due_date < CURRENT_DATE
    AND due_date IS NOT NULL;
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RETURN v_updated;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Mark overdue invoices
-- ============================================================
CREATE OR REPLACE FUNCTION mark_overdue_invoices()
RETURNS INTEGER AS $$
DECLARE v_updated INTEGER;
BEGIN
  UPDATE invoices SET status = 'overdue', updated_at = NOW()
  WHERE status = 'sent'
    AND due_date < CURRENT_DATE
    AND due_date IS NOT NULL;
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RETURN v_updated;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Get unbilled time value  (v2)
-- ============================================================
CREATE OR REPLACE FUNCTION get_unbilled_time_value(p_user_id UUID)
RETURNS NUMERIC AS $$
BEGIN
  RETURN COALESCE((
    SELECT SUM(ROUND((duration_seconds::NUMERIC / 3600) * hourly_rate, 2))
    FROM time_entries
    WHERE user_id = p_user_id
      AND is_billable = TRUE
      AND is_billed = FALSE
      AND ended_at IS NOT NULL
  ), 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Get active timer  (v2)
-- ============================================================
CREATE OR REPLACE FUNCTION get_active_timer(p_user_id UUID)
RETURNS TABLE (
  id UUID, project_id UUID, client_id UUID,
  description TEXT, started_at TIMESTAMPTZ, hourly_rate NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT te.id, te.project_id, te.client_id,
         te.description, te.started_at, te.hourly_rate
  FROM time_entries te
  WHERE te.user_id = p_user_id AND te.ended_at IS NULL
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Get expense breakdown by category  (v2)
-- ============================================================
CREATE OR REPLACE FUNCTION get_expense_breakdown(p_user_id UUID, p_months INTEGER DEFAULT 6)
RETURNS TABLE (category TEXT, total NUMERIC, entry_count BIGINT) AS $$
BEGIN
  RETURN QUERY
  SELECT e.category::TEXT, COALESCE(SUM(e.amount), 0) AS total, COUNT(*) AS entry_count
  FROM expenses e
  WHERE e.user_id = p_user_id
    AND e.date >= (CURRENT_DATE - (p_months || ' months')::INTERVAL)::DATE
  GROUP BY e.category
  ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Get recurring invoices due  (v2)
-- ============================================================
CREATE OR REPLACE FUNCTION get_due_recurring_invoices(p_user_id UUID)
RETURNS TABLE (id UUID, client_id UUID, client_name TEXT, frequency TEXT, line_items JSONB) AS $$
BEGIN
  RETURN QUERY
  SELECT ri.id, ri.client_id, c.name AS client_name, ri.frequency::TEXT, ri.line_items
  FROM recurring_invoices ri
  JOIN clients c ON c.id = ri.client_id
  WHERE ri.user_id = p_user_id
    AND ri.is_active = TRUE
    AND ri.next_issue_date <= CURRENT_DATE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Advance recurring invoice schedule  (v2)
-- ============================================================
CREATE OR REPLACE FUNCTION advance_recurring_invoice(p_recurring_id UUID)
RETURNS VOID AS $$
DECLARE
  v_freq      recurrence_frequency;
  v_next_date DATE;
BEGIN
  SELECT frequency, next_issue_date INTO v_freq, v_next_date
  FROM recurring_invoices WHERE id = p_recurring_id;

  v_next_date := CASE v_freq
    WHEN 'weekly'    THEN v_next_date + INTERVAL '7 days'
    WHEN 'biweekly'  THEN v_next_date + INTERVAL '14 days'
    WHEN 'monthly'   THEN v_next_date + INTERVAL '1 month'
    WHEN 'quarterly' THEN v_next_date + INTERVAL '3 months'
    WHEN 'yearly'    THEN v_next_date + INTERVAL '1 year'
  END;

  UPDATE recurring_invoices
  SET next_issue_date = v_next_date,
      times_generated = times_generated + 1,
      last_generated_at = NOW(),
      updated_at = NOW()
  WHERE id = p_recurring_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Dashboard stats  (updated in v2 — includes profit + time)
-- ============================================================
CREATE OR REPLACE FUNCTION get_dashboard_stats(p_user_id UUID)
RETURNS JSON AS $$
DECLARE v_result JSON;
BEGIN
  SELECT json_build_object(
    'this_month_earned', COALESCE((
      SELECT SUM(amount_paid) FROM payments
      WHERE user_id = p_user_id AND status = 'paid'
        AND DATE_TRUNC('month', paid_date) = DATE_TRUNC('month', CURRENT_DATE)
    ), 0),
    'this_month_expenses', COALESCE((
      SELECT SUM(amount) FROM expenses
      WHERE user_id = p_user_id
        AND DATE_TRUNC('month', date) = DATE_TRUNC('month', CURRENT_DATE)
    ), 0),
    'this_month_profit', COALESCE((
      SELECT SUM(amount_paid) FROM payments
      WHERE user_id = p_user_id AND status = 'paid'
        AND DATE_TRUNC('month', paid_date) = DATE_TRUNC('month', CURRENT_DATE)
    ), 0) - COALESCE((
      SELECT SUM(amount) FROM expenses
      WHERE user_id = p_user_id
        AND DATE_TRUNC('month', date) = DATE_TRUNC('month', CURRENT_DATE)
    ), 0),
    'total_unpaid', COALESCE((
      SELECT SUM(amount - amount_paid) FROM payments
      WHERE user_id = p_user_id AND status IN ('unpaid', 'partial')
    ), 0),
    'overdue_count', COALESCE((
      SELECT COUNT(*) FROM payments
      WHERE user_id = p_user_id AND status IN ('unpaid', 'partial') AND due_date < CURRENT_DATE
    ), 0),
    'overdue_amount', COALESCE((
      SELECT SUM(amount - amount_paid) FROM payments
      WHERE user_id = p_user_id AND status IN ('unpaid', 'partial') AND due_date < CURRENT_DATE
    ), 0),
    'active_projects', COALESCE((
      SELECT COUNT(*) FROM projects
      WHERE user_id = p_user_id AND status = 'in_progress'
    ), 0),
    'total_clients', COALESCE((
      SELECT COUNT(*) FROM clients
      WHERE user_id = p_user_id AND is_archived = FALSE
    ), 0),
    'pending_invoices', COALESCE((
      SELECT COUNT(*) FROM invoices
      WHERE user_id = p_user_id AND status IN ('sent', 'overdue')
    ), 0),
    'unbilled_time_value', get_unbilled_time_value(p_user_id),
    'has_active_timer', EXISTS (
      SELECT 1 FROM time_entries WHERE user_id = p_user_id AND ended_at IS NULL
    )
  ) INTO v_result;
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: Monthly earnings chart (last 6 months)
-- ============================================================
CREATE OR REPLACE FUNCTION get_monthly_earnings(p_user_id UUID)
RETURNS TABLE (month TEXT, year INTEGER, month_num INTEGER, total NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT
    TO_CHAR(gs.month_start, 'Mon') AS month,
    EXTRACT(YEAR FROM gs.month_start)::INTEGER AS year,
    EXTRACT(MONTH FROM gs.month_start)::INTEGER AS month_num,
    COALESCE(SUM(p.amount_paid), 0) AS total
  FROM GENERATE_SERIES(
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
-- VIEWS
-- ============================================================

-- Client summary
CREATE OR REPLACE VIEW client_summary AS
SELECT
  c.id, c.user_id, c.name, c.email, c.phone, c.company, c.country,
  c.currency, c.avatar_color, c.tags, c.default_hourly_rate, c.is_archived, c.created_at,
  COUNT(DISTINCT p.id) FILTER (WHERE p.status = 'in_progress') AS active_projects,
  COUNT(DISTINCT p.id) AS total_projects,
  COALESCE(SUM(pay.amount_paid) FILTER (WHERE pay.status = 'paid'), 0) AS total_earned,
  COALESCE(SUM(pay.amount - pay.amount_paid) FILTER (WHERE pay.status IN ('unpaid', 'partial', 'overdue')), 0) AS total_outstanding
FROM clients c
LEFT JOIN projects p ON p.client_id = c.id
LEFT JOIN payments pay ON pay.client_id = c.id
GROUP BY c.id;

-- Project summary
CREATE OR REPLACE VIEW project_summary AS
SELECT
  p.id, p.user_id, p.client_id, p.title, p.description, p.status,
  p.budget, p.currency, p.start_date, p.deadline, p.completed_at,
  p.is_archived, p.created_at, p.updated_at,
  c.name AS client_name, c.company AS client_company, c.avatar_color AS client_avatar_color,
  COUNT(m.id) AS total_milestones,
  COUNT(m.id) FILTER (WHERE m.is_completed = TRUE) AS completed_milestones,
  CASE WHEN COUNT(m.id) = 0 THEN 0
    ELSE ROUND((COUNT(m.id) FILTER (WHERE m.is_completed = TRUE) * 100.0) / COUNT(m.id))
  END AS progress_percent,
  COALESCE(SUM(pay.amount_paid), 0) AS total_paid,
  -- v2: include time tracked value
  COALESCE((
    SELECT SUM(ROUND((te.duration_seconds::NUMERIC / 3600) * te.hourly_rate, 2))
    FROM time_entries te WHERE te.project_id = p.id AND te.ended_at IS NOT NULL
  ), 0) AS total_time_value,
  CASE WHEN p.deadline < CURRENT_DATE AND p.status = 'in_progress' THEN TRUE ELSE FALSE END AS is_overdue
FROM projects p
LEFT JOIN clients c ON c.id = p.client_id
LEFT JOIN milestones m ON m.project_id = p.id
LEFT JOIN payments pay ON pay.project_id = p.id AND pay.status = 'paid'
GROUP BY p.id, c.id;

-- Time entry summary  (v2)
CREATE OR REPLACE VIEW time_entry_summary AS
SELECT
  te.id, te.user_id, te.project_id, te.client_id, te.description,
  te.started_at, te.ended_at, te.duration_seconds, te.hourly_rate,
  te.is_billable, te.is_billed, te.invoice_id, te.created_at,
  ROUND((COALESCE(te.duration_seconds, 0)::NUMERIC / 3600) * te.hourly_rate, 2) AS billable_amount,
  p.title AS project_title, p.status AS project_status,
  c.name AS client_name, c.company AS client_company, c.avatar_color AS client_avatar_color
FROM time_entries te
LEFT JOIN projects p ON p.id = te.project_id
LEFT JOIN clients  c ON c.id = te.client_id;

-- Expense summary  (v2)
CREATE OR REPLACE VIEW expense_summary AS
SELECT
  e.id, e.user_id, e.project_id, e.client_id, e.category, e.description,
  e.amount, e.currency, e.date, e.receipt_url, e.is_billable, e.is_billed,
  e.invoice_id, e.notes, e.created_at,
  p.title AS project_title,
  c.name AS client_name, c.avatar_color AS client_avatar_color
FROM expenses e
LEFT JOIN projects p ON p.id = e.project_id
LEFT JOIN clients  c ON c.id = e.client_id;

GRANT SELECT ON client_summary     TO authenticated;
GRANT SELECT ON project_summary    TO authenticated;
GRANT SELECT ON time_entry_summary TO authenticated;
GRANT SELECT ON expense_summary    TO authenticated;

ALTER VIEW client_summary     SET (security_barrier = true);
ALTER VIEW project_summary    SET (security_barrier = true);
ALTER VIEW time_entry_summary SET (security_barrier = true);
ALTER VIEW expense_summary    SET (security_barrier = true);

-- ============================================================
-- DONE — FreelanceFlow schema v2 complete
-- ============================================================
