# 📱 Freelance Client Manager — Complete Build Roadmap
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
13. [Dependencies](#dependencies)
14. [Environment Variables](#environment-variables)

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
│   │   ├── app_theme.dart            # ThemeData light & dark
│   │   ├── app_colors.dart           # All color constants
│   │   ├── app_text_styles.dart
│   │   └── theme_notifier.dart       # Riverpod theme toggle provider
│   ├── router/
│   │   └── app_router.dart           # go_router config
│   ├── supabase/
│   │   └── supabase_client.dart      # Supabase init
│   ├── database/
│   │   ├── app_database.dart         # Drift DB definition
│   │   └── app_database.g.dart
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   ├── date_formatter.dart
│   │   └── pdf_generator.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_card.dart
│       ├── status_badge.dart
│       └── empty_state.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository.dart
│   │   ├── domain/
│   │   │   └── user_entity.dart
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       └── splash_screen.dart
│   │
│   ├── dashboard/
│   │   ├── data/
│   │   │   └── dashboard_repository.dart
│   │   ├── domain/
│   │   │   └── dashboard_stats.dart
│   │   └── presentation/
│   │       ├── dashboard_screen.dart
│   │       └── widgets/
│   │           ├── stats_card.dart
│   │           ├── earnings_chart.dart
│   │           └── recent_activity.dart
│   │
│   ├── clients/
│   │   ├── data/
│   │   │   └── client_repository.dart
│   │   ├── domain/
│   │   │   └── client_entity.dart
│   │   └── presentation/
│   │       ├── clients_screen.dart
│   │       ├── client_detail_screen.dart
│   │       ├── add_client_screen.dart
│   │       └── widgets/
│   │           └── client_card.dart
│   │
│   ├── projects/
│   │   ├── data/
│   │   │   └── project_repository.dart
│   │   ├── domain/
│   │   │   └── project_entity.dart
│   │   └── presentation/
│   │       ├── projects_screen.dart
│   │       ├── project_detail_screen.dart
│   │       ├── add_project_screen.dart
│   │       └── widgets/
│   │           ├── project_card.dart
│   │           └── milestone_tile.dart
│   │
│   ├── payments/
│   │   ├── data/
│   │   │   └── payment_repository.dart
│   │   ├── domain/
│   │   │   └── payment_entity.dart
│   │   └── presentation/
│   │       ├── payments_screen.dart
│   │       ├── add_payment_screen.dart
│   │       └── widgets/
│   │           └── payment_tile.dart
│   │
│   ├── invoices/
│   │   ├── data/
│   │   │   └── invoice_repository.dart
│   │   ├── domain/
│   │   │   └── invoice_entity.dart
│   │   └── presentation/
│   │       ├── invoices_screen.dart
│   │       ├── invoice_detail_screen.dart
│   │       ├── create_invoice_screen.dart
│   │       └── widgets/
│   │           └── invoice_card.dart
│   │
│   └── settings/
│       └── presentation/
│           ├── settings_screen.dart
│           └── widgets/
│               └── theme_toggle.dart
│
supabase/
└── migrations/
    ├── 001_initial_schema.sql
    ├── 002_rls_policies.sql
    └── 003_functions.sql
```

---

## 4. Theme System

### Color Palette

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // --- PRIMARY BLUE PALETTE ---
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

  // --- LIGHT THEME ---
  static const lightBackground   = Color(0xFFF8FAFC);
  static const lightSurface      = Color(0xFFFFFFFF);
  static const lightSurfaceAlt   = Color(0xFFF1F5F9);
  static const lightBorder       = Color(0xFFE2E8F0);
  static const lightTextPrimary  = Color(0xFF0F172A);
  static const lightTextSecondary= Color(0xFF64748B);

  // --- DARK THEME ---
  static const darkBackground    = Color(0xFF0F172A);
  static const darkSurface       = Color(0xFF1E293B);
  static const darkSurfaceAlt    = Color(0xFF334155);
  static const darkBorder        = Color(0xFF475569);
  static const darkTextPrimary   = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);

  // --- SEMANTIC COLORS ---
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error   = Color(0xFFEF4444);
  static const info    = Color(0xFF3B82F6);

  // --- STATUS COLORS ---
  static const statusPaid     = Color(0xFF22C55E);
  static const statusUnpaid   = Color(0xFFF59E0B);
  static const statusOverdue  = Color(0xFFEF4444);
  static const statusPartial  = Color(0xFF8B5CF6);
  static const statusActive   = Color(0xFF3B82F6);
  static const statusDone     = Color(0xFF6B7280);
  static const statusOnHold   = Color(0xFFF97316);
}
```

### ThemeData Configuration

```dart
// lib/core/theme/app_theme.dart

class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary500,
      brightness: Brightness.light,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardTheme: CardTheme(
      color: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.lightBorder),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    // ... full config
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary500,
      brightness: Brightness.dark,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardTheme: CardTheme(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.darkBorder),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    // ... full config
  );
}
```

### Theme Toggle Provider

```dart
// lib/core/theme/theme_notifier.dart

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString('theme_mode') ?? 'system';
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark'  => ThemeMode.dark,
      _       => ThemeMode.system,
    };
  }

  void setTheme(ThemeMode mode) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('theme_mode', mode.name);
    state = mode;
  }
}
```

---

## 5. Supabase Setup

### Step-by-step

1. Go to [supabase.com](https://supabase.com) → Create new project
2. Name it `freelanceflow`, choose your region
3. Go to **SQL Editor** → run `001_initial_schema.sql`
4. Run `002_rls_policies.sql`
5. Run `003_functions.sql`
6. Go to **Authentication** → Providers → Enable **Google**
7. Go to **Storage** → Create bucket: `invoices` (private)
8. Copy your `Project URL` and `anon key` → add to `.env`

### Flutter Init

```dart
// lib/core/supabase/supabase_client.dart

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
}
```

---

## Phase 1 — Foundation (Weeks 1–2)

### ✅ Goals
- Project setup, architecture scaffold
- Supabase auth (Google + email)
- Theme system (dark/light toggle)
- Navigation shell (bottom nav)

### Step 1.1 — Project Init

```bash
flutter create freelanceflow --org com.yourname
cd freelanceflow

# Add all dependencies (see Dependencies section)
flutter pub add supabase_flutter riverpod flutter_riverpod \
  riverpod_annotation go_router freezed drift drift_flutter \
  google_sign_in flutter_dotenv envied pdf share_plus \
  fl_chart intl path_provider flutter_local_notifications \
  purchases_flutter image_picker
  
flutter pub add --dev build_runner freezed_annotation \
  riverpod_generator drift_dev
```

### Step 1.2 — Auth Flow

```
Splash Screen
    ↓ check session
    ├── Logged in  → Dashboard
    └── Logged out → Login Screen
                        ├── Google Sign-In
                        └── Email + Password
```

**Login screen features:**
- Google Sign-In button (primary)
- Email/password fallback
- Animated logo with blue gradient
- Respects system theme on first launch

### Step 1.3 — Navigation Shell

```dart
// 5 bottom nav destinations:
// 0: Dashboard  (Icons.dashboard_rounded)
// 1: Clients    (Icons.people_rounded)
// 2: Projects   (Icons.folder_rounded)
// 3: Payments   (Icons.payments_rounded)
// 4: Invoices   (Icons.receipt_long_rounded)
// FAB: Quick Add (context-aware)
```

### Step 1.4 — Theme Toggle in Settings
- Toggle in Settings screen: Light / Dark / System
- Persisted via SharedPreferences
- Applied app-wide via ThemeNotifier

### Step 1.5 — Offline-first Setup
- Drift local DB mirrors Supabase tables
- On app open: sync changed records
- All writes go to local first, then queue sync
- Show "offline" indicator banner when no network

---

## Phase 2 — Core Features (Weeks 3–4)

### ✅ Goals
- Full CRUD: Clients, Projects, Milestones
- Payment logging
- Syncs to Supabase

### Step 2.1 — Clients

**Client Model (Freezed):**
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
    String? currency,      // default 'USD'
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Client;
}
```

**Client Screen features:**
- Search bar with debounce
- Sort by: Name / Recent / Most Revenue
- Filter by: Country / Currency
- Swipe-to-delete with confirmation
- Tap to open Client Detail

**Client Detail Screen:**
- Header: avatar initials + name + country flag emoji
- Tabs: Projects | Payments | Invoices
- Total earned from client (sum of paid payments)

### Step 2.2 — Projects

**Project Status Enum:**
```dart
enum ProjectStatus { inProgress, completed, onHold, cancelled }
```

**Project Screen features:**
- Filter tabs: All | Active | Done | On Hold
- Card shows: client name, deadline, budget, status badge
- Progress bar (milestones completed / total)
- Overdue deadline shown in red

**Milestone support:**
- Add sub-tasks per project
- Toggle complete with checkbox
- Completion % drives project progress bar

### Step 2.3 — Payment Tracker

**Payment methods:**
- Bank Transfer, PayPal, Wise, Crypto, Cash, Other

**Payment Screen features:**
- Filter: All | Paid | Unpaid | Overdue | Partial
- Monthly total at top
- Grouped by month with section headers
- Quick-add FAB: select client + project → log payment

---

## Phase 3 — Invoices & PDF (Weeks 5–6)

### ✅ Goals
- Create invoices from project data
- Professional PDF generation
- Export & share (WhatsApp, Gmail, etc.)
- Upload PDF to Supabase Storage

### Step 3.1 — Invoice Builder

**Invoice fields:**
- Invoice # (auto-increment: INV-0001)
- Issue date + due date
- Bill To: client info (auto-filled)
- Line items: description, qty, unit price
- Subtotal → Tax (%) → Discount (%) → **Total**
- Notes / Payment terms
- Status: Draft | Sent | Paid | Overdue

### Step 3.2 — PDF Generation

```dart
// lib/core/utils/pdf_generator.dart
// Uses 'pdf' package + 'printing' for share

Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
  final pdf = pw.Document();
  final blue = PdfColor.fromHex('#2563EB');
  
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (context) => pw.Column(
      children: [
        // Header: Logo + "INVOICE" + brand blue bar
        // Bill To / Bill From columns
        // Line items table
        // Subtotal / Tax / Total section
        // Notes + payment terms
        // Footer: thank you message
      ],
    ),
  ));
  
  return pdf.save();
}
```

### Step 3.3 — Share Flow

```
Generate PDF
    ↓
