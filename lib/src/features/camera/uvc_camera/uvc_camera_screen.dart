import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/core/utils/logger_service.dart';

// Platform channel for UVC camera communication with Kotlin
const MethodChannel _channel = MethodChannel('com.lavie.app/uvc_camera');

// Provider để quản lý UVC camera state
final uvcCameraStateProvider = StateNotifierProvider<UVCCameraStateNotifier, UVCCameraState>((ref) {
  return UVCCameraStateNotifier();
});

// State class for UVC camera
class UVCCameraState {
  final bool isOpen;
  final bool isRecording;
  final String statusMessage;
  final List<Map<String, dynamic>> resolutions;
  final Map<String, dynamic>? selectedResolution;

  UVCCameraState({
    this.isOpen = false,
    this.isRecording = false,
    this.statusMessage = "Đang khởi tạo...",
    this.resolutions = const [],
    this.selectedResolution,
  });

  UVCCameraState copyWith({
    bool? isOpen,
    bool? isRecording,
    String? statusMessage,
    List<Map<String, dynamic>>? resolutions,
    Map<String, dynamic>? selectedResolution,
  }) {
    return UVCCameraState(
      isOpen: isOpen ?? this.isOpen,
      isRecording: isRecording ?? this.isRecording,
      statusMessage: statusMessage ?? this.statusMessage,
      resolutions: resolutions ?? this.resolutions,
      selectedResolution: selectedResolution ?? this.selectedResolution,
    );
  }
}

// State notifier for UVC camera
class UVCCameraStateNotifier extends StateNotifier<UVCCameraState> {
  UVCCameraStateNotifier() : super(UVCCameraState()) {
    _init();
  }

  final LoggerService _logger = LoggerService();

  Future<void> _init() async {
    try {
      await _channel.invokeMethod('initialize');
      state = state.copyWith(statusMessage: "Sẵn sàng mở camera");
    } catch (e) {
      _logger.error('Failed to initialize UVC Camera: $e');
      state = state.copyWith(statusMessage: "Lỗi khởi tạo camera: $e");
    }
  }

  Future<void> openCamera() async {
    try {
      state = state.copyWith(statusMessage: "Đang mở camera...");
      await _channel.invokeMethod('openCamera');
      
      // Get resolutions after camera is open
      await getResolutions();
      
      state = state.copyWith(
        isOpen: true,
        statusMessage: "Camera đã mở",
      );
    } catch (e) {
      _logger.error('Failed to open UVC camera: $e');
      state = state.copyWith(statusMessage: "Lỗi khi mở camera: $e");
    }
  }

  Future<void> closeCamera() async {
    try {
      state = state.copyWith(statusMessage: "Đang đóng camera...");
      await _channel.invokeMethod('closeCamera');
      state = state.copyWith(
        isOpen: false,
        statusMessage: "Camera đã đóng",
        resolutions: [],
        selectedResolution: null,
        isRecording: false,
      );
    } catch (e) {
      _logger.error('Failed to close UVC camera: $e');
      state = state.copyWith(statusMessage: "Lỗi khi đóng camera: $e");
    }
  }

  Future<void> getResolutions() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getResolutions');
      final resolutions = result.map((dynamic item) => 
        Map<String, dynamic>.from(item as Map)).toList();
      
      state = state.copyWith(
        resolutions: resolutions,
        selectedResolution: resolutions.isNotEmpty ? resolutions[0] : null,
      );
      
      if (resolutions.isNotEmpty) {
        await setResolution(resolutions[0]);
      }
    } catch (e) {
      _logger.error('Failed to get resolutions: $e');
    }
  }

  Future<void> setResolution(Map<String, dynamic> resolution) async {
    try {
      state = state.copyWith(
        statusMessage: "Đang cài đặt độ phân giải ${resolution['width']}x${resolution['height']}...",
      );
      
      await _channel.invokeMethod('setResolution', resolution);
      
      state = state.copyWith(
        selectedResolution: resolution,
        statusMessage: "Đã cài đặt độ phân giải ${resolution['width']}x${resolution['height']}",
      );
    } catch (e) {
      _logger.error('Failed to set resolution: $e');
      state = state.copyWith(
        statusMessage: "Lỗi cài đặt độ phân giải: $e",
      );
    }
  }

  Future<void> takePicture() async {
    try {
      state = state.copyWith(statusMessage: "Đang chụp ảnh...");
      final String? path = await _channel.invokeMethod('takePicture');
      state = state.copyWith(
        statusMessage: path != null ? "Đã lưu ảnh tại: $path" : "Không thể chụp ảnh",
      );
    } catch (e) {
      _logger.error('Failed to take picture: $e');
      state = state.copyWith(statusMessage: "Lỗi khi chụp ảnh: $e");
    }
  }

  Future<void> toggleRecording() async {
    try {
      if (state.isRecording) {
        state = state.copyWith(statusMessage: "Đang dừng ghi video...");
      } else {
        state = state.copyWith(statusMessage: "Đang bắt đầu ghi video...");
      }
      
      final String? path = await _channel.invokeMethod('toggleRecording');
      
      state = state.copyWith(
        isRecording: !state.isRecording,
        statusMessage: path != null 
            ? state.isRecording ? "Đã lưu video tại: $path" : "Đang ghi video..." 
            : "Lỗi khi ghi video",
      );
    } catch (e) {
      _logger.error('Failed to toggle recording: $e');
      state = state.copyWith(
        statusMessage: "Lỗi khi ${state.isRecording ? 'dừng' : 'bắt đầu'} ghi video: $e",
      );
    }
  }
}

