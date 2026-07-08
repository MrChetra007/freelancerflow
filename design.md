---
version: 2.0.0
name: FreelanceFlow-Design
description: >-
  A Material 3 business management app for freelancers — clients, projects,
  invoices, expenses, and time tracking. Flat, card-based UI with a single
  blue accent. Light and dark modes. No gradients (except premium upsell),
  no shadows on cards.

colors:
  primary-50: "#EFF6FF"
  primary-100: "#DBEAFE"
  primary-200: "#BFDBFE"
  primary-300: "#93C5FD"
  primary-400: "#60A5FA"
  primary-500: "#3B82F6"
  primary-600: "#2563EB"
  primary-700: "#1D4ED8"
  primary-800: "#1E40AF"
  primary-900: "#1E3A8A"

  light-background: "#F8FAFC"
  light-surface: "#FFFFFF"
  light-surface-alt: "#F1F5F9"
  light-border: "#E2E8F0"
  light-text-primary: "#0F172A"
  light-text-secondary: "#64748B"

  dark-background: "#0F172A"
  dark-surface: "#1E293B"
  dark-surface-alt: "#334155"
  dark-border: "#475569"
  dark-text-primary: "#F8FAFC"
  dark-text-secondary: "#94A3B8"

  success: "#22C55E"
  warning: "#F59E0B"
  error: "#EF4444"
  info: "#3B82F6"

  status-paid: "#22C55E"
  status-unpaid: "#F59E0B"
  status-overdue: "#EF4444"
  status-partial: "#8B5CF6"
  status-active: "#3B82F6"
  status-done: "#6B7280"
  status-on-hold: "#F97316"

  expense-software: "#6366F1"
  expense-travel: "#F59E0B"
  expense-hardware: "#3B82F6"
  expense-other: "#94A3B8"

  timer-running: "#22C55E"
  timer-stopped: "#64748B"

  premium-gradient-start: "#D97706"
  premium-gradient-end: "#92400E"

typography:
  # Uses Material 3 default system font (Roboto on Android, SF Pro on iOS)
  # No custom fonts are bundled. We rely on the platform's default typeface.
  headline-large:
    fontSize: 32px
    fontWeight: 700
  headline-medium:
    fontSize: 28px
    fontWeight: 700
  headline-small:
    fontSize: 24px
    fontWeight: 600
  title-large:
    fontSize: 22px
    fontWeight: 600
  title-medium:
    fontSize: 16px
    fontWeight: 600
  title-small:
    fontSize: 14px
    fontWeight: 600
  body-large:
    fontSize: 16px
    fontWeight: 400
  body-medium:
    fontSize: 14px
    fontWeight: 400
  body-small:
    fontSize: 12px
    fontWeight: 400
  label-large:
    fontSize: 14px
    fontWeight: 500
  label-medium:
    fontSize: 12px
    fontWeight: 500
  label-small:
    fontSize: 11px
    fontWeight: 500

shape:
  card: 12px
  button: 12px
  input: 12px
  chip: 8px
  badge: 20px
  sheet-top: 24px
  fab: 16px
  avatar: circle

spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 48px

