# bookdonationapp

A new Flutter project.

## Firestore — `users` profiles

The app merges public fields into `users/{uid}` on sign-in (see `UserFirestoreService`).
Add rules so only the signed-in user can write their own document, for example:

```text
match /users/{userId} {
  allow read: if request.auth != null;
  allow create, update: if request.auth != null && request.auth.uid == userId;
  allow delete: if false;
}
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
