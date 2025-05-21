import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/device/data/device_service.dart';
import 'package:lavie/src/features/webrtc/data/webrtc_connection_service.dart';
import 'package:lavie/src/theme/app_theme.dart';

@RoutePage()
class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({super.key});

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  DeviceModel? _connectedDevice;
  StreamSubscription? _deviceStreamSubscription;
  bool _isConnecting = false;
  String? _errorMessage;
  bool _isStreamActive = false;
  WebRTCConnectionService? _webRTCService;
  RTCVideoRenderer? _remoteRenderer;
  
  @override
  void initState() {
    super.initState();
    _initializeWebRTC();
    _checkForConnectedDevice();
  }
  
  @override
  void dispose() {
    _cleanupWebRTC();
    _deviceStreamSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _initializeWebRTC() async {
    _remoteRenderer = RTCVideoRenderer();
    await _remoteRenderer!.initialize();
    
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _webRTCService = ref.read(webRTCConnectionServiceProvider(
        WebRTCConnectionParams(
          userId: user.id,
          isBroadcaster: false,
        ),
      ));
      
      _webRTCService!.onRemoteStreamAvailable = (stream) {
        if (_remoteRenderer != null) {
          _remoteRenderer!.srcObject = stream;
          setState(() {});
        }
      };
    }
  }
  
  void _cleanupWebRTC() {
    _remoteRenderer?.dispose();
    _remoteRenderer = null;
    _webRTCService?.dispose();
    _webRTCService = null;
  }
  
  Future<void> _checkForConnectedDevice() async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.pairedDeviceId == null) return;
    
    try {
      final device = await ref.read(deviceServiceProvider).getDevice(user.pairedDeviceId!);
      if (device != null) {
        setState(() {
          _connectedDevice = device;
        });
        _listenForDeviceChanges();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get device: ${e.toString()}';
      });
    }
  }
  
  void _listenForDeviceChanges() {
    final user = ref.read(currentUserProvider);
    if (user == null || user.pairedDeviceId == null) return;
    
    _deviceStreamSubscription?.cancel();
    
    _deviceStreamSubscription = ref
        .read(deviceServiceProvider)
        .deviceStream(user.pairedDeviceId!)
        .listen((device) {
      if (device == null) {
        setState(() {
          _connectedDevice = null;
          _isStreamActive = false;
        });
        return;
      }
      
      setState(() {
        _connectedDevice = device;
        _isStreamActive = device.isBroadcasting;
      });
      
      // Connect to WebRTC stream if broadcasting started
      if (device.isBroadcasting && !_isConnecting && _webRTCService != null) {
        _connectToStream(device.id);
      }
    });
  }
  
  Future<void> _connectToStream(String broadcasterId) async {
    if (_isConnecting) return;
    
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });
    
    try {
      await _webRTCService!.startViewing(broadcasterId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã kết nối với phát sóng'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi kết nối: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi kết nối: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }
  
  Future<void> _sendVibrationSignal(int count) async {
    if (_connectedDevice == null || !_isStreamActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể gửi tín hiệu: Không có phát sóng đang hoạt động'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });
    
    try {
      await _webRTCService!.sendVibrationToBroadcaster(_connectedDevice!.id, count);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã gửi ${count == 1 ? 'một' : 'hai'} tín hiệu rung'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi gửi tín hiệu: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi gửi tín hiệu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Chưa đăng nhập'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Người xem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkForConnectedDevice,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.router.pushNamed('/device-pairing'),
          ),
        ],
      ),
      body: user.pairedDeviceId == null
          ? _buildNoPairedDeviceView()
          : _buildStreamView(),
    );
  }
  
  Widget _buildNoPairedDeviceView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 24),
          Text(
            'Chưa có phiên Live nào',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Hiện tại bạn chưa có phiên Live nào có thể xem được.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStreamView() {
    if (_connectedDevice == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Column(
      children: [
        // Status card
        Container(
          padding: const EdgeInsets.all(16),
          color: _isStreamActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _isStreamActive ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _connectedDevice!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isStreamActive ? 'Đang phát sóng' : 'Đang chờ phát sóng',
                      style: TextStyle(
                        color: _isStreamActive ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isStreamActive)
                OutlinedButton(
                  onPressed: _checkForConnectedDevice,
                  child: const Text('Làm mới'),
                ),
            ],
          ),
        ),
        
        // Error message
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.withOpacity(0.1),
            width: double.infinity,
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        
        // Video stream
        Expanded(
          child: Container(
            color: Colors.black,
            child: _isStreamActive && _remoteRenderer != null
                ? RTCVideoView(
                    _remoteRenderer!,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isStreamActive ? Icons.videocam : Icons.hourglass_empty,
                          size: 64,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isStreamActive ? 'Đang kết nối...' : 'Đang chờ phát sóng',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isStreamActive
                              ? 'Đang thiết lập kết nối video...'
                              : 'Người phát sóng hiện đang ngoại tuyến',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        
        // Vibration controls
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Gửi tín hiệu đến người phát sóng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isStreamActive && !_isConnecting
                          ? () => _sendVibrationSignal(1)
                          : null,
                      icon: const Icon(Icons.vibration),
                      label: const Text('Rung một lần'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isStreamActive && !_isConnecting
                          ? () => _sendVibrationSignal(2)
                          : null,
                      icon: const Icon(Icons.vibration),
                      label: const Text('Rung hai lần'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _isStreamActive
                    ? 'Gửi tín hiệu rung để thông báo cho người phát sóng'
                    : 'Chờ phát sóng bắt đầu trước khi gửi tín hiệu',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 