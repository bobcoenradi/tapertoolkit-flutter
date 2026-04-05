# The Taper Toolkit — Setup Guide

## 1. Firebase Setup
Run FlutterFire CLI to connect your Firebase project:
```
dart pub global activate flutterfire_cli
flutterfire configure
```
Then in `lib/main.dart`, uncomment the Firebase imports and `initializeApp` call, and uncomment the `AuthGate` StreamBuilder.

## 2. Sanity Studio
Create a new Sanity project:
```
npm create sanity@latest -- --template clean --project-id YOUR_ID --dataset production
```

### Content Types to create in Sanity:
- **article** — title, excerpt, category, readTime, coverImage, slug, body (Portable Text)
- **newsItem** — title, excerpt, tag, publishedAt, coverImage, slug, body
- **glossaryTerm** — term, definition
- **faq** — question, answer, category, order
- **dailyTip** — tip, icon, order
- **checklistItem** — title, description, category, order
- **communityTopic** — title, description, icon, order

Update `lib/services/sanity_service.dart` with your real project ID.

## 3. Firestore Rules (basic)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      match /{sub=**} { allow read, write: if request.auth.uid == userId; }
    }
    match /communityPosts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['likes']);
    }
  }
}
```

## 4. Run
```
cd taper_toolkit_app
flutter run
```
