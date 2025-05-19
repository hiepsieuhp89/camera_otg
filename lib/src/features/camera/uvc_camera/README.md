# UVC Camera Integration

This module integrates external UVC (USB Video Class) cameras with the application using the [flutter_uvc_camera](https://github.com/chenyeju295/flutter_uvc_camera) package.

## Features

- Connect to external USB cameras
- Display live camera preview
- Take photos and record videos
- Control camera resolution

## Prerequisites

- Android device with USB OTG support
- External UVC-compatible camera

## Configuration

The following configurations have been applied:

1. **AndroidManifest.xml**: Required permissions and USB device filters
2. **build.gradle**: Target SDK version set to 27 for better compatibility
3. **proguard-rules.pro**: ProGuard rules to prevent obfuscation of native UVC libraries

## Known Limitations

- Only works on Android (iOS not supported)
- Some Android devices may require user permission on each connection
- For Android 10+, using targetSdkVersion 27 is recommended

## Troubleshooting

If the camera is not detected:

1. Check USB connection and cable
2. Ensure device supports USB OTG
3. Verify the camera is UVC compatible
4. Try disconnecting and reconnecting the camera

For recording issues, check storage permissions and available space.

## References

- [Flutter UVC Camera GitHub Repository](https://github.com/chenyeju295/flutter_uvc_camera)
- [UVC Camera Compatibility List](https://uvccamera.org/) 