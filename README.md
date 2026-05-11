# FreelanceFlow — Freelance Client Manager

A cross-platform Flutter app for freelancers to manage clients, projects, invoices, payments, time tracking, and expenses — all backed by Supabase.

## Tech Stack

- **Framework**: Flutter (Android, iOS, Web, Linux, macOS, Windows)
- **Backend**: Supabase (Auth, PostgreSQL, Storage, Row Level Security)
- **State Management**: Riverpod with code generation
- **Architecture**: Feature-first Clean Architecture (Repository pattern)
- **Navigation**: go_router
- **Models**: Freezed + JSON serialization

## Features

### Core
- **Auth** — Google Sign-In & email/password via Supabase
- **Clients** — CRUD with search, sort, country/currency filter
- **Projects** — Status tracking (in-progress/completed/on-hold/cancelled), milestones with progress bar, budget tracking
- **Payments** — Multi-method logging (bank/PayPal/Wise/crypto/cash), status tracking (paid/unpaid/partial/overdue), monthly grouping
- **Invoices** — Auto-numbering (INV-0001), line items, tax/discount, PDF generation, share via WhatsApp/Gmail/Drive, Supabase Storage
- **Dashboard** — Stats cards (monthly earnings, unpaid, overdue, active projects), 6-month earnings chart (fl_chart), recent activity feed
- **Settings** — Theme toggle (light/dark/system), notification prefs, premium status

### Time Tracking
- Live timer with per-second updates
- Billable/non-billable hours per project
- Timer rounding (5/15/30 min)
- Default hourly rate per user
- Manual entry logging
- Filtering: All, Billable, Unbilled, This Week, This Month

### Expenses
- Expense logging with amount, category, date, receipt image
- Expense breakdown chart
- Filter by category

### Recurring Invoices
- Auto-generate invoices on a schedule (daily/weekly/monthly/yearly)
- Line item templates
- Next invoice date tracking

### Notifications
- Local push notifications for overdue payments, project deadlines, unpaid invoice nudges, weekly summaries
- In-app notification bell with badge
- Notification tester & scheduled view

### Monetization
- Freemium model (Free tier with limits, Pro via in-app purchase)
- Feature gating (Pro required for cloud sync, custom branding, dashboard charts, notifications)

## Setup

### Prerequisites
- Flutter SDK ^3.11.4
- A Supabase project

### Supabase Setup
1. Create a project at [supabase.com](https://supabase.com)
2. Run SQL migrations in order:
   - `001_initial_schema.sql`
   - `002_rls_policies.sql`
   - `003_functions.sql`
   - `schema_v2.sql` (time tracking, expenses, recurring invoices)
3. Enable Google Auth provider in Supabase Dashboard → Authentication → Providers
4. Create storage buckets: `invoices`, `avatars`

### Environment
Create a `.env` file in the project root:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Run
```bash
flutter pub get
flutter run
```

For generated code (after model changes):
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── app.dart                   # MaterialApp.router with theme & Riverpod
├── core/
│   ├── theme/                 # AppTheme, AppColors, ThemeNotifier
│   ├── router/                # go_router config
│   ├── supabase/              # Supabase client init
│   ├── services/              # Notifications, IAP, recurring gen, milestone check
│   ├── utils/                 # PDF generator, currency/date/duration formatters
│   └── widgets/               # Shared widgets (pro gate, loading, celebration)
└── features/
    ├── auth/                  # Login, splash screens
    ├── clients/               # Client CRUD
    ├── projects/              # Projects & milestones
    ├── payments/              # Payment logging
    ├── invoices/              # Invoice builder & PDF
    ├── expenses/              # Expense tracking
    ├── time_tracking/         # Timer, manual entries
    ├── recurring/             # Recurring invoice templates
    ├── dashboard/             # Stats & charts
    └── settings/              # Profile, prefs, premium
```

## Database

The `profiles` table stores user settings including:
- `default_hourly_rate` — Default rate applied to new time entries
- `default_payment_terms` — Default terms on invoices (e.g. "Net 30")
- `tax_id` — Business tax/VAT number for invoice branding
- `currency`, `timezone` — User preferences

## Models

Key models use `@freezed` with `DateTimeUtcConverter` on all datetime fields to ensure consistent UTC storage and retrieval.
