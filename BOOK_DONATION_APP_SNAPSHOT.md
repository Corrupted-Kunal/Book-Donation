# Book Donation App – Current Implementation Snapshot

---

## 1. FULL PROJECT STRUCTURE

```
Book-Donation/
├── .vscode/
│   └── settings.json
├── bookdonationapp/
│   ├── android/
│   │   ├── app/
│   │   │   ├── build.gradle.kts
│   │   │   ├── google-services.json
│   │   │   └── src/
│   │   │       ├── debug/
│   │   │       ├── main/
│   │   │       │   ├── AndroidManifest.xml
│   │   │       │   ├── kotlin/.../MainActivity.kt
│   │   │       │   └── res/
│   │   │       └── profile/
│   │   ├── build.gradle.kts
│   │   ├── gradle/
│   │   ├── settings.gradle.kts
│   │   └── gradle wrapper files
│   ├── ios/
│   │   ├── Flutter/
│   │   └── Runner/
│   │       ├── AppDelegate.swift
│   │       ├── Info.plist
│   │       ├── Assets.xcassets/
│   │       └── Base.lproj/
│   ├── linux/
│   │   ├── CMakeLists.txt
│   │   └── flutter/
│   ├── web/
│   │   ├── index.html
│   │   └── manifest.json
│   ├── lib/
│   │   ├── main.dart
│   │   ├── firebase_options.dart
│   │   ├── core/
│   │   │   ├── theme/
│   │   │   │   ├── app_colors.dart
│   │   │   │   ├── app_text_styles.dart
│   │   │   │   └── app_theme.dart
│   │   │   ├── utils/
│   │   │   │   └── responsive.dart
│   │   │   └── widgets/
│   │   │       └── responsive_container.dart
│   │   ├── routing/
│   │   │   └── app_router.dart
│   │   └── features/
│   │       ├── auth/
│   │       │   ├── auth_service.dart
│   │       │   ├── auth_provider.dart
│   │       │   └── user_profile_model.dart
│   │       ├── books/
│   │       │   ├── book_model.dart
│   │       │   ├── book_service.dart
│   │       │   ├── book_provider.dart
│   │       │   ├── ebook_model.dart
│   │       │   └── request_book_model.dart
│   │       ├── voice/
│   │       │   ├── voice_assistant_service.dart
│   │       │   └── voice_assistant_provider.dart
│   │       └── screens/
│   │           ├── splash_screen.dart
│   │           ├── onboarding_screen.dart
│   │           ├── login_screen.dart
│   │           ├── signup_screen.dart
│   │           ├── home_screen.dart
│   │           ├── donate_screen.dart
│   │           ├── requests_screen.dart
│   │           ├── ebook_listing_screen.dart
│   │           ├── book_detail_screen.dart
│   │           ├── chat_screen.dart
│   │           ├── profile_screen.dart
│   │           ├── settings_screen.dart
│   │           ├── payment_screen.dart
│   │           ├── qr_screen.dart
│   │           ├── rewards_screen.dart
│   │           ├── eco_tracker_screen.dart
│   │           ├── community_screen.dart
│   │           ├── language_settings_screen.dart
│   │           ├── voice_settings_screen.dart
│   │           ├── location_settings_screen.dart
│   │           ├── set_location_screen.dart
│   │           └── widgets/
│   │               ├── bottom_nav_bar.dart
│   │               ├── floating_action_buttons_group.dart
│   │               ├── page_with_floating_buttons.dart
│   │               ├── voice_assistant_button.dart
│   │               ├── voice_assistant_dialog.dart
│   │               ├── stat_card.dart
│   │               ├── donation_card.dart
│   │               ├── request_card.dart
│   │               ├── quick_action_card.dart
│   │               ├── impact_card.dart
│   │               ├── status_badge.dart
│   │               ├── donation_history_card.dart
│   │               ├── book_request_card.dart
│   │               ├── book_type_toggle.dart
│   │               ├── filter_pills.dart
│   │               ├── ebook_card.dart
│   │               ├── menu_card.dart
│   │               ├── menu_item_row.dart
│   │               ├── profile_header.dart
│   │               ├── profile_avatar.dart
│   │               ├── floating_stats_row.dart
│   │               ├── quick_stats_card.dart
│   │               ├── shortcut_grid.dart
│   │               ├── gamification_card.dart
│   │               ├── logout_button.dart
│   │               ├── radio_card.dart
│   │               ├── upload_button.dart
│   │               └── quick_action_card.dart (referenced)
│   ├── test/
│   │   └── widget_test.dart
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   └── firebase.json
```

