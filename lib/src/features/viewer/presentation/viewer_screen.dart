import 'dart:async';
import 'dart:math';

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
  bool _isLoading = true;
  bool _isConnecting = false;
  String? _errorMessage;
  bool _isStreamActive = false;
  WebRTCConnectionService? _webRTCService;
  RTCVideoRenderer? _remoteRenderer;
  List<Map<String, dynamic>> _activeStreams = [];
  String? _selectedBroadcasterId;
  String? _selectedBroadcasterName;
  Timer? _staticNoiseTimer;
  Random _random = Random();
  bool _isFallbackMode = false;
  
  @override
  void initState() {
    super.initState();
    _initializeWebRTC();
  }
  
  @override
  void dispose() {
    _cleanupWebRTC();
    _staticNoiseTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _initializeWebRTC() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
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
            setState(() {
              _isStreamActive = true;
              _isFallbackMode = false;
              
              // Ngừng timer hiệu ứng nhiễu nếu có
              _staticNoiseTimer?.cancel();
            });
          }
        };
        
        // Xử lý thông báo khi stream được thiết lập nhưng không có media (fallback mode)
        _webRTCService!.onNoMediaStreamAvailable = () {
          // Đánh dấu stream đang hoạt động nhưng ở chế độ fallback
          setState(() {
            _isStreamActive = true;
            _isFallbackMode = true;
            
            // Bắt đầu timer để cập nhật hiệu ứng nhiễu
            _startStaticNoiseTimer();
          });
        };
        
        // Listen for active streams
        _webRTCService!.onAvailableStreamsChanged = (streams) {
          setState(() {
            _activeStreams = streams;
          });
        };
        
        await _refreshActiveStreams();
        
        // Start listening for active streams
        _webRTCService!.listenForActiveStreams();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khởi tạo: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _startStaticNoiseTimer() {
    // Hủy timer cũ nếu có
    _staticNoiseTimer?.cancel();
    
    // Tạo timer mới cập nhật mỗi 200ms để tạo hiệu ứng nhiễu
    _staticNoiseTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (mounted && _isFallbackMode) {
        setState(() {
          // Chỉ trigger rebuild để vẽ lại nhiễu
          _random = Random();
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  Future<void> _refreshActiveStreams() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      if (_webRTCService != null) {
        final streams = await _webRTCService!.getActiveStreams();
        setState(() {
          _activeStreams = streams;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải danh sách phát sóng: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _cleanupWebRTC() {
    _remoteRenderer?.dispose();
    _remoteRenderer = null;
    _webRTCService?.dispose();
    _webRTCService = null;
    _staticNoiseTimer?.cancel();
    _staticNoiseTimer = null;
  }
  
  Future<void> _connectToStream(String broadcasterId, String broadcasterName) async {
    if (_isConnecting) return;
    
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _isStreamActive = false; // Reset stream status
    });
    
    try {
      await _webRTCService!.startViewing(broadcasterId);
      
      setState(() {
        _selectedBroadcasterId = broadcasterId;
        _selectedBroadcasterName = broadcasterName;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã kết nối với phát sóng'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi kết nối: ${e.toString()}';
        _selectedBroadcasterId = null;
        _selectedBroadcasterName = null;
        _isStreamActive = false;
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
  
  Future<void> _disconnectFromStream() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });
    
    try {
      if (_webRTCService != null) {
        await _webRTCService!.stopViewing();
      }
      
      setState(() {
        _selectedBroadcasterId = null;
        _selectedBroadcasterName = null;
        _isStreamActive = false;
        _isFallbackMode = false;
      });
      
      // Hủy timer nếu đang chạy
      _staticNoiseTimer?.cancel();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã ngắt kết nối'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi ngắt kết nối: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }
  
  Future<void> _sendVibrationSignal(int count) async {
    if (_selectedBroadcasterId == null || !_isStreamActive) {
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
      await _webRTCService!.sendVibrationToBroadcaster(_selectedBroadcasterId!, count);
      
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
            onPressed: _refreshActiveStreams,
          ),
        ],
      ),
      body: _selectedBroadcasterId == null
          ? _buildStreamSelectionView()
          : _buildStreamView(),
    );
  }
  
  Widget _buildStreamSelectionView() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshActiveStreams,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    
    if (_activeStreams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Không có phát sóng nào',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hiện tại không có phát sóng nào đang hoạt động.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshActiveStreams,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
            ),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phát sóng đang hoạt động',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _activeStreams.length,
              itemBuilder: (context, index) {
                final stream = _activeStreams[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(Icons.videocam, color: Colors.white),
                    ),
                    title: Text(stream['broadcasterName'] ?? 'Không có tên'),
                    subtitle: const Text('Đang phát sóng'),
                    trailing: ElevatedButton(
                      onPressed: () => _connectToStream(
                        stream['broadcasterId'],
                        stream['broadcasterName'] ?? 'Không có tên',
                      ),
                      child: const Text('Xem'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStreamView() {
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
                      _selectedBroadcasterName ?? 'Người phát sóng',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isStreamActive ? 'Đang phát sóng' : 'Đang chờ kết nối',
                      style: TextStyle(
                        color: _isStreamActive ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _disconnectFromStream,
                child: const Text('Ngắt kết nối'),
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
            child: _isStreamActive 
                ? (_isFallbackMode 
                    ? _buildFallbackStreamView() 
                    : (_remoteRenderer != null 
                        ? RTCVideoView(
                            _remoteRenderer!,
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          )
                        : const Center(child: CircularProgressIndicator())))
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.hourglass_empty,
                          size: 64,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Đang chờ phát sóng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Người phát sóng hiện đang ngoại tuyến',
                          style: TextStyle(
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
  
  // Widget hiển thị khi có phát sóng fallback (không có media)
  Widget _buildFallbackStreamView() {
    return Stack(
      children: [
        // Hiệu ứng nhiễu tĩnh
        CustomPaint(
          painter: StaticNoisePainter(_random),
          size: Size.infinite,
        ),
        
        // Overlay thông báo
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.videocam_off,
                  size: 64,
                  color: Colors.orange,
                ),
                SizedBox(height: 16),
                Text(
                  'Phát sóng ở chế độ dự phòng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Người phát sóng đang gặp vấn đề với camera\n'
                  'nhưng vẫn đang phát sóng.\n\n'
                  'Bạn vẫn có thể gửi tín hiệu rung như bình thường.',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Painter tạo hiệu ứng nhiễu tĩnh cho chế độ fallback
class StaticNoisePainter extends CustomPainter {
  final Random random;
  
  StaticNoisePainter(this.random);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    // Vẽ nền đen
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Vẽ các điểm nhiễu trắng ngẫu nhiên
    for (int i = 0; i < 3000; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double pointSize = random.nextDouble() * 2 + 1;
      int alpha = random.nextInt(100) + 155; // 155-255 (đậm hơn)
      
      final noisePaint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, alpha / 255)
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(Rect.fromLTWH(x, y, pointSize, pointSize), noisePaint);
    }
    
    // Thêm một số đường kẻ ngang và dải nhiễu lớn hơn
    if (random.nextInt(5) == 0) { // 20% cơ hội xuất hiện
      double y = random.nextDouble() * size.height;
      double height = random.nextDouble() * 8 + 2;
      
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, height), linePaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 