import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/device/data/device_service.dart';
import 'package:lavie/src/theme/app_theme.dart';
import 'package:uvccamera/uvccamera.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> {
  bool _isBroadcasting = false;
  bool _isCameraConnected = false;
  bool _isInitializing = true;
  String? _errorMessage;
  StreamSubscription? _signalSubscription;
  final List<VibrationSignal> _recentSignals = [];
  UvcCameraController? _cameraController;
  UvcCameraDevice? _selectedDevice;
  Timer? _statusUpdateTimer;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startListeningForSignals();
  }
  
  @override
  void dispose() {
    _cleanupCamera();
    _signalSubscription?.cancel();
    _statusUpdateTimer?.cancel();
    super.dispose();
  }
  
  void _cleanupCamera() {
    _cameraController?.dispose();
    _cameraController = null;
  }
  
  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });
    
    try {
      // Check camera permissions
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          throw Exception('Quyền truy cập camera bị từ chối');
        }
      }
      
      // Check if UVC camera is supported
      final isSupported = await UvcCamera.isSupported();
      if (!isSupported) {
        throw Exception('Thiết bị không hỗ trợ camera UVC');
      }
      
      // Get list of cameras
      final devices = await UvcCamera.getDevices();
      if (devices.isEmpty) {
        throw Exception('Không tìm thấy camera UVC');
      }
      
      // Use the first camera
      _selectedDevice = devices.values.first;
      
      // Request device permission
      final hasPermission = await UvcCamera.requestDevicePermission(_selectedDevice!);
      if (!hasPermission) {
        throw Exception('Quyền truy cập thiết bị bị từ chối');
      }
      
      // Initialize camera controller
      _cameraController = UvcCameraController(device: _selectedDevice!);
      await _cameraController!.initialize();
      
      setState(() {
        _isCameraConnected = true;
      });
      
      // Start periodic status updates
      _startStatusUpdates();
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khởi tạo camera: ${e.toString()}';
        _isCameraConnected = false;
      });
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }
  
  void _startStatusUpdates() {
    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateDeviceStatus();
    });
  }
  
  Future<void> _updateDeviceStatus() async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null || user.pairedDeviceId == null) return;
      
      final deviceService = ref.read(deviceServiceProvider);
      await deviceService.updateDeviceStatus(
        user.pairedDeviceId!,
        isActive: true,
        isBroadcasting: _isBroadcasting,
      );
    } catch (e) {
      // Silently handle failure, will retry on next timer
      print('Failed to update device status: $e');
    }
  }
  
  Future<void> _startBroadcasting() async {
    if (!_isCameraConnected || _cameraController == null || !_cameraController!.value.isInitialized) {
      setState(() {
        _errorMessage = 'Camera chưa được kết nối hoặc khởi tạo';
      });
      return;
    }
    
    setState(() {
      _errorMessage = null;
    });
    
    try {
      final user = ref.read(currentUserProvider);
      if (user == null || user.pairedDeviceId == null) {
        throw Exception('Chưa ghép nối với thiết bị');
      }
      
      // Update device status in Firestore
      final deviceService = ref.read(deviceServiceProvider);
      await deviceService.startBroadcasting(user.pairedDeviceId!);
      
      // Update local state
      setState(() {
        _isBroadcasting = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã bắt đầu phát sóng'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi bắt đầu phát sóng: ${e.toString()}';
      });
    }
  }
  
  Future<void> _stopBroadcasting() async {
    setState(() {
      _errorMessage = null;
    });
    
    try {
      final user = ref.read(currentUserProvider);
      if (user == null || user.pairedDeviceId == null) {
        throw Exception('Chưa ghép nối với thiết bị');
      }
      
      // Update device status in Firestore
      final deviceService = ref.read(deviceServiceProvider);
      await deviceService.stopBroadcasting(user.pairedDeviceId!);
      
      // Update local state
      setState(() {
        _isBroadcasting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã dừng phát sóng'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi dừng phát sóng: ${e.toString()}';
      });
    }
  }
  
  void _startListeningForSignals() {
    final user = ref.read(currentUserProvider);
    if (user == null || user.pairedDeviceId == null) return;
    
    final deviceService = ref.read(deviceServiceProvider);
    _signalSubscription = deviceService
        .vibrationSignalsStream(user.pairedDeviceId!)
        .listen(_handleVibrationSignal);
  }
  
  void _handleVibrationSignal(List<VibrationSignal> signals) {
    if (signals.isEmpty) return;
    
    // Get the newest signal
    final latestSignal = signals.first;
    
    // Only process if we haven't seen this signal before
    if (_recentSignals.any((s) => s.id == latestSignal.id)) return;
    
    // Add to recent signals
    setState(() {
      _recentSignals.insert(0, latestSignal);
      if (_recentSignals.length > 10) {
        _recentSignals.removeLast();
      }
    });
    
    // Vibrate the device
    _vibrateDevice(latestSignal.count);
    
    // Show notification
    _showVibrationNotification(latestSignal);
  }
  
  Future<void> _vibrateDevice(int count) async {
    try {
      for (int i = 0; i < count; i++) {
        await HapticFeedback.heavyImpact();
        if (i < count - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      print('Failed to vibrate device: $e');
    }
  }
  
  void _showVibrationNotification(VibrationSignal signal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã nhận ${signal.count} rung', 
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final hasNoDevice = user == null || user.pairedDeviceId == null;
    
    if (hasNoDevice) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Phát sóng'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Chưa ghép nối thiết bị',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.router.pushNamed('/device-pairing'),
                child: const Text('Ghép nối thiết bị'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phát sóng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.router.pushNamed('/device-pairing'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Camera preview
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isInitializing
                  ? const Center(child: CircularProgressIndicator())
                  : _isCameraConnected && _cameraController != null && _cameraController!.value.isInitialized
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: UvcCameraPreview(_cameraController!),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.videocam_off,
                                size: 48,
                                color: Colors.white54,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Camera chưa kết nối',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _initializeCamera,
                                child: const Text('Kết nối lại'),
                              ),
                            ],
                          ),
                        ),
            ),
            
            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            ],
            
            // Status card
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.zero,
              color: _isBroadcasting ? Colors.green.shade50 : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isBroadcasting ? Icons.sensors : Icons.sensors_off,
                          color: _isBroadcasting ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Trạng thái: ${_isBroadcasting ? 'Đang phát sóng' : 'Ngoại tuyến'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isBroadcasting ? Colors.green : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thiết bị: ${user.pairedDeviceId}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (_selectedDevice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Camera: ${_selectedDevice!.name}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isBroadcasting) ...[
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _stopBroadcasting,
                              icon: const Icon(Icons.stop),
                              label: const Text('Dừng phát sóng'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isCameraConnected ? _startBroadcasting : null,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Bắt đầu phát sóng'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Recent signals
            const SizedBox(height: 24),
            const Text(
              'Tín hiệu gần đây',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _recentSignals.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Chưa nhận được tín hiệu nào. Khi người xem gửi rung, nó sẽ xuất hiện ở đây.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentSignals.length,
                    itemBuilder: (context, index) {
                      final signal = _recentSignals[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(signal.count.toString()),
                        ),
                        title: Text(
                          '${signal.count} rung',
                        ),
                        subtitle: Text(
                          _formatTimestamp(signal.timestamp),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
} 