**Note:** No `assets/` section in `pubspec.yaml`; no assets directory is defined. The project has `android/`, `ios/`, `linux/`, and `web/` platform folders.

---

## 2. FILE INVENTORY

### Root / app entry

| File | Purpose | Classes | Providers | Services | Models | Public methods |
|------|---------|---------|-----------|----------|--------|----------------|
| `lib/main.dart` | App entry; initializes Firebase and runs app with Riverpod | `MyApp` (ConsumerWidget) | — | — | — | — |

### Firebase config

| File | Purpose | Classes | Providers | Services | Models | Public methods |
|------|---------|---------|-----------|----------|--------|----------------|
| `lib/firebase_options.dart` | FlutterFire-generated Firebase options per platform | `DefaultFirebaseOptions` | — | — | — | `currentPlatform` (static getter) |

### Core – theme

| File | Purpose | Classes | Providers | Services | Models | Public methods |
|------|---------|---------|-----------|----------|--------|----------------|
| `lib/core/theme/app_colors.dart` | Design system colors, shadows, radius | `AppColors`, `AppShadows`, `AppRadius` | — | — | — | Static color/gradient/shadow/radius getters |
| `lib/core/theme/app_text_styles.dart` | Typography (Poppins, Nunito Sans) | — | — | — | — | `AppTextStyles` static text styles |
| `lib/core/theme/app_theme.dart` | Material theme (light) | `AppTheme` | — | — | — | `lightTheme` (static getter) |

### Core – utils

| File | Purpose | Classes | Providers | Services | Models | Public methods |
|------|---------|---------|-----------|----------|--------|----------------|
| `lib/core/utils/responsive.dart` | Breakpoints and responsive helpers | `Responsive` | — | — | — | `width`, `height`, `isMobile`, `isTablet`, `isDesktop`, `padding`, `horizontalPadding`, `verticalPadding`, `fontSizeMultiplier`, `spacing`, `widthPercent`, `heightPercent`, `maxContentWidth`, `gridColumns`, `iconSize`, `buttonHeight`, `cardPadding` |

### Core – widgets

| File | Purpose | Classes | Providers | Services | Models | Public methods |
|------|---------|---------|-----------|----------|--------|----------------|
| `lib/core/widgets/responsive_container.dart` | Centered container with max width | `ResponsiveContainer` (StatelessWidget) | — | — | — | `build` |

### Routing

| File | Purpose | Classes | Providers | Services | Models | Public methods |
|------|---------|---------|-----------|----------|--------|----------------|
| `lib/routing/app_router.dart` | GoRouter config and auth redirect | — | `routerProvider` (Provider&lt;GoRouter&gt;) | — | — | — |

### Auth

| File | Purpose | Classes | Providers | Services | Models | Public methods |
|------|---------|---------|-----------|----------|--------|----------------|
| `lib/features/auth/auth_service.dart` | Firebase Auth + Google Sign-In wrapper | `AuthService` | — | `AuthService` | — | `authStateChanges`, `signInAnonymously`, `signInWithEmail`, `registerWithEmail`, `signOut`, `signInWithGoogle`, `currentUser` getter |
| `lib/features/auth/auth_provider.dart` | Riverpod for auth | — | `authServiceProvider`, `authStateProvider` (StreamProvider&lt;User?&gt;) | — | — | — |
| `lib/features/auth/user_profile_model.dart` | In-memory profile for UI | — | — | — | `UserProfile` | — |

### Books

| File | Purpose | Classes | Providers | Services | Models | Public methods |
|------|---------|---------|-----------|----------|--------|----------------|
| `lib/features/books/book_model.dart` | Firestore book document model | `Book` | — | — | `Book` | `fromDoc`, `toMap` |
| `lib/features/books/book_service.dart` | Firestore books collection + Storage uploads | `BookService` | — | `BookService` | — | `streamBooks`, `addBook` |
| `lib/features/books/book_provider.dart` | Riverpod for books | — | `bookServiceProvider`, `booksStreamProvider` (StreamProvider&lt;List&lt;Book&gt;&gt;) | — | — | — |
| `lib/features/books/ebook_model.dart` | E-book UI model (no Firestore) | — | — | — | `EBook` | — |
| `lib/features/books/request_book_model.dart` | Request/listing book model (no Firestore) | — | — | — | `RequestBook` | — |