components:
  card:
    backgroundColor: "{light-surface}"
    borderRadius: "{shape.card}"
    elevation: 0
    border: 1px solid "{light-border}"
    padding: 16px

  card-dark:
    backgroundColor: "{dark-surface}"
    borderRadius: "{shape.card}"
    elevation: 0
    border: 1px solid "{dark-border}"
    padding: 16px

  button-primary:
    backgroundColor: "{primary-500}"
    textColor: "#FFFFFF"
    borderRadius: "{shape.button}"
    padding: 16px 24px
    elevation: 0

  button-primary-dark:
    backgroundColor: "{primary-500}"
    textColor: "#FFFFFF"
    borderRadius: "{shape.button}"
    padding: 16px 24px

  button-outlined:
    backgroundColor: transparent
    textColor: "{light-text-primary}"
    borderRadius: "{shape.button}"
    border: 1px solid "{light-border}"
    padding: 16px 24px

  button-text:
    textColor: "{primary-500}"

  input:
    backgroundColor: "{light-surface-alt}"
    borderRadius: "{shape.input}"
    border: 1px solid "{light-border}"
    padding: 16px
    icon: leading icon, 20px

  input-dark:
    backgroundColor: "{dark-surface-alt}"
    borderRadius: "{shape.input}"
    border: 1px solid "{dark-border}"
    padding: 16px

  app-bar:
    backgroundColor: "{light-surface}"
    foregroundColor: "{light-text-primary}"
    elevation: 0
    centerTitle: false

  app-bar-dark:
    backgroundColor: "{dark-background}"
    foregroundColor: "{dark-text-primary}"
    elevation: 0

  bottom-nav:
    backgroundColor: "{light-surface}"
    selectedItemColor: "{primary-500}"
    unselectedItemColor: "{light-text-secondary}"
    type: fixed
    elevation: 0

  bottom-nav-dark:
    backgroundColor: "{dark-surface}"
    selectedItemColor: "{primary-400}"
    unselectedItemColor: "{dark-text-secondary}"

  stat-card:
    backgroundColor: "{light-surface}"
    borderRadius: "{shape.card}"
    border: 1px solid "{light-border}"
    padding: 16px
    iconBackground: color.at.alpha-0.1
    iconSize: 20px

  search-input:
    backgroundColor: "{light-surface-alt}"
    borderRadius: "{shape.input}"
    border: 1px solid "{light-border}"
    padding: 16px
    prefixIcon: search icon

  chip:
    borderRadius: "{shape.chip}"
    selectedColor: "{primary-500}"

  fab:
    backgroundColor: "{primary-500}"
    foregroundColor: "#FFFFFF"
    borderRadius: "{shape.fab}"
    elevation: 0

  divider:
    color: "{light-border}"
    thickness: 1px

  divider-dark:
    color: "{dark-border}"
    thickness: 1px

  progress-bar:
    backgroundColor: "{primary-500}.with.alpha-0.1"
    valueColor: "{primary-500}"

  error-display:
    icon: Icons.error_outline, 48px
    iconColor: "{error}"
    retryButton: button-primary

  empty-state:
    icon: 64px
    iconColor: "{light-text-secondary}"
    title: title-large
    subtitle: body-medium in "{light-text-secondary}"

  pro-badge:
    backgroundColor: amber gradient
    borderRadius: 20px
    padding: 6px 12px
    textColor: "#FFFFFF"
    fontSize: 12px
    fontWeight: 700

  pro-prompt-sheet:
    backgroundColor: "{light-surface}"
    borderRadius: 24px top
    dragHandle: 40x4px grey.shade300, rounded 2px
    iconContainer: amber gradient circle, 48px
    title: 24px, bold
    subtitle: 14px, grey.shade600
    button: amber.shade700 filled, 16px padding

screen-layouts:
  list-screen:
    - AppBar (title + action icons)
    - Search TextField (optional)
    - Filter chips / status bar (optional)
    - Pull-to-refresh ListView of cards
    - FAB (bottom-right)
    - Empty state when no data

  add-edit-screen:
    - AppBar (close X + Save text button)
    - Form with ListView
    - TextFormField per field with label + prefix icon
    - DropdownButtonFormField for selections
    - Date pickers (InkWell + InputDecorator)
    - Section headers (optional divider)

  detail-screen:
    - SliverAppBar (expanded + pinned)
    - TabBar with 3-4 tabs
    - TabBarView with per-tab content
    - FAB (context-aware per tab)

  form-field-pattern:
    labelText: always present
    prefixIcon: 20px icon
    border: OutlineInputBorder, 12px radius
    filled: true for search, false for form fields
    contentPadding: 16px horizontal, 16px vertical

