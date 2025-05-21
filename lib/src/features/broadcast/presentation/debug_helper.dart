import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logging/logging.dart';
import 'package:lavie/src/features/broadcast/presentation/mock_camera_service.dart';
import 'package:uvccamera/uvccamera.dart';

/// Provider to control debug mode state
final debugModeProvider = StateProvider<bool>((ref) => false);

/// Widget overlay hiển thị các điều khiển debug
class DebugControls extends ConsumerWidget {
  const DebugControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebugMode = ref.watch(debugModeProvider);
    final mockService = ref.read(mockCameraServiceProvider);

    if (!isDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 100,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: Colors.black87,
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Debug Controls',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(color: Colors.white30),
              const SizedBox(height: 8),
              
              _buildDebugButton(
                'Mock Device',
                mockService.isOverriding,
                () {
                  mockService.setOverrideMode(!mockService.isOverriding);
                },
              ),
              
              const SizedBox(height: 8),
              _buildDebugButton(
                'Test Error',
                false,
                () async {
                  final devices = await mockService.getMockDevices();
                  if (devices.isNotEmpty) {
                    final device = devices.values.first;
                    mockService.simulateCameraError('Test camera error');
                  }
                },
              ),
              
              const SizedBox(height: 8),
              _buildDebugButton(
                'Disconnect',
                false,
                () async {
                  final devices = await mockService.getMockDevices();
                  if (devices.isNotEmpty) {
                    final device = devices.values.first;
                    mockService.simulateDeviceDisconnected(device);
                  }
                },
              ),
              
              const SizedBox(height: 8),
              _buildDebugButton(
                'Reconnect',
                false,
                () async {
                  final devices = await mockService.getMockDevices();
                  if (devices.isNotEmpty) {
                    final device = devices.values.first;
                    await mockService.simulateDeviceAttached(device);
                    await Future.delayed(const Duration(milliseconds: 500));
                    await mockService.simulateDeviceConnected(device);
                  }
                },
              ),
              
              const SizedBox(height: 8),
              _buildDebugButton(
                'Fallback Stream',
                false,
                () async {
                  // Tạo một luồng giả lập chỉ có âm thanh
                  await mockService.createMockMediaStream(
                    includeVideo: false,
                    includeAudio: true,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebugButton(String label, bool isActive, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.green : Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          textStyle: const TextStyle(fontSize: 12),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Mixin that provides debug mode toggling and debug controls UI
mixin DebugModeToggle<T extends StatefulWidget> on State<T> {
  final Logger _logger = Logger('DebugModeToggle');
  bool _debugMode = false;
  int _tapCount = 0;
  Timer? _tapTimer;
  
  /// Ref for accessing providers - must be set by the implementing class
  late WidgetRef ref;
  
  /// Static helper method to set the ref from the state class
  static void setRef(DebugModeToggle instance, WidgetRef widgetRef) {
    instance.ref = widgetRef;
  }
  
  @override
  void dispose() {
    _tapTimer?.cancel();
    super.dispose();
  }
  
  /// Toggle debug mode
  void toggleDebugMode() {
    _logger.info('Toggling debug mode: ${!_debugMode}');
    _debugMode = !_debugMode;
    ref.read(debugModeProvider.notifier).state = _debugMode;
    
    // Enable mock camera service if debug mode is on
    ref.read(mockCameraServiceProvider).setOverrideMode(_debugMode);
    
    setState(() {});
  }
  
  /// Build a transparent area that detects taps to toggle debug mode
  Widget buildDebugTapArea() {
    return Positioned(
      right: 0,
      top: 0,
      width: 100,
      height: 100,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _tapCount++;
          _logger.fine('Debug area tap detected: $_tapCount');
          
          _tapTimer?.cancel();
          _tapTimer = Timer(const Duration(milliseconds: 500), () {
            if (_tapCount >= 5) {
              toggleDebugMode();
            }
            _tapCount = 0;
          });
        },
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }
  
  /// Build debug controls overlay
  Widget buildDebugControls(BuildContext context) {
    if (!_debugMode) return const SizedBox.shrink();
    
    final mockService = ref.read(mockCameraServiceProvider);
    
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 10,
      child: Material(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Debug Controls', 
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white)),
              const Divider(color: Colors.white30),
              const SizedBox(height: 8),
              
              // Mock device controls
              Text('Mock Camera', 
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final devices = await mockService.getMockDevices();
                      if (devices.isNotEmpty) {
                        await mockService.simulateDeviceAttached(devices.values.first);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 30),
                    ),
                    child: const Text('Attach', style: TextStyle(fontSize: 12)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final devices = await mockService.getMockDevices();
                      if (devices.isNotEmpty) {
                        await mockService.simulateDeviceDetached(devices.values.first);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 30),
                    ),
                    child: const Text('Detach', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Error simulation
              Text('Simulate Errors', 
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () {
                  mockService.simulateCameraError('Mock camera error');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 30),
                ),
                child: const Text('Camera Error', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Check if debug mode is enabled
  bool get isDebugMode => _debugMode;
}

/// Extension để thêm debug controls vào Scaffold
extension DebugScaffold on Scaffold {
  Scaffold withDebugControls() {
    return Scaffold(
      body: Stack(
        children: [
          body ?? const SizedBox.shrink(),
          const DebugControls(),
        ],
      ),
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
    );
  }
} 