### Voice

| File | Purpose | Classes | Providers | Services | Models | Public methods |
|------|---------|---------|-----------|----------|--------|----------------|
| `lib/features/voice/voice_assistant_service.dart` | TTS + STT and command routing | `VoiceAssistantService` | — | `VoiceAssistantService` | — | `initialize`, `speak`, `stopSpeaking`, `startListening`, `stopListening`, `setEnabled`, `setVoiceFeedback`, `voiceCommands` getter, `getRouteFromCommand`, `dispose` |
| `lib/features/voice/voice_assistant_provider.dart` | Riverpod for voice | — | `voiceAssistantServiceProvider`, `voiceSettingsNotifierProvider`, `voiceAssistantEnabledProvider`, `voiceFeedbackEnabledProvider` | — | — | `VoiceSettings.copyWith`, `VoiceSettingsNotifier.setAssistantEnabled`, `setFeedbackEnabled` |

### Screens

| File | Purpose | Classes | Providers | Services | Models | Public methods |
|------|---------|---------|-----------|----------|--------|----------------|
| `lib/features/screens/splash_screen.dart` | Initial screen; checks auth and redirects | `SplashScreen` (ConsumerStatefulWidget) | uses `authStateProvider` | — | — | `_checkAuthAndNavigate` |
| `lib/features/screens/onboarding_screen.dart` | Onboarding carousel; Skip/Next/Get Started | `OnboardingScreen` (StatefulWidget) | — | — | — | — |
| `lib/features/screens/login_screen.dart` | Email login + mock login; link to signup | `LoginScreen`, `GoogleLogoPainter` (CustomPainter) | uses `authServiceProvider` | — | — | `_loginWithEmail` |
| `lib/features/screens/signup_screen.dart` | Email signup with validation | `SignupScreen` (ConsumerStatefulWidget) | uses `authServiceProvider` | — | — | `_handleSignup` |
| `lib/features/screens/home_screen.dart` | Home with stats, recent donations, requests, quick actions, impact | `HomeScreen` (ConsumerStatefulWidget) | uses `authStateProvider` | — | — | `_getUserName`, `_buildHeader`, `_buildRecentDonationsSection`, `_buildNearbyRequestsSection`, `_buildQuickActionsSection`, `_buildImpactSection` |
| `lib/features/screens/donate_screen.dart` | Donate form (physical) + donation history list | `DonateScreen`, `DonationItem` (local) | — | — | `DonationItem` | `_getTimeAgo`, `_pickImage`, `_submitDonation`, `_showToast`, `_showSuccessToast`, multiple `_build*` |
| `lib/features/screens/requests_screen.dart` | Find books: physical/ebook toggle, filters, list | `RequestsScreen` (StatefulWidget) | — | — | — | `_onSearchChanged`, `_buildHeader`, `_buildSearchBar`, `_buildControls`, `_buildBookList` |
| `lib/features/screens/ebook_listing_screen.dart` | E-book list with search; download/buy/preview | `EBookListingScreen` (StatefulWidget) | — | — | — | `_onSearchChanged`, `_handleDownload`, `_handleBuy`, `_handlePreview`, `_buildHeader`, `_buildSearchBar`, `_buildEBookList` |
| `lib/features/screens/book_detail_screen.dart` | Single book detail; request/buy/chat | `BookDetailScreen` (StatelessWidget) | — | — | — | — |
| `lib/features/screens/chat_screen.dart` | Chat placeholder (empty conversations) | `ChatScreen` (StatefulWidget) | — | — | — | — |
| `lib/features/screens/profile_screen.dart` | Profile header, stats, menu, shortcuts, logout | `ProfileScreen` (ConsumerWidget) | uses `authStateProvider`, `authServiceProvider` | — | — | — |
| `lib/features/screens/settings_screen.dart` | Settings menu (language, voice, location, notifications) | `SettingsScreen` (StatelessWidget) | — | — | — | — |
| `lib/features/screens/payment_screen.dart` | Payment summary and Pay button; receives `RequestBook` as extra | `PaymentScreen` (StatelessWidget) | — | — | — | — |
| `lib/features/screens/qr_screen.dart` | Generate / Scan QR tabs; placeholder UI | `QRScreen` (StatefulWidget) | — | — | — | `_buildTabButton`, `_buildGenerateView`, `_buildScanView` |
| `lib/features/screens/rewards_screen.dart` | Points, badges, certificate list (no PDF) | `RewardsScreen` (StatelessWidget) | — | — | — | `_buildBadgeCard`, `_buildCertificateCard` |
| `lib/features/screens/eco_tracker_screen.dart` | Eco impact (trees saved, stats, chart placeholder) | `EcoTrackerScreen` (StatelessWidget) | — | — | — | `_buildStatCard` |
| `lib/features/screens/community_screen.dart` | Community feed (hardcoded activity cards) | `CommunityScreen` (StatelessWidget) | — | — | — | `_buildActivityCard` |
| `lib/features/screens/language_settings_screen.dart` | Language list (English selected) | `LanguageSettingsScreen` (StatelessWidget) | — | — | — | `_buildLanguageOption` |
| `lib/features/screens/voice_settings_screen.dart` | Voice assistant and feedback toggles; command list; test | `VoiceSettingsScreen` (ConsumerStatefulWidget) | uses `voiceSettingsNotifierProvider`, `voiceAssistantServiceProvider` | — | — | `_buildCommandItem` |
| `lib/features/screens/location_settings_screen.dart` | Location toggle and “Set Location” entry | `LocationSettingsScreen` (StatelessWidget) | — | — | — | — |
| `lib/features/screens/set_location_screen.dart` | Set location search and city list | `SetLocationScreen` (StatelessWidget) | — | — | — | `_buildLocationOption` |

