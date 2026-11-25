# Triply 🇪🇬

A travel marketplace and social platform connecting tourists with verified local guides in Egypt.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)

Triply brings trip discovery, booking, payment, chat and community content into one Flutter app with three roles: **Tourist**, **Tour Guide** and **Admin**. Built during the DEPI × eYouth internship program.

## Download

Get the latest Android APK from the [Releases](../../releases) page.

## Key Features

### Tourist
- Email and Google sign-in, password reset
- Discover places, approved guides and trips on a map (OpenStreetMap)
- Private and public trip booking with transactional seat reservation
- Paymob checkout (test mode): card and mobile wallet
- My Trips with cancellation
- Real-time chat with guides
- Community posts and 24-hour stories
- Light and dark mode

### Tour Guide
- Profile and ID / license verification
- Create and manage trips (admin approval required)
- Bookings, travellers and earnings dashboard
- Real-time chat with tourists

### Admin Dashboard
- Live statistics overview
- Approve or reject guides and trips
- Manage users and bookings
- Moderate posts and review chat reports
- Platform settings

> Some screens still use sample data as a fallback, and payments run in Paymob test mode.

## Tech Stack

| Technology | Role |
|---|---|
| Flutter and Dart | Cross-platform UI |
| Cubit (flutter_bloc) | State management |
| Firebase Auth | Authentication |
| Cloud Firestore | Database and real-time data |
| Firebase Cloud Messaging | Push notifications |
| Paymob | Card and wallet payments |
| Cloudinary | Image and document uploads |
| flutter_map | Maps with OpenStreetMap tiles |

## Architecture

Feature-first MVVM, with Cubits as ViewModels:

```
View (screens/widgets) ──▶ Cubit (ViewModel) ──▶ Repository / Service
                                                       │
                                  Firestore · Auth · Cloudinary · Paymob
```

```
lib/
├── core/        # models, repositories, routing, theme, services, widgets
└── features/    # tourist, tour_guide, admin_dashboard, chat, common, splash
```

## Getting Started

**Prerequisites:** Flutter SDK (Dart ^3.12.2) and a Firebase project with Auth, Firestore and Cloud Messaging.

```bash
git clone https://github.com/SWE-khaled/triply_app.git
cd triply_app
flutter pub get
```

Run the app:

```bash
flutter run
```

To use your own Firebase project, run `flutterfire configure` and deploy `firestore.rules` and `firestore.indexes.json`.

## Future Improvements

- Server-side Paymob verification and live payments
- Automatic push notifications
- Conversation lock after a confirmed report
- Persistent favourites and real search filters
- Dark mode for the Admin Dashboard
- Tighter Firestore security rules
- Meaningful tests and a CI workflow
- Tourism company accounts and hotel booking

## Team

- Khaled Mohamed : Team Lead
- Amr Khaled
- Rawda Ellithy
- Aya Emad
- Shrouk Atef : UI/UX Design

## License

No license file is included, so all rights are reserved unless a license is added.