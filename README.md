# Lavie - UVC Camera Streaming App

A Flutter application for streaming UVC camera feed using WebRTC.

## Overview

This application allows users to stream video from UVC cameras and view other broadcasters' streams. The app has been updated to simplify the user experience by automatically detecting connected UVC cameras without requiring explicit device registration.

## Key Features

- **Automatic UVC Camera Detection**: The app now automatically detects UVC cameras connected to the device
- **Direct Camera Selection**: Broadcasters can select a camera directly from the list of detected devices
- **Real-time Streaming**: Uses WebRTC for low-latency video streaming
- **Interactive Viewer Experience**: Viewers can send vibration signals to broadcasters
- **User Management**: Admin dashboard to manage users and view active streams

## Role-based Access

The application supports three user roles:

1. **Broadcaster**: Can select a UVC camera and broadcast video streams
2. **Viewer**: Can view active broadcasts and send signals to broadcasters
3. **Admin**: Can manage users and monitor active streams

## Technical Changes

Recent updates include:

- Removed device registration step for broadcasters
- Implemented automatic detection of connected UVC cameras
- Simplified the broadcasting workflow
- Updated admin dashboard to show active streams instead of device list
- Removed device pairing screen and device database table
- Improved direct camera selection interface

## Getting Started

This project is built with Flutter. To get started:

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Set up Firebase project with Firestore
4. Connect a UVC camera to your device
5. Run the application with `flutter run`

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