### Screens – widgets

| File | Purpose | Classes | Providers | Services | Models | Public methods |
|------|---------|---------|-----------|----------|--------|----------------|
| `lib/features/screens/widgets/bottom_nav_bar.dart` | Bottom nav (Home, Donate, Requests, Chat, Profile) | `NavItem` (enum), `BottomNavBar` | — | — | — | `_buildNavItem` |
| `lib/features/screens/widgets/floating_action_buttons_group.dart` | Expandable FAB (voice, community, rewards, QR) | `FloatingActionButtonsGroup` (StatefulWidget) | — | — | — | `_toggleExpanded`, `_buildFAB` |
| `lib/features/screens/widgets/page_with_floating_buttons.dart` | Wraps child with floating buttons | `PageWithFloatingButtons` (StatelessWidget) | — | — | — | — |
| `lib/features/screens/widgets/voice_assistant_button.dart` | Button to open voice assistant | (widget) | — | — | — | — |
| `lib/features/screens/widgets/voice_assistant_dialog.dart` | Full-screen dialog: listen, match command, navigate | `VoiceAssistantDialog` (ConsumerStatefulWidget) | uses `voiceAssistantServiceProvider` | — | — | `_startListening`, etc. |
| `lib/features/screens/widgets/stat_card.dart` | Stat card (label, value, icon) | `StatCard` | — | — | — | — |
| `lib/features/screens/widgets/donation_card.dart` | Donation card (title, author, status, emoji) | `DonationCard` | — | — | — | — |
| `lib/features/screens/widgets/request_card.dart` | Request card (title, distance, requestor, onDonate) | `RequestCard` | — | — | — | — |
| `lib/features/screens/widgets/quick_action_card.dart` | Gradient quick action card | `QuickActionCard` | — | — | — | — |
| `lib/features/screens/widgets/impact_card.dart` | Trees saved impact card | `ImpactCard` | — | — | — | — |
| `lib/features/screens/widgets/status_badge.dart` | Donation status badge | `DonationStatus` (enum), `StatusBadge` | — | — | — | — |
| `lib/features/screens/widgets/donation_history_card.dart` | Donation history row | `DonationHistoryCard` | — | — | — | — |
| `lib/features/screens/widgets/book_request_card.dart` | Book request list item | `BookRequestCard` | — | — | — | — |
| `lib/features/screens/widgets/book_type_toggle.dart` | Physical / E-book toggle | `BookTypeToggle` | — | — | — | — |
| `lib/features/screens/widgets/filter_pills.dart` | Filter pills (all, nearby, recent, popular) | `FilterPills` | — | — | — | — |
| `lib/features/screens/widgets/ebook_card.dart` | E-book card (download, buy, preview) | `EBookCard` | — | — | — | — |
| `lib/features/screens/widgets/menu_card.dart` | Profile menu card | `MenuCard` | — | — | — | — |
| `lib/features/screens/widgets/menu_item_row.dart` | Single menu row | `MenuItemRow` | — | — | — | — |
| `lib/features/screens/widgets/profile_header.dart` | Profile header with avatar and settings | `ProfileHeader` | — | — | — | — |
| `lib/features/screens/widgets/profile_avatar.dart` | Profile avatar | `ProfileAvatar` | — | — | — | — |
| `lib/features/screens/widgets/floating_stats_row.dart` | Profile stats row | `FloatingStatsRow` | — | — | — | — |
| `lib/features/screens/widgets/quick_stats_card.dart` | Quick stats card | `QuickStatsCard` | — | — | — | — |
| `lib/features/screens/widgets/shortcut_grid.dart` | Shortcut grid | `ShortcutGrid` | — | — | — | — |
| `lib/features/screens/widgets/gamification_card.dart` | Gamification card | `GamificationCard` | — | — | — | — |
| `lib/features/screens/widgets/logout_button.dart` | Logout with confirmation | `LogoutButton` | — | — | — | — |
| `lib/features/screens/widgets/radio_card.dart` | Radio-style card (e.g. free/paid) | `RadioCard` | — | — | — | — |
| `lib/features/screens/widgets/upload_button.dart` | Camera/Gallery upload button | `UploadButton` | — | — | — | — |

