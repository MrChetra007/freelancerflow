# 📱 FreelanceFlow — Complete Build Roadmap v2
> Flutter (Android) · Supabase Backend · Blue Professional Theme · Dark & Light Mode
> Target: Advanced Flutter Developer

---

## 🗂️ Table of Contents
1. [Project Overview](#1-project-overview)
2. [App Architecture](#2-app-architecture)
3. [Folder Structure](#3-folder-structure)
4. [Theme System](#4-theme-system)
5. [Supabase Setup](#5-supabase-setup)
6. [Phase 1 — Foundation](#phase-1--foundation-weeks-12)
7. [Phase 2 — Core Features](#phase-2--core-features-weeks-34)
8. [Phase 3 — Invoices & PDF](#phase-3--invoices--pdf-weeks-56)
9. [Phase 4 — Dashboard & Charts](#phase-4--dashboard--charts-week-7)
10. [Phase 5 — Notifications & Reminders](#phase-5--notifications--reminders-week-8)
11. [Phase 6 — Monetization](#phase-6--monetization-weeks-910)
12. [Phase 7 — Polish & Release](#phase-7--polish--release-weeks-1112)
13. [Phase 8 — Time Tracking, Expenses & Recurring Invoices](#phase-8--time-tracking-expenses--recurring-invoices-weeks-1315)
14. [Dependencies](#dependencies)
15. [Environment Variables](#environment-variables)

---

## 1. Project Overview

| Item | Detail |
|---|---|
| **App Name** | FreelanceFlow |
| **Platform** | Android (Flutter) |
| **Backend** | Supabase (Auth + PostgreSQL + Storage + Edge Functions) |
| **State Management** | Riverpod (with code generation) |
| **Architecture** | Feature-first Clean Architecture |
| **Theme** | Blue Professional · Dark & Light Mode · User-toggleable |
| **Monetization** | Freemium → Pro ($5/month via Google Play Billing) |
| **Schema Version** | v2 (time_entries, expenses, recurring_invoices) |

---

## 2. App Architecture

```
Presentation Layer  →  Feature Screens + Widgets
        ↕
Application Layer   →  Riverpod Providers + Use Cases
        ↕
Domain Layer        →  Entities + Repository Interfaces
        ↕
Data Layer          →  Supabase Repos + Local Cache (Drift/SQLite)
```

**Patterns used:**
- Repository Pattern for all data access
- AsyncNotifier for async state
- Freezed for immutable models
- go_router for navigation
- Offline-first: local SQLite cache syncs with Supabase

---

## 3. Folder Structure

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + theme + router
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── theme_notifier.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── supabase/
│   │   └── supabase_client.dart
│   ├── database/
│   │   ├── app_database.dart         # Drift DB definition (includes v2 tables)
│   │   └── app_database.g.dart
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   ├── date_formatter.dart
│   │   ├── duration_formatter.dart   # v2: formats seconds → "2h 34m"
│   │   └── pdf_generator.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_card.dart
│       ├── status_badge.dart
│       └── empty_state.dart
│
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart
│   │   ├── domain/user_entity.dart
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       └── splash_screen.dart
│   │
│   ├── dashboard/
│   │   ├── data/dashboard_repository.dart
│   │   ├── domain/dashboard_stats.dart    # v2: includes profit, unbilled_time_value
│   │   └── presentation/
│   │       ├── dashboard_screen.dart
│   │       └── widgets/
│   │           ├── stats_card.dart
│   │           ├── earnings_chart.dart
│   │           ├── profit_card.dart       # v2: shows revenue - expenses
│   │           ├── active_timer_banner.dart # v2: shows running timer if active
│   │           └── recent_activity.dart
│   │
│   ├── clients/
│   │   ├── data/client_repository.dart
│   │   ├── domain/client_entity.dart      # v2: + tags, default_hourly_rate
│   │   └── presentation/
│   │       ├── clients_screen.dart
│   │       ├── client_detail_screen.dart
│   │       ├── add_client_screen.dart
│   │       └── widgets/client_card.dart
│   │
│   ├── projects/
│   │   ├── data/project_repository.dart
│   │   ├── domain/project_entity.dart
│   │   └── presentation/
│   │       ├── projects_screen.dart
│   │       ├── project_detail_screen.dart  # v2: + time entries tab
│   │       ├── add_project_screen.dart
│   │       └── widgets/
│   │           ├── project_card.dart
│   │           └── milestone_tile.dart
│   │
│   ├── payments/
│   │   ├── data/payment_repository.dart
│   │   ├── domain/payment_entity.dart
│   │   └── presentation/
│   │       ├── payments_screen.dart
│   │       ├── add_payment_screen.dart
│   │       └── widgets/payment_tile.dart
│   │
│   ├── invoices/
│   │   ├── data/invoice_repository.dart
│   │   ├── domain/invoice_entity.dart
│   │   └── presentation/
│   │       ├── invoices_screen.dart
│   │       ├── invoice_detail_screen.dart
│   │       ├── create_invoice_screen.dart  # v2: + import time entries / expenses
│   │       └── widgets/invoice_card.dart
│   │
│   ├── time_tracking/                # v2 — NEW FEATURE
│   │   ├── data/
│   │   │   └── time_entry_repository.dart
│   │   ├── domain/
│   │   │   └── time_entry_entity.dart
│   │   └── presentation/
│   │       ├── time_tracking_screen.dart   # list of entries + active timer
│   │       ├── add_time_entry_screen.dart  # manual entry or edit
│   │       └── widgets/
│   │           ├── timer_widget.dart        # live counting timer
│   │           ├── time_entry_tile.dart
│   │           └── billable_summary_card.dart
│   │
│   ├── expenses/                     # v2 — NEW FEATURE
│   │   ├── data/
│   │   │   └── expense_repository.dart
│   │   ├── domain/
│   │   │   └── expense_entity.dart
│   │   └── presentation/
│   │       ├── expenses_screen.dart        # list + category filter
│   │       ├── add_expense_screen.dart     # + receipt photo upload
│   │       └── widgets/
│   │           ├── expense_tile.dart
│   │           └── expense_breakdown_chart.dart  # pie chart by category
│   │
│   ├── recurring/                    # v2 — NEW FEATURE
│   │   ├── data/
│   │   │   └── recurring_invoice_repository.dart
│   │   ├── domain/
│   │   │   └── recurring_invoice_entity.dart
│   │   └── presentation/
│   │       ├── recurring_invoices_screen.dart
│   │       ├── create_recurring_screen.dart
│   │       └── widgets/
│   │           └── recurring_invoice_tile.dart
│   │
│   └── settings/
│       └── presentation/
│           ├── settings_screen.dart        # v2: + default hourly rate, tax ID
│           └── widgets/theme_toggle.dart
│
supabase/
└── migrations/
    ├── 001_initial_schema.sql        # v1 — original
    ├── migration_to_v2.sql           # v1 → v2 delta (run if you have v1 data)
    └── schema_v2.sql                 # fresh install — full v2 schema
```

---

## 4. Theme System

### Color Palette

```dart
class AppColors {
  // PRIMARY BLUE PALETTE
  static const primary50  = Color(0xFFEFF6FF);
  static const primary100 = Color(0xFFDBEAFE);
  static const primary200 = Color(0xFFBFDBFE);
  static const primary300 = Color(0xFF93C5FD);
  static const primary400 = Color(0xFF60A5FA);
  static const primary500 = Color(0xFF3B82F6); // Main brand blue
  static const primary600 = Color(0xFF2563EB);
  static const primary700 = Color(0xFF1D4ED8);
  static const primary800 = Color(0xFF1E40AF);
  static const primary900 = Color(0xFF1E3A8A);

  // LIGHT THEME
  static const lightBackground    = Color(0xFFF8FAFC);
  static const lightSurface       = Color(0xFFFFFFFF);
  static const lightSurfaceAlt    = Color(0xFFF1F5F9);
  static const lightBorder        = Color(0xFFE2E8F0);
  static const lightTextPrimary   = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);

  // DARK THEME
  static const darkBackground    = Color(0xFF0F172A);
  static const darkSurface       = Color(0xFF1E293B);
  static const darkSurfaceAlt    = Color(0xFF334155);
  static const darkBorder        = Color(0xFF475569);
  static const darkTextPrimary   = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);

  // SEMANTIC
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error   = Color(0xFFEF4444);
  static const info    = Color(0xFF3B82F6);

  // STATUS
  static const statusPaid    = Color(0xFF22C55E);
  static const statusUnpaid  = Color(0xFFF59E0B);
  static const statusOverdue = Color(0xFFEF4444);
  static const statusPartial = Color(0xFF8B5CF6);
  static const statusActive  = Color(0xFF3B82F6);
  static const statusDone    = Color(0xFF6B7280);
  static const statusOnHold  = Color(0xFFF97316);

  // v2 — TIME TRACKING
  static const timerRunning = Color(0xFF22C55E);   // green pulse when active
  static const timerStopped = Color(0xFF64748B);

  // v2 — EXPENSE CATEGORIES
  static const expenseSoftware  = Color(0xFF6366F1);
  static const expenseTravel    = Color(0xFFF59E0B);
  static const expenseHardware  = Color(0xFF3B82F6);
  static const expenseOther     = Color(0xFF94A3B8);
}
```

---

## 5. Supabase Setup

### Step-by-step

1. Go to [supabase.com](https://supabase.com) → Create new project
2. Name it `freelanceflow`, choose your region
3. Go to **SQL Editor**:
   - Fresh install → run `schema_v2.sql`
   - Existing v1 install → run `migration_to_v2.sql`
4. Go to **Authentication** → Providers → Enable **Google**
5. Go to **Storage** → confirm 3 buckets exist: `invoices`, `avatars`, `receipts`
6. Copy your `Project URL` and `anon key` → add to `.env`

---

## Phase 1 — Foundation (Weeks 1–2)

### ✅ Goals
- Project setup, architecture scaffold
- Supabase auth (Google + email)
- Theme system (dark/light toggle)
- Navigation shell (bottom nav)

### Step 1.1 — Auth Flow

```
Splash Screen
    ↓ check session
    ├── Logged in  → Dashboard
    └── Logged out → Login Screen
                        ├── Google Sign-In
                        └── Email + Password
```

### Step 1.2 — Navigation Shell

```dart
// Bottom nav destinations:
// 0: Dashboard     (Icons.dashboard_rounded)
// 1: Clients       (Icons.people_rounded)
// 2: Projects      (Icons.folder_rounded)
// 3: Payments      (Icons.payments_rounded)
// 4: Invoices      (Icons.receipt_long_rounded)
// FAB: Quick Add (context-aware per tab)

// v2 — Time Tracking and Expenses accessible from:
// - Project Detail screen → Time tab
// - FAB quick actions → "Log Time", "Add Expense"
// - Settings → dedicated sections
```

### Step 1.3 — Offline-first Setup
- Drift local DB mirrors all Supabase tables including v2 tables
- On app open: sync changed records
- All writes go to local first, then queue sync
- Show "offline" indicator banner when no network

---

## Phase 2 — Core Features (Weeks 3–4)

### ✅ Goals
- Full CRUD: Clients, Projects, Milestones, Payments
- Syncs to Supabase

### Step 2.1 — Clients (v2 additions)

```dart
@freezed
class Client with _$Client {
  const factory Client({
    required String id,
    required String userId,
    required String name,
    String? email,
    String? phone,
    String? company,
    String? country,
    String? currency,
    String? notes,
    required double defaultHourlyRate,  // v2
    required List<String> tags,          // v2
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Client;
}
```

**Client Screen features:**
- Search bar with debounce
- Sort by: Name / Recent / Most Revenue
- Filter by: Country / Currency / Tag (v2)
- Swipe-to-delete with confirmation
- Tap to open Client Detail

**Client Detail Screen:**
- Header: avatar initials + name + country flag emoji
- Tabs: Projects | Payments | Invoices | Time (v2)
- Total earned + total expenses per client (v2)

### Step 2.2 — Projects (v2 additions)

**Project Detail Screen — tabs:**
- Overview (milestones, status, dates)
- Payments
- Time Entries (v2) — lists logged hours, shows total billed/unbilled
- Expenses (v2) — lists project costs

### Step 2.3 — Payment Tracker
- Filter: All | Paid | Unpaid | Overdue | Partial
- Monthly total at top
- Grouped by month with section headers
- Quick-add FAB

---

## Phase 3 — Invoices & PDF (Weeks 5–6)

### ✅ Goals
- Create invoices from project data
- PDF generation and sharing
- Upload PDF to Supabase Storage

### Step 3.1 — Invoice Builder (v2 additions)

**New import flows:**
- "Import Time Entries" button — lists unbilled time entries for the selected client/project, checkboxes, tap to add as line items
- "Import Expenses" button — lists billable unbilled expenses, tap to add as line items
- After import → sets `is_billed = true` on selected time_entries / expenses and links `invoice_id`

```dart
// Import time entries as line items
final entries = await timeEntryRepo.getUnbilledForClient(clientId);
// Each entry becomes: description = entry.description ?? project.title
//                    quantity    = duration_hours (rounded to 2dp)
//                    unit_price  = entry.hourly_rate
```

### Step 3.2 — PDF Generation
- Same as v1 but now includes "Hours Worked" line items from time entries
- Shows time period if imported from time tracker

### Step 3.3 — Recurring Invoice Setup (v2)

- Toggle on create_invoice_screen: "Make this recurring"
- If toggled: show frequency picker + next issue date
- On save: creates recurring_invoices record instead of (or alongside) draft invoice
- Workmanager checks on app launch and generates due invoices

---

## Phase 4 — Dashboard & Charts (Week 7)

### ✅ Goals
- Financial overview at a glance
- Earnings chart (monthly)
- Key stats cards
- Recent activity feed

### Step 4.1 — Stats Cards (v2 — updated)

| Card | Value | Note |
|---|---|---|
| 💰 This Month | Sum of paid payments this month | Same as v1 |
| 📉 Expenses | Total expenses this month | **New v2** |
| 📈 Net Profit | Earned − Expenses this month | **New v2** |
| ⏳ Unpaid | Total outstanding amount | Same as v1 |
| 🔴 Overdue | Count + amount overdue | Same as v1 |
| 📁 Active Projects | Count of in-progress projects | Same as v1 |
| ⏱ Unbilled Time | Value of unbilled hours | **New v2** |

### Step 4.2 — Active Timer Banner (v2)

- If `has_active_timer = true` from dashboard stats, show a persistent green banner at top of dashboard
- Shows: project name, client name, elapsed time (live updating)
- Tap → navigates to Time Tracking screen
- Stop button directly on banner

```dart
// Poll active timer every second using a local Timer.periodic
// Data from: get_active_timer(user_id) Supabase function
// Elapsed = DateTime.now().difference(startedAt)
```

### Step 4.3 — Earnings Chart
- fl_chart BarChart
- X-axis: last 6 months
- Two bar series per month: Revenue (primary500) + Expenses (error/red)
- Tap bar → tooltip showing both values and profit

### Step 4.4 — Recent Activity Feed
- Last 10 events across all features
- v2 additions: time_logged, expense_logged, recurring_invoice_created

---

## Phase 5 — Notifications & Reminders (Week 8)

### ✅ Goals
- Local notifications for overdue payments and invoices
- Deadline warnings for projects and milestones
- Follow-up nudges for unpaid invoices
- Recurring invoice generation alerts
- Weekly summary

### Step 5.1 — Notification Types (v2 — updated)

| Trigger | Message | When |
|---|---|---|
| Payment overdue | "Client X owes $500 — overdue by 3 days" | Daily at 9am if overdue |
| Project deadline | "Project Y is due tomorrow" | 24h before deadline |
| **Milestone due** | "Milestone 'Design mockup' due today" | Day of due_date at 9am **(v2)** |
| Invoice unpaid | "Invoice INV-0023 unpaid for 14 days" | Every 7 days after due date |
| **Recurring generated** | "Invoice auto-created for Client X — review it" | On generation **(v2)** |
| Weekly summary | "This week: $1,200 earned, 2 invoices pending" | Every Monday 8am |

### Step 5.2 — Implementation

```dart
// flutter_local_notifications + workmanager

// Schedule on app launch:
await NotificationService.scheduleOverdueCheck();
await NotificationService.scheduleDeadlineCheck();
await NotificationService.scheduleMilestoneDueCheck();    // v2
await NotificationService.scheduleWeeklySummary();
await NotificationService.checkRecurringInvoices();       // v2

// Milestone check: query milestones WHERE due_date = TODAY AND is_completed = FALSE
// Recurring check: call get_due_recurring_invoices() → generate invoice → call advance_recurring_invoice()
```

### Step 5.3 — Notification ID Strategy

```dart
// Use stable IDs so rescheduling replaces rather than duplicates:
// payment overdue:  hash(payment.id) % 100000
// project deadline: hash(project.id) % 100000 + 100000
// milestone due:    hash(milestone.id) % 100000 + 200000  // v2
// weekly summary:   999999 (fixed)
```

### Step 5.4 — In-App Notification Bell
- Bell icon in AppBar with unread badge count
- Dropdown sheet with all recent alerts
- Tap alert → navigate to relevant screen
- Mark all as read
- v2: recurring_invoice_generated taps navigate to invoice detail

---

## Phase 6 — Monetization (Weeks 9–10)

### ✅ Goals
- Freemium gates implemented
- Google Play Billing via RevenueCat
- Paywall screen with plan comparison

### Step 6.1 — Free vs Pro Limits (v2 — updated)

| Feature | Free | Pro |
|---|---|---|
| Clients | Max 3 | Unlimited |
| Invoices/month | Max 5 | Unlimited |
| PDF export | ✅ | ✅ |
| Cloud sync | ❌ | ✅ |
| Custom branding on invoices | ❌ | ✅ |
| Reminders & notifications | ❌ | ✅ |
| Dashboard charts | ❌ | ✅ |
| **Time tracking** | Max 10 entries/month | Unlimited **(v2)** |
| **Expense tracking** | Max 10 entries/month | Unlimited **(v2)** |
| **Recurring invoices** | ❌ | ✅ **(v2)** |
| **Expense breakdown chart** | ❌ | ✅ **(v2)** |
| Priority support | ❌ | ✅ |

### Step 6.2 — RevenueCat Setup

```dart
await Purchases.configure(
  PurchasesConfiguration(Env.revenuecatApiKey),
);
// Products:
// freelanceflow_pro_monthly  → $4.99/month
// freelanceflow_pro_yearly   → $39.99/year
// freelanceflow_pro_lifetime → $29.99 one-time
```

### Step 6.3 — Pro Status Provider

```dart
@riverpod
Future<bool> isProUser(IsProUserRef ref) async {
  final info = await Purchases.getCustomerInfo();
  return info.entitlements.active.containsKey('pro');
}
```

---

## Phase 7 — Polish & Release (Weeks 11–12)

### ✅ Goals
- UI animations & micro-interactions
- Error handling & empty states
- App icon & splash
- Google Play release

### Step 7.1 — Animations
- Hero transitions: client card → detail screen
- Staggered list animations on screen load
- Shimmer loading skeletons
- SnackBar confirmations for all actions
- Lottie animation for empty states
- **v2: Timer widget pulse animation when running** (AnimationController + ScaleTransition)

### Step 7.2 — Error Handling

```dart
// All providers use AsyncValue pattern:
// data:    → show UI
// error:   → AppErrorWidget with retry button
// loading: → shimmer skeleton
```

### Step 7.3 — Release Checklist

```
□ Set applicationId in build.gradle
□ Set versionName + versionCode
□ Generate signed APK / AAB
□ Minify: flutter build appbundle --release
□ Enable ProGuard rules for Supabase
□ Test on Android 8, 10, 12, 14
□ Screenshot all main screens including Time Tracking (v2)
□ Write Google Play store listing
□ Set up Crashlytics (Firebase)
□ Submit: Internal Testing → Closed Testing → Production
```

---

## Phase 8 — Time Tracking, Expenses & Recurring Invoices (Weeks 13–15)

### ✅ Goals
- Live timer with start/stop per project
- Manual time entry
- Convert unbilled hours → invoice line items
- Expense logging with receipt photos
- Billable expenses → invoice line items
- Recurring invoice templates with auto-generation
- Profit view on dashboard

---

### Step 8.1 — Time Tracking

#### Entity

```dart
@freezed
class TimeEntry with _$TimeEntry {
  const factory TimeEntry({
    required String id,
    required String userId,
    required String projectId,
    required String clientId,
    String? description,
    required DateTime startedAt,
    DateTime? endedAt,
    int? durationSeconds,       // null if timer running
    required double hourlyRate,
    required bool isBillable,
    required bool isBilled,
    String? invoiceId,
    required DateTime createdAt,
  }) = _TimeEntry;

  // Helpers
  bool get isRunning => endedAt == null;
  Duration get duration => endedAt != null
    ? endedAt!.difference(startedAt)
    : DateTime.now().difference(startedAt);
  double get billableAmount =>
    (duration.inSeconds / 3600) * hourlyRate;
}
```

#### Timer Widget

```dart
// TimerWidget — shows live elapsed time
// Uses Timer.periodic(Duration(seconds: 1), ...) to rebuild
// Displays: HH:MM:SS format
// Green pulsing dot indicator when running
// Stop button → calls repo.stopTimer(entry.id, endedAt: DateTime.now())

// Only ONE timer can run at a time per user.
// The unique index on time_entries (user_id) WHERE ended_at IS NULL
// enforces this at DB level. In Flutter, check before starting.
```

#### Time Tracking Screen

- **Top:** Active timer card (if running) with project name + live clock + Stop button
- **Body:** List of time entries grouped by date
- **Filter:** All | Billable | Unbilled | This Week | This Month
- **FAB:** Start Timer (select project → starts entry) or Log Manual Entry
- **Summary bar:** Total hours this month | Billable amount | Unbilled amount

#### Repository Key Methods

```dart
abstract class TimeEntryRepository {
  Future<TimeEntry?> getActiveTimer(String userId);
  Future<TimeEntry> startTimer({
    required String projectId,
    required String clientId,
    String? description,
    required double hourlyRate,
  });
  Future<TimeEntry> stopTimer(String entryId);
  Future<TimeEntry> createManualEntry(TimeEntry entry);
  Future<List<TimeEntry>> getUnbilledForClient(String clientId);
  Future<List<TimeEntry>> getUnbilledForProject(String projectId);
  Future<void> markAsBilled(List<String> entryIds, String invoiceId);
  Stream<List<TimeEntry>> watchEntriesForProject(String projectId);
}
```

#### Hourly Rate Resolution

```dart
// Priority: entry.hourly_rate > client.default_hourly_rate > profile.default_hourly_rate
double resolveHourlyRate(Client client, Profile profile) {
  if (client.defaultHourlyRate > 0) return client.defaultHourlyRate;
  if (profile.defaultHourlyRate > 0) return profile.defaultHourlyRate;
  return 0;
}
```

---

### Step 8.2 — Expenses

#### Entity

```dart
@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String userId,
    String? projectId,
    String? clientId,
    required ExpenseCategory category,
    required String description,
    required double amount,
    required String currency,
    required DateTime date,
    String? receiptUrl,
    required bool isBillable,
    required bool isBilled,
    String? invoiceId,
    String? notes,
    required DateTime createdAt,
  }) = _Expense;
}

enum ExpenseCategory {
  software, hardware, travel, accommodation,
  meals, marketing, freelancer, office, other;

  String get label => name[0].toUpperCase() + name.substring(1);
  Color get color => switch (this) {
    ExpenseCategory.software  => AppColors.expenseSoftware,
    ExpenseCategory.travel    => AppColors.expenseTravel,
    ExpenseCategory.hardware  => AppColors.expenseHardware,
    _                         => AppColors.expenseOther,
  };
}
```

#### Add Expense Screen

- Category picker (icon grid)
- Description text field
- Amount + currency
- Date picker (defaults today)
- Project/Client linkage (optional dropdowns)
- Is Billable toggle
- Receipt photo: tap to open image_picker → upload to `receipts/{user_id}/{expense_id}.jpg`
- Notes text field

#### Expenses Screen

- **Top:** This month total + pie chart mini (by category)
- **Filter tabs:** All | Billable | Unbilled | By Category
- **List:** Grouped by month, shows category icon + description + amount
- Swipe to delete with undo SnackBar

#### Expense Breakdown Chart (Pro only)

```dart
// fl_chart PieChart
// Each slice = expense category
// Center label: total amount
// Legend below chart
// Tap slice → filter list to that category
```

---

### Step 8.3 — Recurring Invoices

#### Entity

```dart
@freezed
class RecurringInvoice with _$RecurringInvoice {
  const factory RecurringInvoice({
    required String id,
    required String userId,
    required String clientId,
    String? projectId,
    required RecurrenceFrequency frequency,
    required DateTime nextIssueDate,
    required int dueDays,
    required bool isActive,
    required List<InvoiceLineItem> lineItems,
    required double taxPercent,
    required double discountPercent,
    required String currency,
    String? notes,
    String? paymentTerms,
    required int timesGenerated,
    DateTime? lastGeneratedAt,
    required DateTime createdAt,
  }) = _RecurringInvoice;
}

enum RecurrenceFrequency { weekly, biweekly, monthly, quarterly, yearly }
```

#### Create Recurring Screen

- Same form as Create Invoice but with:
  - Frequency picker (Weekly / Bi-weekly / Monthly / Quarterly / Yearly)
  - First issue date (date picker)
  - Due in X days field
- No status field (always generates as 'draft' → user reviews before sending)

#### Recurring Invoices Screen

- List of active recurring templates
- Each tile shows: client, frequency badge, next issue date, line item count
- Toggle active/inactive
- Tap → edit template

#### Auto-Generation Logic (workmanager)

```dart
// Runs on app launch (and via periodic background task)
Future<void> checkAndGenerateRecurringInvoices() async {
  final due = await recurringRepo.getDueInvoices(userId);
  for (final template in due) {
    // 1. Generate invoice number
    final number = await invoiceRepo.getNextNumber(userId);
    // 2. Create invoice record
    final invoice = await invoiceRepo.create(Invoice(
      clientId: template.clientId,
      projectId: template.projectId,
      recurringId: template.id,
      invoiceNumber: number,
      status: InvoiceStatus.draft,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(Duration(days: template.dueDays)),
      lineItems: template.lineItems,
      taxPercent: template.taxPercent,
      discountPercent: template.discountPercent,
    ));
    // 3. Advance schedule
    await recurringRepo.advanceSchedule(template.id);
    // 4. Show local notification
    await NotificationService.showRecurringGenerated(
      clientName: template.clientName,
      invoiceNumber: number,
      invoiceId: invoice.id,
    );
  }
}
```

---

### Step 8.4 — Invoice Import Flow (v2 enhancement)

**In create_invoice_screen.dart — new "Import" button in line items section:**

```dart
// Button: "+ Import Time Entries"
// Opens bottom sheet:
//   - Shows unbilled time entries for selected client
//   - Each row: project name | description | duration | amount
//   - Checkbox multi-select
//   - "Add X entries" confirmation button
// On confirm:
//   - Adds each as InvoiceLineItem
//   - Quantity = hours (decimal), unit_price = hourly_rate
//   - Marks entries as is_billed = true after invoice is saved

// Button: "+ Import Expenses"  
// Same flow for billable unbilled expenses
// Quantity = 1, unit_price = expense.amount
```

---

### Step 8.5 — Pro Gates for Phase 8 Features

```dart
// Time tracking: allow free users up to 10 entries/month
// Gate check on startTimer() and createManualEntry():
final count = await timeEntryRepo.getCountThisMonth(userId);
if (!isPro && count >= 10) showPaywall();

// Expenses: same limit — 10/month for free
final expCount = await expenseRepo.getCountThisMonth(userId);
if (!isPro && expCount >= 10) showPaywall();

// Recurring invoices: Pro only
if (!isPro) showPaywall();

// Expense breakdown chart: Pro only
// Show blurred chart with "Unlock with Pro" overlay
```

---

### Step 8.6 — Settings Screen (v2 additions)

```dart
// New settings sections:

// Time Tracking
// - Default hourly rate (saved to profile.default_hourly_rate)
// - Round timer to nearest: None / 5 min / 15 min / 30 min

// Invoicing
// - Default payment terms (saved to profile.default_payment_terms)
// - Tax ID / VAT number (saved to profile.tax_id)
//   → Auto-fills on all generated invoices
```

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Backend
  supabase_flutter: ^2.5.0

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.2.0

  # Models
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

  # Local Database
  drift: ^2.18.0
  drift_flutter: ^0.2.1
  sqlite3_flutter_libs: ^0.5.24

  # Auth
  google_sign_in: ^6.2.1

  # PDF
  pdf: ^3.11.1
  printing: ^5.13.1

  # Charts
  fl_chart: ^0.68.0

  # Notifications
  flutter_local_notifications: ^17.2.2

  # Background tasks (recurring invoices + notification checks)
  workmanager: ^0.5.2

  # Monetization
  purchases_flutter: ^7.5.0  # RevenueCat

  # UI
  shimmer: ^3.0.0
  lottie: ^3.1.2

  # Utilities
  intl: ^0.19.0
  share_plus: ^9.0.0
  path_provider: ^2.1.3
  shared_preferences: ^2.3.2
  image_picker: ^1.1.2        # receipt photos (v2)
  flutter_dotenv: ^5.1.0
  envied: ^0.5.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.11
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.2
  drift_dev: ^2.18.0
  envied_generator: ^0.5.4
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.4.0
```

> **No new packages required for v2.** `image_picker` was already in v1 for avatars and is reused for receipt photos. `fl_chart` handles the new expense pie chart. `workmanager` handles recurring invoice checks.

---

## Environment Variables

```bash
# .env (never commit this)
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
REVENUECAT_API_KEY=your_revenuecat_key_here
```

---

## 📅 Timeline Summary

| Phase | Focus | Duration |
|---|---|---|
| Phase 1 | Foundation, Auth, Theme, Nav | Weeks 1–2 |
| Phase 2 | Clients, Projects, Payments CRUD | Weeks 3–4 |
| Phase 3 | Invoices + PDF Generation | Weeks 5–6 |
| Phase 4 | Dashboard + Charts | Week 7 |
| Phase 5 | Notifications + Reminders | Week 8 |
| Phase 6 | Monetization (RevenueCat) | Weeks 9–10 |
| Phase 7 | Polish + Google Play Release | Weeks 11–12 |
| **Phase 8** | **Time Tracking + Expenses + Recurring Invoices** | **Weeks 13–15** |

**Total: ~15 weeks to full v2 feature set** 🚀

---

## 📊 v2 Data Model Summary

| Table | New in v2 | Purpose |
|---|---|---|
| `profiles` | `tax_id`, `default_hourly_rate`, `default_payment_terms` | Invoice compliance + time tracking defaults |
| `clients` | `default_hourly_rate`, `tags` | Per-client billing rate + segmentation |
| `milestones` | index on `due_date` | Milestone notification support |
| `time_entries` | ✅ New table | Timer + manual time logging |
| `expenses` | ✅ New table | Cost tracking per project/client |
| `recurring_invoices` | ✅ New table | Auto-generating invoice templates |
| `notification_type` | `milestone_due`, `recurring_invoice_generated`, `time_entry_reminder` | New notification triggers |
| `activity_type` | `time_logged`, `expense_logged`, `recurring_invoice_created` | Activity feed entries |
