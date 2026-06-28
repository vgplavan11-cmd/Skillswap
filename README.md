```markdown
# 🚀 SkillSwap – Peer-to-Peer Skill Exchange Platform

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

SkillSwap is a modern cross-platform mobile application that enables users to exchange skills with one another **without any monetary transactions**. Instead of paying for courses, users teach the skills they already know and learn new ones from others.

Built using **Flutter** and **Firebase**, SkillSwap offers real-time communication, smart skill matching, session scheduling, AI-powered recommendations, notifications, ratings, and a beautiful modern UI.

---

# 📖 Table of Contents

- About
- Features
- Application Workflow
- System Architecture
- Technology Stack
- Project Structure
- Installation
- Firebase Setup
- Database Collections
- Core Modules
- Security
- Future Enhancements
- Screens
- Contributors
- License

---

# 📌 About

SkillSwap is a peer-to-peer learning platform where users can:

- Teach their expertise
- Learn new skills
- Find suitable mentors
- Schedule learning sessions
- Chat in real time
- Rate completed sessions
- Earn badges and rankings

The application removes financial barriers from learning by allowing users to exchange knowledge instead of money.

---

# ✨ Features

## Authentication

- Email & Password Login
- Google Sign-In
- Forgot Password
- Secure Authentication
- Persistent Login

---

## User Profile

- Upload Profile Photo
- Edit Personal Information
- Add Skills to Teach
- Add Skills to Learn
- Experience & Bio

---

## Smart Skill Matching

The matching system compares:

- Offered Skills
- Requested Skills

It automatically suggests users who can mutually help each other.

---

## Real-Time Chat

- Instant Messaging
- Read Status
- Conversation History
- Real-Time Synchronization

---

## Session Scheduler

Users can

- Create Sessions
- Schedule Meetings
- View Upcoming Sessions
- Mark Sessions Completed

---

## AI Features

- Skill Recommendations
- Learning Suggestions
- Profile Improvement Tips
- Personalized Matching

---

## Reviews & Ratings

After every completed session:

- Rate Partner
- Write Review
- Build Reputation

---

## Leaderboard

- Earn Points
- Unlock Badges
- Track Rankings

---

## Push Notifications

Receive notifications for

- New Match
- New Chat
- Session Reminder
- Review Request
- Admin Updates

---

## Admin Dashboard

Admin can

- View Users
- Monitor Sessions
- Manage Platform
- View Analytics

---

# 🔄 Complete Application Workflow

## Step 1

User installs the application.

↓

Launches SkillSwap.

↓

Splash Screen appears.

↓

Onboarding Screens.

↓

Register/Login.

---

## Step 2

Firebase Authentication verifies user credentials.

↓

If successful

↓

User profile is loaded from Firestore.

↓

Dashboard opens.

---

## Step 3

User completes profile.

- Name
- Bio
- Skills Offered
- Skills Wanted
- Profile Image

↓

Information stored inside Firestore.

---

## Step 4

Matching Engine starts.

It compares

```

Skills I Teach

```
    ↕
```

Skills Others Want

```
    ↕
```

Mutual Match Found

```
    ↕
```

Suggested Connection

```

---

## Step 5

User sends connection request.

↓

Other user accepts.

↓

Chat Room created.

↓

Users communicate.

---

## Step 6

Users schedule a learning session.

↓

Session stored in Firestore.

↓

Reminder notification sent.

---

## Step 7

Users attend session.

↓

Session marked completed.

↓

Review screen opens.

↓

Ratings updated.

↓

Leaderboard refreshed.

---

# 🏛 System Architecture

```

```
                Flutter Mobile App

                       │

                Provider State Management

                       │

                Service Layer

                       │

      Firebase SDK (FlutterFire)

  ┌──────────────┬───────────────┬───────────────┐
  │              │               │
```

Authentication   Firestore      Storage
│              │               │
└──────────────┴───────────────┘
│
Firebase Cloud Messaging

```
               │
      Firebase Analytics
```