### Test

| File | Purpose | Classes | Providers | Services | Models | Public methods |
|------|---------|---------|-----------|----------|--------|----------------|
| `test/widget_test.dart` | Default Flutter widget test (counter smoke test) | — | — | — | — | `main` (expects counter 0/1; app no longer has counter) |

---

## 3. FIREBASE INTEGRATION STATUS

- **Initialization:** Yes. In `main.dart`, `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` is called before `runApp`.
- **Firebase services imported/used:**
  - **firebase_core:** Used in `main.dart` and `firebase_options.dart`.
  - **firebase_auth:** Used in `auth_service.dart` and `auth_provider.dart` (`FirebaseAuth.instance`, `User`, `UserCredential`).
  - **cloud_firestore:** Used in `book_service.dart` only (`FirebaseFirestore.instance.collection('books')`).
  - **firebase_storage:** Used in `book_service.dart` only (`FirebaseStorage.instance`, `ref`, `putFile`, `getDownloadURL`).
  - **google_sign_in:** Used in `auth_service.dart` for `signInWithGoogle` and in `signOut` on mobile.
- **Firestore collections referenced:** `books` (in `book_service.dart`).
- **Storage paths used:** `bookCovers/$ownerId/$id.jpg` (in `book_service.dart`).
- **Auth methods implemented:**
  - Email sign-in: `signInWithEmail` in `AuthService`; used from `LoginScreen`.
  - Email register: `registerWithEmail` in `AuthService`; used from `SignupScreen`.
  - Google sign-in: `signInWithGoogle` in `AuthService` (web: popup; mobile: Google Sign-In plugin; desktop: throws UnsupportedError).
  - Anonymous sign-in: `signInAnonymously` (used for mock login in `LoginScreen`).
  - Sign-out: `signOut` in `AuthService` (Firebase + Google Sign-Out on mobile); used from profile logout.
  - Auth state: `authStateChanges()` stream exposed via `authStateProvider` and used in router redirect and splash.

---

## 4. FEATURE IMPLEMENTATION SNAPSHOT

### Authentication

| Feature | Status |
|--------|--------|
| Email login | Implemented (`AuthService.signInWithEmail`, `LoginScreen`) |
| Email register | Implemented (`AuthService.registerWithEmail`, `SignupScreen`) |
| Google login | Implemented (`AuthService.signInWithGoogle`; web + mobile; not desktop) |
| Logout | Implemented (`AuthService.signOut`, profile `LogoutButton`) |
| Auth state listener | Implemented (`authStateProvider` from `authStateChanges()`) |
| Mock/anonymous login | Implemented (LoginScreen: abc@gmail.com / 123456 → anonymous + display name) |
| Forgot password | Not present in code (TODO in `LoginScreen`) |