Save to temp directory
    ↓
Upload to Supabase Storage (invoices/{user_id}/{invoice_id}.pdf)
    ↓
Share via share_plus (WhatsApp / Gmail / Drive / etc.)
```

---

## Phase 4 — Dashboard & Charts (Week 7)

### ✅ Goals
- Financial overview at a glance
- Earnings chart (monthly)
- Key stats cards
- Recent activity feed

### Step 4.1 — Stats Cards (top of dashboard)

| Card | Value |
|---|---|
| 💰 This Month | Sum of paid payments this month |
| ⏳ Unpaid | Total outstanding amount |
| 🔴 Overdue | Count + amount overdue |
| 📁 Active Projects | Count of in-progress projects |

### Step 4.2 — Earnings Chart

```dart
// fl_chart — BarChart
// X-axis: last 6 months (abbreviated: Jan, Feb...)
// Y-axis: revenue in user's currency
// Bar color: primary500 for current month, primary300 for past
// Tap bar → show exact amount in tooltip
```

### Step 4.3 — Recent Activity Feed

- Last 10 events across all features
- Types: Payment received, Invoice sent, Project completed, Client added
- Each item has icon + color + time ago text

### Step 4.4 — Currency Support

```dart
// Settings: user picks their base currency
// Supported: USD, EUR, GBP, KHR, THB, SGD, AUD, CAD
// All amounts stored in base currency
// Formatted with intl package: NumberFormat.currency(...)
```

---

## Phase 5 — Notifications & Reminders (Week 8)

### ✅ Goals
- Local notifications for overdue payments
- Deadline warnings for projects
- Follow-up nudges for unpaid invoices

### Step 5.1 — Notification Types

| Trigger | Message | When |
|---|---|---|
| Payment overdue | "Client X owes $500 — overdue by 3 days" | Daily at 9am if overdue |
| Project deadline | "Project Y is due tomorrow" | 24h before deadline |
| Invoice unpaid | "Invoice INV-0023 unpaid for 14 days" | Every 7 days after due date |
| Weekly summary | "This week: $1,200 earned, 2 invoices pending" | Every Monday 8am |

### Step 5.2 — Implementation

```dart
// flutter_local_notifications + workmanager for background tasks