screen-list:
  splash:
    route: /splash
    description: Loading screen, checks auth session
    layout: centered column
    elements:
      - White container (100x100, 24px radius) with business_center icon
      - "FreelanceFlow" headline (32px, bold)
      - "Client Management" subtitle (16px)
      - CircularProgressIndicator (white)
    background: blue (light) or dark navy (dark)

  landing:
    route: /landing
    description: 4-page onboarding carousel
    layout: page view + bottom controls
    elements:
      - Skip TextButton (top-right)
      - PageView with 4 pages (icon + title + description)
      - Dot indicators (animated width, blue)
      - "Next" / "Sign In" FilledButton
      - "I already have an account" TextButton
    backgroundColor: white or dark navy

  login:
    route: /login
    description: Login/signup with Google OAuth and email/password
    layout: animated gradient background + centered form
    elements:
      - Animated gradient (primary500 ↔ primary700 → black)
      - Floating decorative circles
      - Semi-transparent black overlay
      - App logo icon container
      - "FreelanceFlow" title
      - "Continue with Google" OutlinedButton (white bg, Google SVG icon)
      - "or" divider
      - Email TextField
      - Password TextField (with visibility toggle)
      - Confirm password field (signup mode)
      - "Forgot Password?" button
      - "Sign In" / "Create Account" button
      - Mode toggle TextButton
    Google Sign-In:
      uses Supabase OAuth (not native Google Sign-In SDK)
      redirectTo: com.sozin.freelanceflow://login-callback
      opens external browser

  onboarding:
    route: /onboarding
    description: 3-step profile setup wizard
    layout: AppBar + progress bar + step content + bottom bar
    step-1: Full Name (person icon)
    step-2: Business info (name, email, phone, address)
    step-3: Preferences (hourly rate, currency dropdown, timezone dropdown)
    bottom-bar: "Next" / "Finish Setup" button with shadow

  dashboard:
    route: /dashboard
    description: Business overview with stats and charts
    layout: AppBar + scrollable cards
    elements:
      - Pro badge (amber gradient, conditional)
      - Settings gear icon
      - Time-of-day greeting
      - Stat cards (2-column grid, tappable)
      - Monthly revenue/expenses bar chart (fl_chart, Pro feature)
      - Project status pie chart (fl_chart)
      - Quick action buttons (expenses, time tracking, recurring)
      - Alert banners (overdue projects, unbilled time)
    stat-card:
      colored icon container (10px padding, 8px radius)
      large bold value
      small label

  clients:
    route: /clients
    description: Client list with search and tag filtering
    layout: list-screen
    search: text field at top
    tags: horizontal FilterChip row
    sort: bottom sheet (name, recent)
    items: ClientCard with avatar, name, company, email, tag chips
    empty: people icon + message
    fab: "Add Client"

  add-client:
    route: /clients/add, /clients/:id/edit
    description: Create/edit client profile
    layout: add-edit-screen
    fields: Name*, Email, Phone, Company, Country dropdown, Currency dropdown, Notes
    avatar: CircleAvatar with initials + 8 color picker circles

  client-detail:
    route: /clients/:id
    description: Client overview with 4 tabs
    layout: detail-screen
    tabs: Overview, Projects, Time, Expenses
    header: avatar, name, company, email, tags, rate, currency
    overview: info card + summary stats
    projects: list of project cards
    time: total hours + value + entry list
    expenses: total + expense tiles

  projects:
    route: /projects
    description: Project list with search and status filter
    layout: list-screen
    filter: status (all, in-progress, completed, on-hold)
    items: ProjectCard with title, client, budget, status badge
    fab: "Add Project"

  add-project:
    route: /projects/add, /projects/:id/edit
    description: Create/edit project
    layout: add-edit-screen
    fields: Title*, Description, Client*, Status, Budget + Currency, Start/End dates

  project-detail:
    route: /projects/:id
    description: Project detail with 3 tabs
    layout: detail-screen
    tabs: Details, Time, Expenses
    header: status badge, budget, deadline, title, description
    details: info card + milestones section
    time: summary + entries + start/stop timer buttons
    expenses: summary + expense tiles (Pro feature)

  payments:
    route: /payments
    description: Payment list with monthly total and status filter
    layout: list-screen
    header: monthly total card (blue tint, trending icon)
    filter: status (all, paid, unpaid, overdue, partial)
    items: PaymentTile with client, amount, status, date
    fab: "Add Payment"

  add-payment:
    route: /payments/add, /payments/:id/edit
    description: Create/edit payment
    layout: add-edit-screen
    fields: Amount*, Currency, Client*, Status, Method, Due/Paid dates, Description, Reference, Notes

  invoices:
    route: /invoices
    description: Invoice list with search and status filter
    layout: list-screen
    filter: status (all, draft, sent, paid, overdue)
    items: InvoiceCard with number, client, total, status
    fab: ProGateButton "Create Invoice"

  create-invoice:
    route: /invoices/create, /invoices/:id/edit
    description: Create/edit invoice with line items
    layout: add-edit-screen
    fields: Client*, Issue/Due dates, line items (description, qty, unit price)
    sections: tax%, discount%, notes, payment terms
    totals: subtotal, tax, discount, total
    advanced: import time/expense entries, recurring invoice toggle (Pro)
    line-item-card: description, qty, unit price, total, delete button
    totals-card: blue tinted background

  invoice-detail:
    route: /invoices/:id
    description: Invoice view with status and actions
    layout: AppBar + cards
    elements:
      - Status card (colored dot + total)
      - Bill To card
      - Dates card (issue + due)
      - Line items card
      - Totals card
      - Notes card
    appBar: invoice number + print, share, popup menu (change status)

  expenses:
    route: /expenses
    description: Expense list with category breakdown
    layout: CustomScrollView + slivers
    chart: ExpenseBreakdownChart (Pro feature)
    filter: horizontal category FilterChips
    items: ExpenseTile
    fab: ProGateButton "Add Expense"

  add-expense:
    route: /expenses/add
    description: Create/edit expense
    layout: add-edit-screen
    fields: Category dropdown, Description, Amount$, Client, Project, Date, Billable toggle, Receipt upload, Notes

  time-tracking:
    route: /time-tracking
    description: Time entries with active timer
    layout: CustomScrollView + slivers
    active-timer: TimerWidget (running timer card with stop button)
    filter: horizontal toggle chips (all, billable, unbilled, this-week, this-month)
    entries: grouped by date with date headers
    fab: "Track Time" with bottom sheet (start timer/log manual)

  add-time-entry:
    route: /time-tracking/add
    description: Log time entry
    layout: add-edit-screen
    fields: Project dropdown, Description, Hourly Rate$, Start date/time, End date/time, Billable toggle

  settings:
    route: /settings
    description: App settings
    layout: ListView of sections
    sections:
      - Premium active card (amber gradient, conditional)
      - Appearance (theme picker)
      - Time Tracking (hourly rate, timer rounding)
      - Invoicing (payment terms, tax ID)
      - Features (expenses, time tracking, recurring)
      - Notifications (toggles + tester)
      - Premium (upgrade link)
      - Account (profile)
      - About (version, terms, privacy)
      - Sign Out (red outlined button)

  premium:
    route: /premium
    description: Subscription page
    layout: centered scrollable
    states:
      - not subscribed: upgrade prompt with feature list + subscribe button
      - subscribed: "You're Premium!" with feature cards + plan info
    subscribe: amber gradient button, IAP purchase

  profile:
    route: /profile
    description: User profile with business info
    layout: scrollable card sections
    sections:
      - Avatar (tappable, camera icon overlay, upload to Supabase)
      - Account Information (name, email, member since)
      - Business Information (editable fields)
      - Quick Stats (clients, projects, earnings)
      - Quick Actions (clients, dashboard, settings)
    edit: toggle mode with Save action

  recurring:
    route: /recurring, /recurring/create
    description: Recurring invoice templates
    layout: list-screen
    items: RecurringInvoiceTile with toggle, edit, delete
    form: Client, Frequency, First Issue Date, Due Days, Tax%, Discount%

