# Lavie - Camera OTG App with Screen Sharing

Lavie is a Flutter application that enables OTG camera connectivity and screen sharing between paired devices.

## Features

### Authentication
- Admin account with the ability to create new user accounts
- Two types of user accounts:
  - Broadcaster: Connects to OTG camera and shares screen
  - Viewer: Watches the broadcast and can send vibration signals

### Camera OTG
- Connect to an OTG camera device
- Live camera feed display
- Camera controls (flip camera)

### Screen Sharing
- Real-time screen sharing between paired devices using WebRTC
- One account can log in on two different devices (broadcaster and viewer)
- Each account is limited to 2 devices only

### Remote Control
- Viewer can send vibration signals to the broadcaster device
- Two vibration patterns available:
  - Single vibration
  - Double vibration

## Technical Stack

- Flutter (UI framework)
- Firebase Authentication (user management)
- Cloud Firestore (real-time database)
- WebRTC (peer-to-peer communication)
- Camera plugin (camera access)
- Vibration plugin (haptic feedback)

## Getting Started

### To run automatic build on code changes

``` bash
dart run build_runner watch
```

### To build localization file

``` bash
flutter gen-l10n
```

## Setup Instructions

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to the project
   - Download and place the configuration files
4. Run the app using `flutter run`

## Admin Account

Default admin credentials:
- Email: admin@lavie.com
- Password: Admin@123

## Usage Flow

1. Admin logs in and creates broadcaster and viewer accounts
2. Broadcaster logs in on a device with OTG camera
3. Viewer logs in on another device
4. Broadcaster starts streaming camera feed
5. Viewer connects to the broadcast
6. Viewer can send vibration signals to the broadcaster

## Assets

The `assets` directory houses images, fonts, and any other files you want to
include with your application.

The `assets/images` directory contains [resolution-aware
images](https://flutter.dev/docs/development/ui/assets-and-images#resolution-aware).

## Localization

This project generates localized messages based on arb files found in
the `lib/src/localization` directory.

To support additional languages, please visit the tutorial on
[Internationalizing Flutter
apps](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