// Schedule on app launch:
await NotificationService.scheduleOverdueCheck();
await NotificationService.scheduleDeadlineCheck();
await NotificationService.scheduleWeeklySummary();

// AndroidManifest.xml additions needed:
// - RECEIVE_BOOT_COMPLETED permission
// - SCHEDULE_EXACT_ALARM permission (Android 12+)
```

### Step 5.3 — In-App Notification Bell

- Bell icon in AppBar with unread badge
- Dropdown sheet with all recent alerts
- Tap alert → navigate to relevant screen
- Mark all as read

---

## Phase 6 — Monetization (Weeks 9–10)

### ✅ Goals
- Freemium gates implemented
- Google Play Billing integration
- Paywall screen
- Pro badge in UI

### Step 6.1 — Free vs Pro Limits

| Feature | Free | Pro |
|---|---|---|
| Clients | Max 3 | Unlimited |
| Invoices/month | Max 5 | Unlimited |
| PDF export | ✅ | ✅ |
| Cloud sync | ❌ | ✅ |
| Custom branding on invoices | ❌ | ✅ |
| Reminders & notifications | ❌ | ✅ |
| Dashboard charts | ❌ | ✅ |
| Priority support | ❌ | ✅ |

### Step 6.2 — RevenueCat Setup

```dart
// purchases_flutter (RevenueCat SDK)