navigation:
  type: AppBar + BottomNavigationBar (shell route)
  routes:
    /splash: splash
    /landing: landing
    /login: login
    /onboarding: onboarding
    /dashboard: dashboard (shell)
    /clients: clients (shell)
    /projects: projects (shell)
    /payments: payments (shell)
    /invoices: invoices (shell)
    /clients/add: add-client (modal)
    /clients/:id: client-detail (modal)
    /clients/:id/edit: add-client (modal)
    /projects/add: add-project (modal)
    /projects/:id: project-detail (modal)
    /projects/:id/edit: add-project (modal)
    /payments/add: add-payment (modal)
    /invoices/create: create-invoice (modal)
    /invoices/:id: invoice-detail (modal)
    /settings: settings (modal)
    /profile: profile (modal)
    /premium: premium (modal)
    /expenses: expenses (modal)
    /expenses/add: add-expense (modal)
    /time-tracking: time-tracking (modal)
    /time-tracking/add: add-time-entry (modal)
    /recurring: recurring (modal)
    /recurring/create: create-recurring (modal)
  auth-redirect:
    - No session → /splash → /landing
    - Has session + onboarding needed → /onboarding
    - Has session + onboarding complete → /dashboard
    - Non-public route without session → /landing
    - Public route with session → /splash (redirects to dashboard/onboarding)