```

---

# 🛠 Technology Stack

## Frontend

| Technology | Purpose |
|------------|---------|
| Flutter | Cross Platform Framework |
| Dart | Programming Language |
| Material Design | UI Components |

---

## Backend

| Technology | Purpose |
|------------|---------|
| Firebase Core | Firebase Initialization |
| Firebase Authentication | Authentication |
| Cloud Firestore | Database |
| Firebase Storage | Image Storage |
| Firebase Cloud Messaging | Notifications |
| Firebase Analytics | Analytics |

---

## State Management

- Provider

---

## Third-Party Packages

- provider
- firebase_core
- firebase_auth
- cloud_firestore
- firebase_storage
- firebase_messaging
- firebase_analytics
- google_sign_in
- image_picker
- google_fonts
- intl
- uuid
- http
- url_launcher
- font_awesome_flutter

---

# 📂 Project Structure

```

lib/

│

├── main.dart

├── firebase_options.dart

│

├── models/

│     ├── user_model.dart

│     ├── skill_model.dart

│     ├── session_model.dart

│     ├── review_model.dart

│     └── chat_model.dart

│

├── providers/

│     ├── auth_provider.dart

│     ├── theme_provider.dart

│     ├── chat_provider.dart

│     ├── session_provider.dart

│     └── matching_provider.dart

│

├── services/

│     ├── auth_service.dart

│     ├── firestore_service.dart

│     ├── chat_service.dart

│     ├── matching_service.dart

│     ├── notification_service.dart

│     └── ai_service.dart

│

├── screens/

│     ├── auth/

│     ├── home/

│     ├── profile/

│     ├── sessions/

│     ├── chat/

│     ├── leaderboard/

│     ├── admin/

│     └── settings/

│

└── widgets/

```
  ├── custom_button.dart

  ├── custom_card.dart

  ├── mentor_tile.dart

  └── loading_widget.dart
```

````

---

# ⚙ Installation

## Clone Repository

```bash
git clone https://github.com/yourusername/SkillSwap.git
````

---

## Open Folder

```bash
cd SkillSwap
```

---

## Install Packages

```bash
flutter pub get
```

---

## Run Application

```bash
flutter run
```

---

# 🔥 Firebase Setup

Create a Firebase project and enable:

* Firebase Authentication
* Cloud Firestore
* Firebase Storage
* Firebase Cloud Messaging
* Firebase Analytics

Download:

```
google-services.json
```

Place inside

```
android/app/
```

For iOS

```
GoogleService-Info.plist
```

Place inside

```
ios/Runner/
```

---

# 🗄 Firestore Collections

```
users/

skills/

matches/

chat_rooms/

messages/

sessions/

reviews/

badges/

notifications/
```

---

# 📊 Core Modules

### Authentication

* Login
* Register
* Google Login

---

### Profile

* User Details
* Skills
* Photo

---

### Matching

* Skill Comparison
* Mutual Matching

---

### Chat

* Real-Time Messaging

---

### Sessions

* Schedule
* Update
* Complete

---

### Reviews

* Rating
* Feedback

---

### Notifications

* Push Notifications

---

### AI Module

* Personalized Suggestions
* Smart Recommendations

---

# 🔐 Security

* Firebase Authentication
* Firestore Security Rules
* Secure Cloud Storage
* User-based Access Control
* Protected API Access

---

# 📱 Supported Platforms

* ✅ Android
* ✅ iOS
* ✅ Web (Flutter Supported)

---

# 🚀 Future Enhancements

* Video Calling
* Voice Chat
* Certificate Generation
* Calendar Integration
* AI Mentor Assistant
* Skill Verification
* Multi-language Support
* Offline Mode
* Community Groups
* Discussion Forums

---

# 📷 Application Screens

* Splash Screen
* Onboarding
* Login
* Registration
* Dashboard
* Profile
* Skill Matching
* Chat
* Sessions
* Notifications
* Leaderboard
* Settings
* Admin Dashboard

---

# 👨‍💻 Contributors

Developed as an EdTech Flutter application for peer-to-peer skill exchange.

---

# 📄 License

This project is licensed under the MIT License.

---

# ⭐ If you like this project

Give it a ⭐ on GitHub and contribute to make learning accessible for everyone.

```
"Learn Together • Teach Together • Grow Together"
```

```
```
