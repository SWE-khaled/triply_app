# Triply

### A travel marketplace and social platform connecting tourists with verified local guides in Egypt.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Status](https://img.shields.io/badge/status-in%20development-blue)](https://github.com/SWE-khaled/triply_app)
[![License](https://img.shields.io/badge/license-not%20specified-lightgrey)](#13-license)

Triply is a Flutter application that brings trip discovery, booking, messaging and community content together. Tourists can browse approved guides and public trips, create bookings, use Paymob checkout, follow stories and posts, and chat with guides. Guides manage their profile, trips, travellers and earnings. Administrators review verification and trip applications, manage users and bookings, moderate content and monitor activity in a dedicated dashboard.

> This README describes the current source and repository configuration on the `main` branch. Statuses were verified against the implementation under `lib/`, the committed Firebase configuration and the project setup. Historical documents are retained only for background and are not used as proof that a feature is complete. Source implementation and production deployment are separate claims; deployed Firebase services and rules cannot be verified from this repository alone. See [Key Features](#2-key-features) for the current status of each feature.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Key Features](#2-key-features)
3. [Screenshots](#3-screenshots)
4. [Tech Stack](#4-tech-stack)
5. [Architecture](#5-architecture)
6. [Installation & Setup](#6-installation--setup)
7. [Environment Variables & Configuration](#7-environment-variables--configuration)
8. [Backend & Data](#8-backend--data)
9. [Repository Structure](#9-repository-structure)
10. [Team Members](#10-team-members)
11. [Future Improvements](#11-future-improvements)
12. [Documentation](#12-documentation)
13. [License](#13-license)

---

## 1. Project Overview

Triply is a mobile-first travel marketplace and social platform for Egypt. It serves three audiences in one application:

| Audience | What they do in Triply |
|---|---|
| **Tourists** | Discover destinations and approved guides, book private or public trips, go through Paymob checkout, chat, publish posts and stories, and manage their trips and profile. |
| **Tour guides** | Build a public profile, submit identity documents, create trips for admin review, manage bookings and travellers, and view earnings. |
| **Administrators** | Review guide verification and trip applications, manage users, trips and bookings, moderate reports and community posts, and monitor dashboard statistics. |

The app aims to replace the fragmented process of finding a trustworthy local guide, coordinating a trip and keeping the communication in one place, while giving verified guides a channel to offer their trips.

---

## 2. Key Features

Status legend:

| Symbol | Meaning |
|---|---|
| ✅ | Implemented and integrated for the stated scope. |
| ✅ | Implemented and integrated, but with remaining limitations such as sample fallbacks, hardcoded values, client-side assertions or placeholder sub-actions. |
| 🚧 | The UI or a local placeholder exists, but the complete flow or destination is not implemented. |

### Tourist

| Feature | Status | Notes |
|---|---|---|
| Onboarding & Role Selection | ✅ | Static onboarding slides, a local preference flag and role routing are wired. |
| Authentication & Session | ✅ | Email/password, Google sign-in, password-reset email and role-aware restore are connected. Apple sign-in is still a TODO and the password-confirmation screen has no registered route. |
| Home & Discovery | ✅ | Firestore-backed guide and trip sections are connected, and the community banner opens the community screen. Place cards and banner figures are bundled samples, and favourites are session-only. |
| Explore & Search | ✅ | The search UI and Cubit work locally against bundled mocks; `SearchFilter` is stored but not applied to results. |
| Guides, Maps & Place Details | ✅ | Approved Firestore guides and places are connected with `flutter_map` and OpenStreetMap tiles. Language options, place details and stories still use bundled samples; guide-list chat, place chat and story taps are placeholders, and bookmarks are local-only. |
| Private & Public Booking | ✅ | Firestore guide identity, EGP pricing, approved trips, transactional seat reservation and booking creation are wired. Private places, slots and meeting points are samples or hardcoded; the fee is fixed at 5%; trip details can fall back to sample trips; popular and home trips retain unreachable fallback branches; the old local `confirm()` path is dead code. |
| Payment & Checkout | ✅ | Paymob auth, order, payment key, card iframe and wallet WebView are connected. `.env` fallbacks are empty, success is asserted by the client from the URL, the booking id is stored as the payment id, and the private payment method is hardcoded to `card`. |
| Community & Stories | ✅ | Firestore feed, Cloudinary image upload, likes, deletes, live stories and 24-hour expiry are connected. Comments and shares are no-ops, Cloudinary assets are not deleted with their records, and story URLs are restricted to a Cloudinary format. |
| Chat & Notifications | ✅ | Firestore chats, messages, typing and read state, reports, FCM tokens, local display and in-app notification rows are connected. Several tourist chat entry points are no-ops, the background handler only logs messages, and booking notification taps have no global route. |
| My Trips & Profile | ✅ | Firestore bookings, cancellation, seat release and profile editing with Firebase Auth sync are connected. Session-only booking records remain in several paths, and labels, currency and private-trip detection are inconsistent. Some profile statistics, preferences and switches are mock or session-local. |
| Favourites | 🚧 | A local toggle exists, but there is no repository, Firestore write or cross-session persistence. |

### Tour Guide

| Feature | Status | Notes |
|---|---|---|
| Onboarding & Settings | ✅ | Static onboarding records the preference and routes to login; settings provides password reset. |
| Authentication & Session | ✅ | Firebase sign-in, role checks and session restore are connected. Signup hardcodes license number, languages and the `+20` prefix; failed role reads sign the guide out, login/profile verification-read failures are treated as unverified, and startup restore falls back to cached verification when Firestore is unreachable. |
| Profile & Verification | ✅ | Public profile writes, a live verification badge, file picking, Cloudinary upload and the pending `guideVerifications` write are connected. Specialty, rating and review counts are hardcoded; bookmarks and cover previews are local-only; profile load failures fall back to blank data; “Skip for now” opens the dashboard and review-time copy is hardcoded. |
| Dashboard & Booking Details | ✅ | Live trip, booking and verification streams are connected. Dashboard statistics seed the name and avatar from mocks, although displayed values come from Firebase Auth/Firestore; pending requests count trips rather than booking requests; rows can fall back to mocks and the Total Bookings tap is empty. |
| Trips & Approval | ✅ | Firestore create, update and delete, validation, generated IDs and approval fields are wired. New trips are `pending` and admin approval controls public visibility, but the verification gate described in the UI copy is not enforced by the create-trip path. Lists and details retain mock fallbacks, placeholder covers and hardcoded rating fields. |
| Travellers & Check-in | ✅ | Lead travellers are read from Firestore bookings. Profile and check-in views are display-only, counts are hardcoded and reads can fall back to mocks; no check-in state is persisted. |
| Earnings & Withdrawals | ✅ | Balances derive from eligible paid Firestore bookings, with a mock fallback. The withdrawal action shows “coming soon” and has no backend. |
| Notifications | ✅ | The shared Firestore notification repository and FCM are connected. Chat taps are role-aware, while trip taps use tourist trip details; booking taps have no global route and admin verification decisions do not notify the guide. |
| Chat Participation | ✅ | Guides can open existing chats and reply through the shared Firestore implementation; new chats are initiated by tourists. |

### Admin Dashboard

| Feature | Status | Notes |
|---|---|---|
| Access & Overview | ✅ | Firebase sign-in, a Firestore role check for interactive login and live KPI streams are connected. Login also enforces a hardcoded email fragment, restored sessions bypass that check and may use cached roles, and no client-side first-admin provisioning exists. Overview hardcodes commission at 10%, Reject and Suspend both write `suspended`, and its document “View file” cell is inert, although the dedicated Guides tab opens a details dialog. |
| Users & Guide Verification | ✅ | The live user list, status toggle, verification decisions across collections and document viewing are wired. “Tourists” are all users whose role is not `guide`, including admins; type and activity are hardcoded and status is not enforced by app sign-in. Rejected guides display as suspended, guide trip data can be stale, and verification decisions do not notify the guide. |
| Trips & Applications | ✅| Live trip streams, rejection, approval in the duplicated applications module and the shared trips repository are connected. The main Trips module has no approve action; “Cancel & Refund” only rejects the trip without refunding or restoring seats. Applications are not a separate collection, the mapper hardcodes public type and empty participants, and cancelled rows remain actionable. |
| Bookings & Reports | ✅ | Live booking and chat-report lists, status changes and report review are wired. Booking updates do not set payment/refund fields or restore seats, the Total column shows unit price, and reports support status changes only, with no message deletion, user ban or report deletion. |
| Community Moderation & Settings | ✅ | Live post feed, admin delete and `appSettings/general` load/save are wired. An unused admin repository still contains fake seed logic, Cloudinary assets are not deleted with posts, there is no story-moderation UI, settings search is inert, saved commission is not consumed by Overview, and `approvalMode` has no consumer. |

> These statuses describe implemented source paths, including mock fallbacks and placeholder sub-actions. They do not describe verified production behaviour.

---

## 3. Screenshots

Screenshots have not been added to this repository. The images under `assets/images/` are onboarding artwork, icons and branding assets, not UI captures, so they are not presented here as application screenshots. This section can be expanded when real Tourist, Tour Guide and Admin previews are available.

---

## 4. Tech Stack

| Technology | Role in Triply |
|---|---|
| **Flutter** and **Dart** (`^3.12.2`) | Cross-platform UI and application language. Android, iOS, Web, macOS, Linux and Windows runners are present. |
| **Firebase Authentication** | Email/password and Google sign-in, session restore and password reset. |
| **Cloud Firestore** | Primary database and real-time source for users, guides, trips, bookings, chats, stories, posts, reports and notifications. |
| **Firebase Cloud Messaging** and `flutter_local_notifications` | FCM token registration, foreground local display and notification-tap navigation. The registered background handler currently only logs messages. |
| **Flutter Bloc / Cubit** (`flutter_bloc`) | Primary state management. App-session Cubits are provided in `main.dart`; feature screens create their own Cubits where needed. |
| **`flutter_map`** and `latlong2` | Interactive maps with OpenStreetMap tiles, markers, filters and place focus. |
| **Cloudinary** | Uploads for community images, profile photos and guide verification documents. |
| **Paymob** (`dio` and `webview_flutter`) | Card iframe and mobile-wallet payment steps against the Paymob REST API. |
| **Supporting packages** | `google_sign_in`, `shared_preferences`, `image_picker`, `file_picker`, `url_launcher`, `flutter_svg`, `google_fonts`, `shimmer`, `dropdown_search` and related UI helpers. `pdf` is used only by `tool/generate_report_pdf.dart`; `http` is directly imported by two app-source files but is currently only a transitive dependency in `pubspec.lock`. |

`provider` is not a direct dependency in `pubspec.yaml`; it is available transitively through `flutter_bloc`. There is no direct `package:provider` import in `lib/`: it is used indirectly through `BlocProvider`, `MultiBlocProvider` and `context.watch<T>()`. Stale references to `AuthProvider` in `tool/generate_report_pdf.dart` do not describe the current app source.

`google_maps_flutter`, `firebase_storage`, `pay_with_paymob`, `lucide_icons_flutter`, `iconsax_flutter` and `pdf` are declared in `pubspec.yaml` but have no call site under `lib/`. The in-app map is rendered with `flutter_map`, not Google Maps.

---

## 5. Architecture

Triply follows a feature-first, MVVM-style structure with Cubits as ViewModels:

| MVVM role | Implementation in this repository |
|---|---|
| **Model** | Plain classes and Firestore mappers under `lib/core/data/models/` and feature `model/` folders. |
| **View** | Screens and widgets under each feature's `view/` and `widgets/` folders. Views render state and dispatch events. |
| **ViewModel** | Cubits and immutable state classes under each feature's `cubit/` folder. |
| **Data / Services** | Firestore repositories in `lib/core/data/repositories/`, feature-local repositories and shared services in `lib/core/services/`. |
| **State management** | Cubit via `flutter_bloc`. `MultiBlocProvider` in `lib/main.dart` provides app-session Cubits; feature screens create their own where needed. |

```text
View (screens/widgets)  ──calls──▶  Cubit (ViewModel)
        ▲                               │
        │ emits State                   │ reads/writes
        └──────────────────────────────  ▼
                              Model / Repository / Service
                                       │
                                       ▼
                         Firestore · Auth · Cloudinary · Paymob
```

Navigation uses `AppRoutes` and `AdminRoutes` in `lib/core/routing/app_routes.dart` plus named routes in `lib/main.dart`. Application startup follows: Firebase initialisation → FCM/notification setup → `.env` load → Paymob/Dio setup → app.

### Project structure

```text
lib/
├── main.dart                     # App entry, Firebase init, global BlocProviders
├── firebase_options.dart         # Generated Firebase platform options
├── core/
│   ├── constants/                # App assets and constants
│   ├── data/
│   │   ├── models/               # Shared domain models
│   │   ├── mock/                 # Sample datasets used as fallbacks
│   │   ├── repositories/         # Firestore repositories
│   │   └── seed/                 # Development seed helpers
│   ├── helper/                   # Shared helpers
│   ├── network/                  # Dio configuration
│   ├── notification_toruist/     # FCM and local notification handling
│   ├── routing/                  # AppRoutes and AdminRoutes
│   ├── services/                 # Preferences, Cloudinary and session services
│   ├── theme/                    # App theme and colours
│   ├── utils/                    # Shared utilities and mixins
│   └── widgets/                  # Shared UI widgets
└── features/
    ├── tourist/                  # Home, search, guides, trips, booking, checkout,
    │                             # map, community, chat entry, my trips and profile
    ├── tour_guide/               # Auth, onboarding, dashboard, trips, travellers,
    │                             # earnings, profile and verification
    ├── admin_dashboard/          # Overview, users, guides, trips, bookings,
    │                             # reports, posts, settings and applications
    ├── chat/                     # Shared chat screens, models and repository
    ├── common/                   # Shared authentication and role selection
    └── splash/                   # Splash and startup routing gate
```

---

## 6. Installation & Setup

### 1. Prerequisites

- A Flutter SDK compatible with Dart `^3.12.2` (`flutter --version`).
- Android SDK and/or Xcode for the platform you plan to build.
- A Firebase project with Authentication, Cloud Firestore and Cloud Messaging configured.
- Firebase CLI, optional, for deploying rules and indexes.
- A Paymob sandbox account for exercising checkout; non-payment flows can run without it.

### 2. Clone and install

```bash
git clone https://github.com/SWE-khaled/triply_app.git
cd triply_app
flutter pub get
```

### 3. Firebase configuration

Firebase platform configuration is committed:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `firebase.json`, `firestore.rules` and `firestore.indexes.json`

For a different Firebase project, regenerate the options and replace the platform configuration files:

```bash
flutterfire configure
firebase deploy --only firestore:rules,firestore:indexes
```

`firebase deploy` requires an authenticated Firebase CLI account with access to that project.


The built-in fallbacks are empty strings, so valid values are required for checkout. The in-app map uses public OpenStreetMap tiles and does not read a Maps key from Dart or `.env`. On Android, the native build optionally reads `MAPS_API_KEY` from `android/local.properties` or the environment and injects it as the Google Maps metadata placeholder; this is separate from the Flutter map implementation. See [Environment Variables & Configuration](#7-environment-variables--configuration) before using real credentials.

### 4. Run and validate

```bash
flutter run
```

Optional validation:

```bash
flutter analyze
flutter test
```

`flutter test` currently includes a leftover default counter widget test that does not match the app; see [Future Improvements](#11-future-improvements).

---

## 5. Environment Variables & Configuration

| Configuration | Where it is configured | Read by | Notes |
|---|---|---|---|
| Firebase platform options | `lib/firebase_options.dart`, `android/app/google-services.json` | `main.dart` via `Firebase.initializeApp` | Generated files; regenerate for your own Firebase project. |
| Paymob credentials | `.env` at the repository root | `lib/features/tourist/checkout/paymob_settings.dart` via `flutter_dotenv` | Four keys are read. The fallbacks are empty strings and a missing `.env` load is silently ignored. |
| Maps | `lib/features/tourist/map/view/map_view.dart`; native Android build files | `flutter_map`; Android manifest placeholder | OpenStreetMap tiles need no Dart/`.env` key. The Android build can inject an optional `MAPS_API_KEY` into `com.google.android.geo.API_KEY`. |
| Cloudinary | `lib/core/services/cloudinary_service.dart`, `lib/features/tourist/community/data/community_cloudinary_uploader.dart` and profile upload helpers | `cloudinary_public` and direct HTTP uploads | Two hardcoded public cloud/upload-preset pairs are used; no Cloudinary secret is read from `.env`. |
| Firestore security | `firestore.rules`, `firestore.indexes.json` | Firebase backend | Deploy with the Firebase CLI. Source files do not prove which rules or indexes are currently deployed. |

**Security notes for contributors**

- Never commit `.env`, API keys, tokens, service accounts or Firebase admin credentials.
- Although `.env` is git-ignored, it is also declared as a Flutter asset, so anything placed in it is bundled into built apps. Use sandbox or demo values for local builds.
- The current Paymob flow uses an API key loaded on the client; moving credential handling to a trusted backend remains outstanding.
- This README contains no real credentials or secret values.

---

## 6. Backend & Data

| Service | Role in Triply |
|---|---|
| **Firebase Authentication** | Sign-up and sign-in for tourists and guides, Google sign-in, password reset and role-based session restore. |
| **Cloud Firestore** | Primary database for `users`, `guides`, `guideVerifications`, `trips`, `bookings`, `places`, `appSettings`, `chats` (with `messages` and `typing`), `communityPosts`, `communityStories` and `reports`. Notification rows are stored under `users/{uid}/notifications`; the global `notifications` rules are legacy. The client reads `places`, but `firestore.rules` has no dedicated `match /places` block. Several screens still keep parallel in-memory or session records. |
| **Firebase Cloud Messaging** | Token registration, foreground local display and notification-tap navigation. The background handler currently only logs messages. |
| **Cloudinary** | Two hardcoded public upload configurations are used for community/profile images and guide verification/trip-cover documents. |
| **Paymob** | Card and wallet checkout: auth token → order → payment key → iframe/wallet WebView. Confirmation is written by the client, not by a verified server callback. |
| **Firebase Cloud Functions** | No Functions implementation or configuration exists in this repository: there is no `functions/` directory, no `functions` block in `firebase.json` and no `cloud_functions` client dependency. Functions deployed outside this repository cannot be verified from the source. |

Firestore rules and indexes live in `firestore.rules` and `firestore.indexes.json`. They describe the intended repository configuration, not necessarily what is deployed. The linked [project audit](docs/PROJECT_FILE_AUDIT.md) is background material only.

---

## 7. Repository Structure

| Path | Responsibility |
|---|---|
| `lib/` | Application source: entry point, core infrastructure and feature modules. |
| `lib/core/` | Shared models, repositories, mock data, routing, theme, services, network and widgets. |
| `lib/features/` | Feature-first modules for tourist, tour guide, admin, chat, common auth and splash flows. |
| `assets/images/` | Branding, onboarding artwork, icons and declared image assets. |
| `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/` | Platform runners and build configuration. |
| `test/` | Flutter unit and widget tests. |
| `tool/` | Manual developer maintenance scripts. |
| `docs/` | Project documentation, including the linked background audit. |
| `firebase.json`, `firestore.rules`, `firestore.indexes.json` | Firebase CLI and Firestore security/index configuration. |
| `pubspec.yaml`, `pubspec.lock` | Dependencies, assets and Flutter build settings. |
| `opencode/` | Historical planning and backup artifacts retained in the repository. |
| `README.md` | This file. |

---

## 8. Team Members

- Khaled Mohamed - Team lead
- Amr khaled 
- Rawda Ellithy
- Aya Emad
- shrouk Atef
---

## 9. Future Improvements

The following work remains outstanding in the current source:

- **Payments:** verify Paymob transactions server-side, store the real transaction/order id instead of the booking id, move credential handling out of the client bundle, handle the app-killed-after-charge case and record the actual private-booking payment method instead of the hardcoded `card` value.
- **Data sources:** make Firestore the single source of truth for My Trips and profile counters; remove or gate bundled sample fallbacks in search, home places, trip details, map, guide dashboard, travellers, earnings and profile paths; and delete the unreachable popular/home fallback branches.
- **Search and favourites:** connect `SearchCubit` to a real repository, apply `SearchFilter` and persist favourites across sessions.
- **Placeholder flows:** implement Apple sign-in, register a reachable password-confirmation screen and replace no-op tourist chat entries, place-detail chat/story taps and community comment/share actions with real destinations.
- **Guide operations:** implement traveller profile and check-in persistence, withdrawals and an availability write model; notify guides of verification decisions; and enforce the verification gate described in the UI copy if it is intended.
- **Admin operations:** replace the hardcoded admin email check and add first-admin provisioning consistent with the existing rules; align client and rules-based role enforcement; make cancellation and booking status updates modify refund, payment and seat fields correctly; distinguish rejected from suspended guides; consume saved commission and `approvalMode`; add an approve action or merge the duplicated trip-management modules; add story moderation; and fix the hardcoded trip-application type.
- **Security rules:** tighten duplicated `allow update` blocks, notably the second `trips` rule that lets any signed-in caller change `bookedSeats` and `updatedAt`; add role, status and payment assertions where client checks can be bypassed; and add a dedicated `places` rule if the client collection is intended to be supported.
- **Code quality:** consolidate duplicate model, profile-editor and Cloudinary upload paths; remove unreachable files, stale routes and unused assets/dependencies; and declare the directly imported `http` package.
- **Testing and CI:** replace the leftover default counter widget test with meaningful Triply tests and add a CI workflow.
- **Documentation and assets:** add real Tourist, Tour Guide and Admin screenshots, and add confirmed team information when available.

---

## 10. Documentation

| Document | Description |
|---|---|
| [README.md](README.md) | Project introduction, current feature status, setup and configuration guide. |
| [docs/PROJECT_FILE_AUDIT.md](docs/PROJECT_FILE_AUDIT.md) | Background document retained in the repository. It is not used as evidence for current feature status; current status comes from the source and configuration in this repository. |

No `docs/TRIPLY_MASTER_DOCUMENTATION.md` file exists in this repository at the time of writing.

---

## 11. License
  
No `LICENSE` file exists in this repository. The project should therefore be treated as **all rights reserved** unless a license is added by the repository owner. No license type is assumed here.