platform:
  framework: Flutter
  sdk: ^3.11.4
  design-system: Material 3
  state-management: Riverpod
  routing: GoRouter
  database: Supabase (PostgreSQL)
  auth: Supabase Auth (email/password + Google OAuth)
  google-oauth-flow:
    provider: Supabase signInWithOAuth(OAuthProvider.google)
    redirect: custom deep link (com.sozin.freelanceflow://login-callback)
    mobile-handling: app_links package (automatic) via supabase_flutter
    android-intent: scheme="com.sozin.freelanceflow" host="login-callback"
    ios-url-scheme: CFBundleURLTypes → com.sozin.freelanceflow
  charts: fl_chart
  subscriptions: in_app_purchase

design-principles:
  - "Flat, no shadows": Cards and buttons have elevation: 0 everywhere. Content hierarchy comes from color and spacing, not shadows. (Exception: subtle boxShadow on bottom bars, onboarding step bar, and account/container cards.)
  - "Single blue accent": All interactive elements use Primary-500 (#3B82F6). No second brand color exists.
  - "Card-based lists": Every data screen is a vertical list of bordered cards. Cards are rectangular with 12px radius and a thin #E2E8F0 border.
  - "Prefix icons in forms": Every text field has a leading icon for visual scanning.
  - "Consistent 12px radius": Cards, buttons, inputs, stat containers all share 12px border radius. Only chips (8px), FABs (16px), and badge pills (20px) differ.
  - "Material 3 defaults": System font, M3 color scheme from seed color, standard FilledButton, OutlinedButton, TextField widgets.
  - "FAB for creation": Every list screen has a FAB for adding new items. FAB always shows an icon + label text.
  - "SliverAppBar for details": Detail screens use expandable/collapsible headers with pinned tabs.
  - "Premium gating": Revenue chart, expense tracking, receipt upload, invoice PDF, import entries, and recurring invoices are Pro-only features, guarded by ProGate and ProGateButton widgets.
  - "Pull to refresh": All list screens support RefreshIndicator.
  - "Haptic feedback": Light/medium impact on taps and deletes via HapticUtils.

dark-mode:
  - Fully supported via ThemeData.dark + ColorScheme.fromSeed
  - Light: white/slate surfaces → Dark: navy/charcoal surfaces
  - Primary blue remains same in both modes
  - All component tokens have dark counterparts
  - Theme toggled in Settings (system/light/dark), persisted in SharedPreferences