### Books

| Feature | Status |
|--------|--------|
| Add book (Firestore) | Implemented in `BookService.addBook` (title, author, ownerId, optional cover file); not used by DonateScreen (donate form is local-only) |
| Stream books | Implemented (`BookService.streamBooks`, `booksStreamProvider`); no screen currently watches it |
| Upload cover | Implemented in `BookService.addBook` (Firebase Storage `bookCovers/$ownerId/$id.jpg`) |
| Book model | Implemented (`Book` with Firestore `fromDoc`/`toMap`) |
| Firestore integration | Implemented for `books` collection in `BookService` only |
| DonateScreen form | Partially implemented: full UI and local submit; does not call `BookService.addBook` or persist to Firestore |

### Certificates

| Feature | Status |
|--------|--------|
| Certificate generation | Not present in code |
| PDF generation | Not present in code |
| Storage of certificate | Not present in code |
| Certificate UI | Partially implemented: `RewardsScreen` shows certificate list and download icon; download handler is empty |

### UI

| Screen / area | Status |
|---------------|--------|
| Splash screen | Implemented (auth check, redirect to /home or /login) |
| Login screen | Implemented (email + mock login, link to signup) |
| Signup screen | Implemented (name, email, password, confirm; validation) |
| Onboarding screen | Implemented (carousel, Skip, Next, Get Started) |
| Home screen | Implemented (header, stats, recent donations, nearby requests, quick actions, impact) |
| Donate screen | Implemented (list + form; form does not persist to Firestore) |
| Requests / Find books screen | Implemented (physical/ebook toggle, filters, search, mock list) |
| E-book listing screen | Implemented (search, mock list, download/buy/preview actions) |
| Book detail screen | Implemented (mock data; request free / buy / chat) |
| Chat screen | Implemented (empty state; no backend) |
| Profile screen | Implemented (header, stats, menu, shortcuts, gamification, logout) |
| Settings screen | Implemented (language, voice, location, notifications links) |
| Payment screen | Implemented (book summary, payment method placeholder, order summary, Pay → dialog) |
| QR screen | Implemented (Generate / Scan tabs; placeholder content) |
| Rewards screen | Implemented (points, badges, certificate list; no PDF) |
| Eco tracker screen | Implemented (trees saved, stats, chart placeholder) |
| Community screen | Implemented (hardcoded activity feed) |
| Language settings screen | Implemented (language list, English selected) |
| Voice settings screen | Implemented (enable voice, voice feedback, command list, test) |
| Location settings screen | Implemented (location toggle, set location entry) |
| Set location screen | Implemented (search field, city list; tap does not persist) |
| Bottom nav | Implemented (Home, Donate, Requests, Chat, Profile) |
| Floating action buttons | Implemented (Voice, Community, Rewards, QR) |
| Voice assistant dialog | Implemented (listen, match commands, navigate) |

---

## 5. DATA MODEL STRUCTURE

### Firestore (inferred from code)

**Collection: `books`**

| Field | Type | Notes |
|-------|------|--------|
| `title` | string | |
| `author` | string | |
| `coverUrl` | string | From Storage or empty |
| `ownerId` | string | |
| `status` | string | Default `'available'` |
| `createdAt` | timestamp | `FieldValue.serverTimestamp()` on add |

Document ID: auto-generated (`_books.add(book)`).

No other Firestore collections or documents are referenced in the code. `UserProfile`, `EBook`, `RequestBook`, and `DonationItem` are in-memory/UI models only.

---

## 6. NAVIGATION STRUCTURE