await Purchases.configure(
  PurchasesConfiguration(Env.revenuecatApiKey),
);

// Products to create in Google Play Console:
// - freelanceflow_pro_monthly  → $4.99/month
// - freelanceflow_pro_yearly   → $39.99/year
// - freelanceflow_pro_lifetime → $29.99 one-time
```

### Step 6.3 — Paywall Screen

- Triggered when free user hits limit
- Shows feature comparison table
- 3 plan options: Monthly / Yearly (best value badge) / Lifetime
- "Start 7-day free trial" for monthly
- Restore purchases button

### Step 6.4 — Pro Status Provider

```dart
@riverpod
Future<bool> isProUser(IsProUserRef ref) async {
  final info = await Purchases.getCustomerInfo();
  return info.entitlements.active.containsKey('pro');
}

// Gate usage:
final isPro = await ref.read(isProUserProvider.future);
if (!isPro && clientCount >= 3) {
  // Show paywall
}
```

---

## Phase 7 — Polish & Release (Weeks 11–12)

### ✅ Goals
- UI animations & micro-interactions
- Error handling & empty states
- App icon & splash screen
- Google Play release

### Step 7.1 — Animations

- Hero transitions: client card → detail screen
- Staggered list animations on screen load
- Shimmer loading skeletons (shimmer package)
- SnackBar confirmations for all actions
- Lottie animation for empty states

### Step 7.2 — Error Handling

```dart
// Global error handling via Riverpod AsyncValue
// Every provider uses:
//   data:  → show UI
//   error: → show AppErrorWidget with retry button
//   loading: → show shimmer skeleton
```

### Step 7.3 — App Icon & Splash

- App icon: briefcase or graph icon in primary blue
- Use `flutter_launcher_icons` package
- Splash: white/dark bg + centered logo + blue accent
- Use `flutter_native_splash` package

### Step 7.4 — Release Checklist

```
□ Set applicationId in build.gradle
□ Set versionName + versionCode
□ Generate signed APK / AAB
□ Minify: flutter build appbundle --release
□ Enable ProGuard rules for Supabase
□ Test on Android 8, 10, 12, 14
□ Screenshot all 5 bottom nav screens
□ Write Google Play store listing
□ Set up Crashlytics (Firebase)
□ Submit to Internal Testing → Closed Testing → Production
```

---

## Dependencies

```yaml
# pubspec.yaml

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

  # Background tasks
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
  image_picker: ^1.1.2
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

---

## Environment Variables

```bash
# .env (never commit this)

SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
REVENUECAT_API_KEY=your_revenuecat_key_here
```

```dart
// lib/core/env.dart (generated by envied)
@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Env.supabaseAnonKey;

  @EnviedField(varName: 'REVENUECAT_API_KEY', obfuscate: true)
  static final String revenuecatApiKey = _Env.revenuecatApiKey;
}
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

**Total: ~12 weeks to production-ready app** 🚀
