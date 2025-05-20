import 'package:flutter/material.dart';
import 'uvccamera_devices_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UvcCameraApp());
}

class UvcCameraApp extends StatelessWidget {
  const UvcCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UVC Camera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const UvcCameraDevicesScreen(),
    );
  }
}