- **Router:** `go_router` with a single `GoRouter` provided by `routerProvider` in `app_router.dart`. `MaterialApp.router(routerConfig: router)` in `main.dart`.
- **Routes:** All routes are **named** and declared on the single `GoRouter`:
  - `/` → SplashScreen  
  - `/onboarding` → OnboardingScreen  
  - `/login` → LoginScreen  
  - `/signup` → SignupScreen  
  - ShellRoute (bottom nav + floating buttons) with child routes: `/home`, `/donate`, `/requests`, `/chat`, `/profile`  
  - Standalone routes (with `PageWithFloatingButtons` where used): `/ebook-list`, `/book-detail/:id`, `/settings`, `/qr`, `/rewards`, `/eco-tracker`, `/community`, `/language-settings`, `/voice-settings`, `/location-settings`, `/set-location`, `/payment` (with `extra`: `RequestBook`).
- **Redirect:** If not at `/`, unauthenticated users go to `/login`; authenticated users on `/login`, `/signup`, or `/onboarding` go to `/home`.
- **Navigation calls:** `context.go(...)` and `context.push(...)` from `go_router`; one place uses `Navigator.push(context, MaterialPageRoute(...))` (RequestsScreen → EBookListingScreen).
- **Summary:** Named routes with GoRouter; one hybrid use of `Navigator.push` for EBookListingScreen.

---

## 7. STATE MANAGEMENT STRUCTURE

- **Library:** `flutter_riverpod` (ProviderScope in `main.dart`).

**Providers:**

| Provider | Type | Controls |
|----------|------|----------|
| `routerProvider` | `Provider<GoRouter>` | Single GoRouter instance; uses `authStateProvider` in redirect |
| `authServiceProvider` | `Provider<AuthService>` | Singleton `AuthService` |
| `authStateProvider` | `StreamProvider<User?>` | Firebase auth state; drives router redirect and splash |
| `bookServiceProvider` | `Provider<BookService>` | Singleton `BookService` |
| `booksStreamProvider` | `StreamProvider<List<Book>>` | Live list of books from Firestore (no screen uses it currently) |
| `voiceAssistantServiceProvider` | `Provider<VoiceAssistantService>` | Singleton voice service; disposed on provider dispose |
| `voiceSettingsNotifierProvider` | `Provider<VoiceSettingsNotifier>` | In-memory voice settings (assistant on/off, feedback on/off) |
| `voiceAssistantEnabledProvider` | `Provider<bool>` | Derived from `voiceSettingsNotifierProvider` |
| `voiceFeedbackEnabledProvider` | `Provider<bool>` | Derived from `voiceSettingsNotifierProvider` |

**Widget usage:** `ConsumerWidget`, `ConsumerStatefulWidget`, `ref.watch(...)`, `ref.read(...)` in screens and voice dialog. No other state management (e.g. ChangeNotifier, Bloc) is used.

---

## 8. DEPENDENCY SUMMARY

From `pubspec.yaml`:

| Dependency | Version | Purpose |
|------------|---------|---------|
| flutter | sdk | Framework |
| cupertino_icons | ^1.0.2 | Icons |
| firebase_core | ^4.2.1 | Firebase init |
| firebase_auth | ^6.1.2 | Auth |
| cloud_firestore | ^6.1.0 | Firestore |
| firebase_storage | ^13.0.4 | Storage |
| firebase_storage_web | ^3.11.0 | Storage on web |
| firebase_auth_web | ^6.1.0 | Auth on web |
| google_sign_in | ^6.1.0 | Google Sign-In |
| flutter_riverpod | ^3.0.3 | State management |
| go_router | ^14.2.0 | Navigation |
| cached_network_image | ^3.2.3 | Image caching |
| image_picker | ^1.1.0 | Camera/gallery |
| flutter_hooks | ^0.18.6 | Hooks (optional) |
| intl | ^0.18.1 | Intl |
| uuid | ^4.5.2 | UUIDs (e.g. in BookService) |
| google_fonts | ^6.1.0 | Fonts (Poppins, Nunito Sans) |
| permission_handler | ^11.3.0 | Permissions (e.g. voice) |
| geolocator | ^11.1.0 | Location (not wired in UI) |
| file_picker | ^8.0.0 | File picking |
| qr_flutter | ^4.1.0 | QR display |
| mobile_scanner | ^5.2.0 | QR scan |
| speech_to_text | ^7.0.0 | Voice input |
| flutter_tts | ^4.0.0 | Voice output |
| http | ^1.2.0 | HTTP |

**Dev:** `flutter_test`, `flutter_lints: ^2.0.0`.

**Flutter config:** `uses-material-design: true`. No `assets` section.