@RoutePage()
class UVCCameraScreen extends ConsumerStatefulWidget {
  const UVCCameraScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UVCCameraScreen> createState() => _UVCCameraScreenState();
}

class _UVCCameraScreenState extends ConsumerState<UVCCameraScreen> with WidgetsBindingObserver {
  final LoggerService _logger = LoggerService();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _logger.info('UVC Camera screen initialized');
    
    // Set up platform channel event handler for status updates
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onStatusChanged':
          final String message = call.arguments as String;
          ref.read(uvcCameraStateProvider.notifier).state = 
            ref.read(uvcCameraStateProvider.notifier).state.copyWith(statusMessage: message);
          break;
        case 'onCameraOpened':
          ref.read(uvcCameraStateProvider.notifier).state = 
            ref.read(uvcCameraStateProvider.notifier).state.copyWith(isOpen: true);
          break;
        case 'onCameraClosed':
          ref.read(uvcCameraStateProvider.notifier).state = 
            ref.read(uvcCameraStateProvider.notifier).state.copyWith(isOpen: false);
          break;
      }
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Close camera when screen is disposed
    final cameraState = ref.read(uvcCameraStateProvider);
    if (cameraState.isOpen) {
      ref.read(uvcCameraStateProvider.notifier).closeCamera();
    }
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Close camera when app is paused
      final cameraState = ref.read(uvcCameraStateProvider);
      if (cameraState.isOpen) {
        ref.read(uvcCameraStateProvider.notifier).closeCamera();
      }
    }
  }
  
  void _showPermissionGuide() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hướng dẫn khắc phục'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Để khắc phục lỗi quyền USB:'),
            const SizedBox(height: 8),
            const Text('1. Rút thiết bị camera USB'),
            const Text('2. Vào Cài đặt > Ứng dụng > La Vie'),
            const Text('3. Chọn "Xóa dữ liệu" và "Xóa bộ nhớ cache"'),
            const Text('4. Khởi động lại ứng dụng'),
            const Text('5. Cắm lại thiết bị camera USB'),
            const Text('6. Thử mở camera lại'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(uvcCameraStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('UVC Camera'),
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: Text(
              cameraState.statusMessage,
              style: TextStyle(
                color: cameraState.statusMessage.contains("Lỗi") ? Colors.red : Colors.blue.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Camera view or placeholder
          Expanded(
            child: cameraState.isOpen
                ? _buildCameraPreviewView()
                : _buildCameraPlaceholderView(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCameraPlaceholderView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "Camera chưa được mở",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Khi nhấn nút Mở Camera, hãy chấp nhận quyền truy cập thiết bị USB khi được hỏi",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(uvcCameraStateProvider.notifier).openCamera(),
            child: const Text("Mở Camera"),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _showPermissionGuide,
            child: const Text("Gặp vấn đề? Xem hướng dẫn"),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCameraPreviewView() {
    final cameraState = ref.watch(uvcCameraStateProvider);
    
    return Column(
      children: [
        // Resolution selection
        if (cameraState.resolutions.isNotEmpty)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cameraState.resolutions.length,
              itemBuilder: (context, index) {
                final resolution = cameraState.resolutions[index];
                final isSelected = cameraState.selectedResolution != null &&
                                  cameraState.selectedResolution!['width'] == resolution['width'] && 
                                  cameraState.selectedResolution!['height'] == resolution['height'];
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text("${resolution['width']}x${resolution['height']}"),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(uvcCameraStateProvider.notifier).setResolution(resolution);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        
        // Camera preview (Native view from platform)
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: cameraState.selectedResolution != null 
                    ? (cameraState.selectedResolution!['width'] / cameraState.selectedResolution!['height'])
                    : 4 / 3,
                child: const AndroidView(
                  viewType: 'com.lavie.app/uvc_camera_view',
                  creationParams: {},
                  creationParamsCodec: StandardMessageCodec(),
                ),
              ),
            ),
          ),
        ),
        
        // Recording indicator
        if (cameraState.isRecording)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.red.withOpacity(0.7),
            width: double.infinity,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                SizedBox(width: 8),
                Text('ĐANG GHI VIDEO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        
        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => ref.read(uvcCameraStateProvider.notifier).takePicture(),
                icon: const Icon(Icons.camera_alt),
                tooltip: "Chụp ảnh",
                iconSize: 32,
              ),
              IconButton(
                onPressed: () => ref.read(uvcCameraStateProvider.notifier).toggleRecording(),
                icon: Icon(cameraState.isRecording ? Icons.stop : Icons.videocam),
                tooltip: cameraState.isRecording ? "Dừng ghi video" : "Ghi video",
                color: cameraState.isRecording ? Colors.red : null,
                iconSize: 32,
              ),
              IconButton(
                onPressed: () => ref.read(uvcCameraStateProvider.notifier).closeCamera(),
                icon: const Icon(Icons.close),
                tooltip: "Đóng camera",
                iconSize: 32,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 