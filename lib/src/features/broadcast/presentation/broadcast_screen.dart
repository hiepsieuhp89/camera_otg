import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lavie/src/core/providers/logger_provider.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/device/data/device_service.dart';
import 'package:lavie/src/features/webrtc/data/webrtc_connection_service.dart';
import 'package:lavie/src/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uvccamera/uvccamera.dart';
import 'package:vibration/vibration.dart';

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
  bool _isLoadingDevices = true;
  String? _errorMessage;
  StreamSubscription? _signalSubscription;
  final List<VibrationSignal> _recentSignals = [];
  UvcCameraController? _cameraController;
  UvcCameraDevice? _selectedDevice;
  List<UvcCameraDevice> _availableDevices = [];
  Timer? _statusUpdateTimer;
  WebRTCConnectionService? _webRTCService;
  RTCVideoRenderer? _localRenderer;
  MediaStream? _localStream;
  String? _selectedDeviceId;
  bool _isStreamInitialized = false;
  bool _hasDevicePermission = false;
  bool _hasCameraPermission = false;
  bool _isDeviceAttached = false;
  bool _isDeviceConnected = false;
  StreamSubscription<UvcCameraErrorEvent>? _errorEventSubscription;
  StreamSubscription<UvcCameraStatusEvent>? _statusEventSubscription;
  StreamSubscription<UvcCameraButtonEvent>? _buttonEventSubscription;
  StreamSubscription<UvcCameraDeviceEvent>? _deviceEventSubscription;
  bool _isUsingFallbackStream = false;
  Timer? _staticNoiseTimer;
  Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeWithLogging();
  }

  Future<void> _initializeWithLogging() async {
    final logger = ref.read(loggerProvider);
    try {
      await logger.info('BroadcastScreen: Initializing...');
      await _initializeWebRTCRenderer();
      await _loadAvailableDevices();
      _startListeningForDeviceEvents();
      await logger.info('BroadcastScreen: Initialization complete');
    } catch (e) {
      await logger.error('BroadcastScreen: Initialization error - $e');
      setState(() {
        _errorMessage = 'Lỗi khởi tạo: $e';
      });
    }
  }

  @override
  void dispose() {
    _cleanupWithLogging();
    super.dispose();
  }

  Future<void> _cleanupWithLogging() async {
    final logger = ref.read(loggerProvider);
    try {
      await logger.info('BroadcastScreen: Starting cleanup...');
      
      _errorEventSubscription?.cancel();
      _statusEventSubscription?.cancel();
      _buttonEventSubscription?.cancel();
      _deviceEventSubscription?.cancel();
      
      if (_localStream != null) {
        await logger.info('BroadcastScreen: Disposing local stream...');
        _localStream!.getTracks().forEach((track) {
          track.stop();
        });
        _localStream!.dispose();
        _localStream = null;
      }

      _cleanupCamera();
      _cleanupWebRTC();
      _signalSubscription?.cancel();
      _statusUpdateTimer?.cancel();
      
      await logger.info('BroadcastScreen: Cleanup complete');
    } catch (e) {
      await logger.error('BroadcastScreen: Cleanup error - $e');
    }
  }

  Future<void> _initializeWebRTCRenderer() async {
    final logger = ref.read(loggerProvider);
    try {
      await logger.info('BroadcastScreen: Initializing WebRTC renderer...');
      
      // First clean up any existing resources
      if (_localRenderer != null) {
        await _localRenderer!.dispose();
        _localRenderer = null;
      }
      
      // Create and initialize the renderer
      _localRenderer = RTCVideoRenderer();
      try {
      await _localRenderer!.initialize();
      await logger.info('BroadcastScreen: Local renderer initialized');
      } catch (e) {
        await logger.error('BroadcastScreen: Failed to initialize local renderer - $e');
        _localRenderer = null;
        throw Exception('Không thể khởi tạo trình hiển thị video: $e');
      }
    } catch (e) {
      await logger.error('BroadcastScreen: WebRTC renderer initialization error - $e');
      rethrow;
    }
  }

  Future<void> _setupWebRTCForBroadcasting() async {
    final logger = ref.read(loggerProvider);
    
    // Đảm bảo không gọi lại khi WebRTC service đã được khởi tạo
    if (_webRTCService != null) {
      await logger.info('BroadcastScreen: WebRTC service already exists, reusing existing instance');
      return;
    }
    
    try {
      await logger.info('BroadcastScreen: Setting up WebRTC for broadcasting...');
      
      // 1. Kiểm tra người dùng đã đăng nhập chưa
      final user = ref.read(currentUserProvider);
      if (user == null) {
        await logger.error('BroadcastScreen: No logged in user');
        throw Exception('Chưa đăng nhập');
      }
      
      // 2. Tạo WebRTC service với retry
      int retryCount = 0;
      const maxRetries = 2;
      
      while (retryCount <= maxRetries) {
        try {
          await logger.info('BroadcastScreen: Creating WebRTC service (attempt ${retryCount+1}/${maxRetries+1}) for user ${user.id}');
          
        _webRTCService = ref.read(webRTCConnectionServiceProvider(
          WebRTCConnectionParams(
            userId: user.id,
            isBroadcaster: true,
          ),
        ));
          
          // Kiểm tra service đã được khởi tạo đúng
          if (_webRTCService == null) {
            throw Exception('WebRTC service creation returned null');
      }
          
          await logger.info('BroadcastScreen: WebRTC service created successfully');
          return; // Thoát sớm nếu thành công
    } catch (e) {
          await logger.warning('BroadcastScreen: Failed to create WebRTC service (attempt ${retryCount+1}/${maxRetries+1}) - $e');
          
          // Dọn dẹp tài nguyên nếu có
          if (_webRTCService != null) {
            try {
              _webRTCService!.dispose();
            } catch (disposeError) {
              await logger.error('BroadcastScreen: Error disposing WebRTC service - $disposeError');
            }
            _webRTCService = null;
          }
          
          // Đã thử hết số lần retry
          if (retryCount >= maxRetries) {
            await logger.error('BroadcastScreen: Failed all attempts to create WebRTC service');
            throw Exception('Không thể khởi tạo dịch vụ WebRTC sau nhiều lần thử: $e');
          }
          
          // Chờ giữa các lần retry
          await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
          retryCount++;
        }
      }
    } catch (e) {
      await logger.error('BroadcastScreen: WebRTC setup error - $e');
      
      // Đảm bảo dọn dẹp tài nguyên
      if (_webRTCService != null) {
        try {
          _webRTCService!.dispose();
        } catch (disposeError) {
          await logger.error('BroadcastScreen: Error disposing WebRTC service during cleanup - $disposeError');
        }
        _webRTCService = null;
      }
      
      throw Exception('Lỗi thiết lập WebRTC: $e');
    }
  }

  Future<void> _createFallbackStream() async {
    final logger = ref.read(loggerProvider);
    try {
      await logger.info('BroadcastScreen: Creating fallback stream...');
      
      // Dọn dẹp stream hiện tại nếu có
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) => track.stop());
        _localStream!.dispose();
        _localStream = null;
      }
      
      // Dừng timer nếu đã tồn tại
      _staticNoiseTimer?.cancel();
      
      // Tạo luồng giả với âm thanh nhưng video đen (không video)
      final Map<String, dynamic> audioOnlyConstraints = {
        'audio': true,
        'video': false
      };
      
      try {
        _localStream = await navigator.mediaDevices.getUserMedia(audioOnlyConstraints);
        
        // Bắt đầu timer để làm mới giao diện chế độ nhiễu
        _staticNoiseTimer = Timer.periodic(Duration(milliseconds: 200), (_) {
          if (mounted) setState(() {/* trigger UI update để vẽ lại nhiễu */});
        });
        
        if (_localRenderer != null) {
          await logger.info('BroadcastScreen: Setting fallback stream to renderer...');
          _localRenderer!.srcObject = _localStream;
          _isStreamInitialized = true;
          _isUsingFallbackStream = true;
        }
        
        await logger.info('BroadcastScreen: Fallback stream created successfully');
      } catch (e) {
        await logger.error('BroadcastScreen: Error creating audio fallback stream - $e');
        
        // Tạo dummy stream không có media track
        await logger.info('BroadcastScreen: Creating no-media fallback mode...');
        
        try {
          // Tạo một dummy stream trống
          _localStream = await createLocalMediaStream('dummy_fallback');
          
          // Bắt đầu timer để cập nhật UI nhiễu
          _staticNoiseTimer = Timer.periodic(Duration(milliseconds: 200), (_) {
            if (mounted) setState(() {/* trigger UI update */});
          });
          
          if (_localRenderer != null) {
            _localRenderer!.srcObject = _localStream;
          }
          
          // Đánh dấu là đang dùng fallback UI
          _isUsingFallbackStream = true;
          _isStreamInitialized = true;
          
          await logger.info('BroadcastScreen: No-media fallback mode created successfully');
        } catch (dummyError) {
          await logger.error('BroadcastScreen: Failed to create no-media fallback - $dummyError');
          throw Exception('Không thể tạo luồng dự phòng: $e');
        }
      }
    } catch (e) {
      await logger.error('BroadcastScreen: Fallback stream creation error - $e');
      rethrow;
    }
  }

  Future<void> _requestPermissions() async {
    final logger = ref.read(loggerProvider);
    try {
      logger.info('BroadcastScreen: Requesting all required permissions...');
      
      // Kiểm tra quyền camera trước
      final hasCameraPermission = await _requestCameraPermission();
      setState(() {
        _hasCameraPermission = hasCameraPermission;
      });

      if (!hasCameraPermission) {
        logger.warning('BroadcastScreen: Camera permission denied - cannot proceed with camera functions');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cần quyền truy cập camera để sử dụng tính năng này'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Kiểm tra quyền microphone (cần thiết cho audio)
      final hasMicrophonePermission = await _requestMicrophonePermission();
      if (!hasMicrophonePermission) {
        logger.warning('BroadcastScreen: Microphone permission denied - audio will not be available');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phát sóng sẽ không có âm thanh do không có quyền truy cập microphone'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        // Vẫn tiếp tục với camera, nhưng không có audio
      }

      // Nếu có thiết bị đã chọn, yêu cầu quyền truy cập thiết bị UVC
      if (_selectedDevice != null) {
        logger.info('BroadcastScreen: Requesting USB device permission...');
        try {
          // Sử dụng phương thức _requestDevicePermission thay vì gọi trực tiếp API
          final hasDevicePermission = await _requestDevicePermission();
          setState(() {
            _hasDevicePermission = hasDevicePermission;
          });
          
          logger.info('BroadcastScreen: USB device permission result: $hasDevicePermission');
          
          if (!hasDevicePermission) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Không thể truy cập thiết bị USB camera'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          }
        } catch (deviceError) {
          logger.error('BroadcastScreen: Error requesting device permission - $deviceError');
          setState(() {
            _hasDevicePermission = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi truy cập thiết bị: ${deviceError.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      logger.error('BroadcastScreen: Permission request error - $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi yêu cầu quyền truy cập: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createMediaStreamForBroadcasting() async {
    final logger = ref.read(loggerProvider);
    
    try {
      await logger.info('BroadcastScreen: Creating media stream for broadcasting...');
      
      // Kiểm tra camera controller
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        await logger.error('BroadcastScreen: Cannot create media stream - camera not initialized');
        throw Exception('Camera chưa được khởi tạo');
      }
      
      // Kiểm tra thiết bị
      if (_selectedDevice == null) {
        await logger.error('BroadcastScreen: Cannot create media stream - no device selected');
        throw Exception('Không có thiết bị camera được chọn');
      }
      
      // Dọn dẹp stream hiện tại nếu có
      if (_localStream != null) {
        try {
          await logger.info('BroadcastScreen: Cleaning up existing stream...');
          _localStream!.getTracks().forEach((track) {
            try {
              track.stop();
            } catch (e) {
              logger.error('BroadcastScreen: Error stopping track: $e');
            }
          });
          _localStream!.dispose();
        } catch (e) {
          await logger.error('BroadcastScreen: Error cleaning up stream: $e');
        }
        _localStream = null;
      }

      // Reset fallback state
      _isUsingFallbackStream = false;
      _staticNoiseTimer?.cancel();
      _staticNoiseTimer = null;

      // Add a small delay to ensure the camera is fully ready
      await Future.delayed(const Duration(milliseconds: 300));

      // Kiểm tra lại quyền CAMERA và MICROPHONE trước khi tiếp tục
      bool hasCamera = await Permission.camera.status.isGranted;
      bool hasMic = await Permission.microphone.status.isGranted;
      
      if (!hasCamera) {
        await logger.error('BroadcastScreen: Camera permission not granted');
        throw Exception('Không có quyền truy cập camera, vui lòng cấp quyền và thử lại');
      }
      
      // Kiểm tra lại trạng thái kết nối
      if (!_isDeviceAttached || !_isDeviceConnected) {
        await logger.error('BroadcastScreen: Device not connected');
        throw Exception('Thiết bị camera không được kết nối');
      }

      await logger.info('BroadcastScreen: Getting user media... Microphone permission: $hasMic');
      
      // Bọc getUserMedia trong try-catch riêng để xử lý lỗi cụ thể
      try {
        // Sử dụng deviceId exact và thiết lập kích thước hợp lý
        Map<String, dynamic> mediaConstraints = {
          'audio': hasMic, // Chỉ yêu cầu audio nếu có quyền
          'video': {
            'deviceId': {'exact': _selectedDevice!.name},
            'width': {'ideal': 640, 'max': 1280}, // Giảm xuống để ổn định hơn
            'height': {'ideal': 480, 'max': 720}
          }
        };
        
        await logger.info('BroadcastScreen: Requesting media with constraints: $mediaConstraints');
        
        // Thêm timeout để tránh treo
        _localStream = await _getUserMediaWithTimeout(mediaConstraints, const Duration(seconds: 5));
        
        if (_localStream == null) {
          throw Exception('Không nhận được stream từ camera');
        }
        
        // Kiểm tra stream đã nhận
        final videoTracks = _localStream!.getVideoTracks();
        final audioTracks = _localStream!.getAudioTracks();
        
        await logger.info('BroadcastScreen: Media stream obtained - Video tracks: ${videoTracks.length}, Audio tracks: ${audioTracks.length}');
        
        // Nếu không có video track, báo lỗi
        if (videoTracks.isEmpty) {
          throw Exception('Không nhận được video track từ camera');
        }
        
        // Log thông tin về các track
        for (var track in videoTracks) {
          await logger.info('BroadcastScreen: Video track - ID: ${track.id}, Kind: ${track.kind}, Enabled: ${track.enabled}');
        }
        
        for (var track in audioTracks) {
          await logger.info('BroadcastScreen: Audio track - ID: ${track.id}, Kind: ${track.kind}, Enabled: ${track.enabled}');
        }
      } catch (e) {
        await logger.error('BroadcastScreen: Error getting user media - $e');
        
        // Phân tích lỗi cụ thể
        String errorMessage = e.toString();
        if (errorMessage.contains('NotAllowedError') || errorMessage.contains('Permission denied')) {
          await logger.error('BroadcastScreen: Permission error detected in getUserMedia - attempting to recheck permissions');
          
          // Thử kiểm tra lại quyền và thông báo
          final cameraStatus = await Permission.camera.status;
          final micStatus = await Permission.microphone.status;
          
          await logger.info('BroadcastScreen: Current permission status - Camera: $cameraStatus, Microphone: $micStatus');
          
          if (!cameraStatus.isGranted) {
            await logger.error('BroadcastScreen: Camera permission is not granted (status: $cameraStatus)');
            throw Exception('Không có quyền truy cập camera. Vui lòng vào Cài đặt để cấp quyền và khởi động lại ứng dụng');
          } else {
            // Có thể là lỗi khác trong quá trình khởi tạo camera
            throw Exception('Lỗi truy cập camera: $e. Thử khởi động lại ứng dụng');
          }
        }
        
        // Sử dụng _handleBroadcastingError để xử lý lỗi này thay vì tự xử lý
        await _handleBroadcastingError(
          e is Exception ? e : Exception(e.toString()), 
          contextMessage: 'khi truy cập camera'
        );
        return;
      }

      if (_localStream == null) {
        await logger.error('BroadcastScreen: Local stream is null after initialization');
        
        // Sử dụng _handleBroadcastingError
        await _handleBroadcastingError(
          Exception('Stream null sau khi khởi tạo'), 
          contextMessage: 'camera stream trống'
        );
        return;
      }

      if (_localRenderer != null) {
        try {
          await logger.info('BroadcastScreen: Setting stream to renderer...');
          _localRenderer!.srcObject = _localStream;
        } catch (e) {
          await logger.error('BroadcastScreen: Error setting stream to renderer - $e');
          // Không gây crash ở đây, tiếp tục với stream đã có
        }
      } else {
        await logger.warning('BroadcastScreen: Local renderer is null, cannot attach stream');
      }

      _isStreamInitialized = true;
      _isUsingFallbackStream = false;
      
      await logger.info('BroadcastScreen: Media stream created successfully');
    } catch (e) {
      await logger.error('BroadcastScreen: Media stream creation error - $e');
      
      // Sử dụng _handleBroadcastingError để xử lý lỗi toàn diện
      await _handleBroadcastingError(
        e is Exception ? e : Exception(e.toString()), 
        contextMessage: 'khởi tạo media stream'
      );
    }
  }
  
  // Phương thức gọi getUserMedia với timeout
  Future<MediaStream?> _getUserMediaWithTimeout(
    Map<String, dynamic> constraints, 
    Duration timeout
  ) async {
    final logger = ref.read(loggerProvider);
    try {
      await logger.info('BroadcastScreen: getUserMedia with timeout ${timeout.inSeconds}s - constraints: $constraints');
      
      // Kiểm tra quyền truy cập trước khi gọi getUserMedia
      var cameras = await navigator.mediaDevices.getSources();
      await logger.info('BroadcastScreen: Available devices: ${cameras.length}');
      
      // Log toàn bộ cameras để debug
      await logger.info('BroadcastScreen: Full cameras list: $cameras');
      
      for (var camera in cameras) {
        // Log thông tin tất cả các keys và giá trị để debug
        await logger.info('BroadcastScreen: Camera object type: ${camera.runtimeType}');
        if (camera is Map) {
          await logger.info('BroadcastScreen: Camera keys: ${camera.keys.toList()}');
          await logger.info('BroadcastScreen: Camera full data: $camera');
        }
        
        // Fix: Access properties safely with toString to avoid null errors
        await logger.info('BroadcastScreen: Device - ID: ${camera['deviceId'] ?? 'unknown'}, Kind: ${camera['kind'] ?? 'unknown'}, Label: ${camera['label'] ?? 'unknown'}');
      }
      
      final completer = Completer<MediaStream?>();
      
      // Tạo timer cho timeout
      final timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          logger.error('BroadcastScreen: getUserMedia timeout after ${timeout.inSeconds} seconds');
          completer.complete(null);
        }
      });
      
      // Kiểm tra permission trước khi gọi getUserMedia
      final cameraPermission = await Permission.camera.status;
      final micPermission = await Permission.microphone.status;
      
      await logger.info('BroadcastScreen: Permission check before getUserMedia - Camera: $cameraPermission, Mic: $micPermission');
      
      if (!cameraPermission.isGranted) {
        await logger.error('BroadcastScreen: Camera permission not granted before getUserMedia');
        timer.cancel();
        throw Exception('Không có quyền truy cập camera');
      }
      
      // Gọi getUserMedia trong try-catch với nhiều thông tin debug
      try {
        await logger.info('BroadcastScreen: Calling navigator.mediaDevices.getUserMedia()...');
        final stream = await navigator.mediaDevices.getUserMedia(constraints);
        
        // Kiểm tra stream đã nhận được
        int videoTracks = stream.getVideoTracks().length;
        int audioTracks = stream.getAudioTracks().length;
        
        await logger.info('BroadcastScreen: getUserMedia success - Video tracks: $videoTracks, Audio tracks: $audioTracks');
        
        if (!completer.isCompleted) {
          completer.complete(stream);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          String errorMessage = e.toString();
          
          // Chi tiết phân tích lỗi
          if (errorMessage.contains('NotAllowedError') || errorMessage.contains('Permission denied')) {
            await logger.error('BroadcastScreen: NotAllowedError in getUserMedia - Permission issue');
            
            // Kiểm tra lại trạng thái quyền ngay sau lỗi
            final postErrorCameraStatus = await Permission.camera.status;
            final postErrorMicStatus = await Permission.microphone.status;
            
            await logger.info('BroadcastScreen: Post-error permission check - Camera: $postErrorCameraStatus, Mic: $postErrorMicStatus');
            
            completer.completeError(Exception('Không có quyền truy cập: $e - Camera: $postErrorCameraStatus, Mic: $postErrorMicStatus'));
          } else if (errorMessage.contains('NotFoundError') || errorMessage.contains('Requested device not found')) {
            await logger.error('BroadcastScreen: NotFoundError in getUserMedia - Device not found');
            completer.completeError(Exception('Không tìm thấy thiết bị camera: $e'));
          } else if (errorMessage.contains('NotReadableError') || errorMessage.contains('Could not start video source')) {
            await logger.error('BroadcastScreen: NotReadableError in getUserMedia - Hardware error');
            completer.completeError(Exception('Không thể khởi động thiết bị camera - đã bị sử dụng bởi ứng dụng khác hoặc bị lỗi: $e'));
          } else if (errorMessage.contains('OverconstrainedError')) {
            await logger.error('BroadcastScreen: OverconstrainedError in getUserMedia - Constraints cannot be satisfied');
            completer.completeError(Exception('Thiết bị camera không hỗ trợ các thiết lập yêu cầu: $e'));
          } else if (errorMessage.contains('TypeError')) {
            await logger.error('BroadcastScreen: TypeError in getUserMedia - Invalid constraints');
            completer.completeError(Exception('Lỗi định dạng yêu cầu truy cập camera: $e'));
          } else {
            await logger.error('BroadcastScreen: Unknown getUserMedia error - $e');
            completer.completeError(e);
          }
        }
      }
      
      // Hủy timer nếu hoàn thành trước timeout
      final result = await completer.future;
      timer.cancel();
      return result;
    } catch (e) {
      logger.error('BroadcastScreen: _getUserMediaWithTimeout error - $e');
      // Bổ sung thêm thông tin về thiết bị và trạng thái khi có lỗi
      try {
        final deviceStatus = _selectedDevice != null 
          ? "ID: ${_selectedDevice!.name}, Connected: $_isDeviceConnected" 
          : "No device selected";
        
        final permissionStatus = "Camera: ${await Permission.camera.status}, Mic: ${await Permission.microphone.status}";
        
        await logger.error('BroadcastScreen: Error context - Device: $deviceStatus, Permissions: $permissionStatus');
      } catch (contextError) {
        await logger.error('BroadcastScreen: Failed to log error context - $contextError');
      }
      
      rethrow; // Ném lại lỗi để có thể được xử lý ở hàm gọi
    }
  }

  void _cleanupCamera() {
    final logger = ref.read(loggerProvider);
    try {
      logger.info('BroadcastScreen: Cleaning up camera...');
      
      // Hủy các event listeners trước
      _errorEventSubscription?.cancel();
      _errorEventSubscription = null;
      
      _statusEventSubscription?.cancel();
      _statusEventSubscription = null;
      
      _buttonEventSubscription?.cancel();
      _buttonEventSubscription = null;
      
      // Kiểm tra và hủy controller nếu tồn tại
      if (_cameraController != null) {
        try {
          if (_cameraController!.value.isInitialized) {
            _cameraController!.dispose();
          }
        } catch (e) {
          logger.error('BroadcastScreen: Error disposing camera controller - $e');
          // Tiếp tục bất kể lỗi
        }
      _cameraController = null;
      }
      
      // Cập nhật trạng thái
      if (mounted) {
        setState(() {
          _isCameraConnected = false;
        });
      }
      
      logger.info('BroadcastScreen: Camera cleanup complete');
    } catch (e) {
      logger.error('BroadcastScreen: Camera cleanup error - $e');
    }
  }

  void _cleanupWebRTC() {
    final logger = ref.read(loggerProvider);
    try {
      logger.info('BroadcastScreen: Cleaning up WebRTC...');
      _localRenderer?.dispose();
      _localRenderer = null;
      _webRTCService?.dispose();
      _webRTCService = null;
      logger.info('BroadcastScreen: WebRTC cleanup complete');
    } catch (e) {
      logger.error('BroadcastScreen: WebRTC cleanup error - $e');
    }
  }

  Future<void> _loadAvailableDevices() async {
    final logger = ref.read(loggerProvider);
    setState(() {
      _isLoadingDevices = true;
      _errorMessage = null;
    });

    try {
      await logger.info('BroadcastScreen: Loading available devices...');
      
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        await logger.info('BroadcastScreen: Requesting camera permission...');
        cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          throw Exception('Quyền truy cập camera bị từ chối');
        }
      }

      final isSupported = await UvcCamera.isSupported();
      if (!isSupported) {
        await logger.warning('BroadcastScreen: UVC camera not supported on this device');
        throw Exception('Thiết bị không hỗ trợ camera UVC');
      }

      final devices = await UvcCamera.getDevices();
      await logger.info('BroadcastScreen: Found ${devices.length} devices');
      
      if (devices.isEmpty) {
        throw Exception('Không tìm thấy camera UVC');
      }

      setState(() {
        _availableDevices = devices.values.toList();
      });
    } catch (e) {
      await logger.error('BroadcastScreen: Device loading error - $e');
      setState(() {
        _errorMessage = 'Lỗi tải danh sách camera: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingDevices = false;
      });
    }
  }

  void _startListeningForDeviceEvents() {
    final logger = ref.read(loggerProvider);
    try {
      // Cancel existing subscription
      _deviceEventSubscription?.cancel();
      _deviceEventSubscription = null;
      
      logger.info('BroadcastScreen: Starting device event listener...');
      _deviceEventSubscription = UvcCamera.deviceEventStream.listen((event) {
        try {
          // Check if we have a selected device
          if (_selectedDevice == null) {
            logger.info('BroadcastScreen: Received device event but no device is selected');
            return;
          }
          
          // Check if this event is for our selected device
          if (event.device.name != _selectedDevice!.name) {
            logger.info('BroadcastScreen: Event for different device: ${event.device.name}, our device: ${_selectedDevice!.name}');
          return;
        }

        logger.info('BroadcastScreen: Device event: ${event.type} for device: ${event.device.name}');

          // Xử lý các loại sự kiện thiết bị
          if (event.type == UvcCameraDeviceEventType.attached) {
            // Thiết bị được kết nối vật lý
            setState(() {
            _isDeviceAttached = true;
            _isDeviceConnected = false;
            });
            
            // Yêu cầu quyền truy cập
            Future.microtask(() => _requestPermissions());
            
          } else if (event.type == UvcCameraDeviceEventType.detached) {
            // Thiết bị bị rút ra khỏi cổng USB
            logger.warning('BroadcastScreen: Device physically detached');
            
            setState(() {
            _hasCameraPermission = false;
            _hasDevicePermission = false;
            _isDeviceAttached = false;
            _isDeviceConnected = false;
            });
            
            // Dọn dẹp camera trước
            _cleanupCamera();
            
            // Nếu đang phát sóng, thử chuyển sang chế độ fallback
            if (_isBroadcasting && !_isUsingFallbackStream) {
              logger.info('BroadcastScreen: Device detached while broadcasting, attempting fallback mode');
              
              Future.microtask(() async {
                try {
                  await _handleBroadcastingError(
                    Exception('Thiết bị đã bị ngắt kết nối vật lý'),
                    contextMessage: 'thiết bị đã bị ngắt kết nối'
                  );
                } catch (e) {
                  logger.error('BroadcastScreen: Error handling device detach - $e');
                }
              });
            } else {
              // Hiển thị thông báo ngắt kết nối thiết bị
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thiết bị camera đã bị ngắt kết nối'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } else if (event.type == UvcCameraDeviceEventType.connected) {
            logger.info('BroadcastScreen: Device connected: ${event.device.name}');
            
      setState(() {
            _isDeviceConnected = true;
            });
            
            // Thiết lập controller cho thiết bị
            Future.microtask(() async {
              try {
                await _initializeCameraController();
              } catch (e) {
                logger.error('BroadcastScreen: Error initializing camera after connect - $e');
                
                // Nếu đang phát sóng, xử lý lỗi
                if (_isBroadcasting) {
                  await _handleBroadcastingError(
                    e is Exception ? e : Exception(e.toString()),
                    contextMessage: 'khởi tạo camera sau khi kết nối'
                  );
                }
              }
            });
          } else if (event.type == UvcCameraDeviceEventType.disconnected) {
            logger.warning('BroadcastScreen: Device disconnected');
            
        setState(() {
            _isDeviceConnected = false;
              _isCameraConnected = false;
            });
            
            // Đang phát sóng và chưa dùng fallback
            if (_isBroadcasting && !_isUsingFallbackStream) {
              logger.info('BroadcastScreen: Device disconnected while broadcasting, using fallback');
              
              Future.microtask(() async {
                try {
                  await _handleBroadcastingError(
                    Exception('Thiết bị đã bị ngắt kết nối'),
                    contextMessage: 'thiết bị đã bị ngắt kết nối logic'
                  );
    } catch (e) {
                  logger.error('BroadcastScreen: Error handling device disconnect - $e');
                }
              });
            } else {
              // Hiển thị thông báo ngắt kết nối thiết bị
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kết nối thiết bị camera đã bị ngắt'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          }
    } catch (e) {
          logger.error('BroadcastScreen: Error processing device event - $e');
        }
      }, onError: (e) {
        logger.error('BroadcastScreen: Device event stream error - $e');
      }, onDone: () {
        logger.info('BroadcastScreen: Device event stream closed');
      });
      
      logger.info('BroadcastScreen: Device event listener started');
    } catch (e) {
      logger.error('BroadcastScreen: Error starting device event listener - $e');
    }
  }

  Future<void> _initializeCameraController() async {
    final logger = ref.read(loggerProvider);
    try {
      if (_selectedDevice == null) {
        logger.warning('BroadcastScreen: No device selected for initialization');
        return;
      }

      if (!_isDeviceConnected) {
        logger.warning('BroadcastScreen: Device not connected');
        return;
      }

      logger.info('BroadcastScreen: Initializing camera controller...');
      
      // Cancel existing subscriptions
      _errorEventSubscription?.cancel();
      _statusEventSubscription?.cancel();
      _buttonEventSubscription?.cancel();

      // Kiểm tra xem controller đã được khởi tạo hay chưa
      if (_cameraController != null) {
        if (_cameraController!.value.isInitialized) {
          // Nếu controller đã được khởi tạo, không cần khởi tạo lại
          logger.info('BroadcastScreen: Camera controller is already initialized');
          
          // Thiết lập lại các event listeners
          _setupEventListeners();
          
          setState(() {
            _isCameraConnected = true;
            _selectedDeviceId = _selectedDevice!.name;
          });
          
          return;
        }
        
        // Nếu có controller nhưng chưa được khởi tạo, dọn dẹp nó
        await _cameraController!.dispose();
        _cameraController = null;
      }

      // Create controller
      _cameraController = UvcCameraController(device: _selectedDevice!);
      
      // Initialize with explicit try-catch for better error handling
      try {
        await logger.info('BroadcastScreen: Calling initialize on camera controller...');
      await _cameraController!.initialize();
        await logger.info('BroadcastScreen: Camera controller initialize completed');
      } catch (e) {
        // Kiểm tra xem có phải lỗi "already initialized" không
        if (e.toString().contains('already initialized')) {
          logger.warning('BroadcastScreen: Camera already initialized, continuing...');
        } else {
          await logger.error('BroadcastScreen: Camera initialize failed - $e');
          _cameraController = null;
          throw Exception('Không thể khởi tạo camera controller: $e');
        }
      }

      // Thiết lập event listeners
      _setupEventListeners();

      setState(() {
        _isCameraConnected = true;
        _selectedDeviceId = _selectedDevice!.name;
      });

      // Camera đã khởi tạo xong - chúng ta không cần tạo MediaStream ngay
      logger.info('BroadcastScreen: Camera controller initialized successfully');
    } catch (e) {
      logger.error('BroadcastScreen: Camera controller initialization error - $e');
      setState(() {
        _errorMessage = 'Lỗi khởi tạo camera: $e';
        _isCameraConnected = false;
        _isDeviceAttached = false;
        _isDeviceConnected = false;
      });
      _cleanupCamera();
    }
  }

  // Hàm riêng để thiết lập event listeners
  void _setupEventListeners() {
    final logger = ref.read(loggerProvider);
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        logger.warning('BroadcastScreen: Cannot setup event listeners - camera not initialized');
        return;
      }
      
      _errorEventSubscription = _cameraController!.cameraErrorEvents.listen((event) {
        logger.error('BroadcastScreen: Camera error - ${event.error}');
        if (event.error.type == UvcCameraErrorType.previewInterrupted) {
          _recoverFromPreviewInterruption();
        }
      }, onError: (error) {
        logger.error('BroadcastScreen: Camera error event listener error - $error');
      });

      _statusEventSubscription = _cameraController!.cameraStatusEvents.listen((event) {
        logger.info('BroadcastScreen: Camera status - ${event.payload}');
      }, onError: (error) {
        logger.error('BroadcastScreen: Camera status event listener error - $error');
      });

      _buttonEventSubscription = _cameraController!.cameraButtonEvents.listen((event) {
        logger.info('BroadcastScreen: Camera button - ${event.button}: ${event.state}');
      }, onError: (error) {
        logger.error('BroadcastScreen: Camera button event listener error - $error');
      });

      logger.info('BroadcastScreen: Event listeners set up successfully');
    } catch (e) {
      logger.error('BroadcastScreen: Failed to set up camera event listeners - $e');
      // Continue without listeners rather than failing completely
    }
  }

  Future<void> _recoverFromPreviewInterruption() async {
    final logger = ref.read(loggerProvider);
    try {
      logger.info('BroadcastScreen: Attempting to recover from preview interruption...');
      
      // Hiển thị thông báo cho người dùng
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera bị gián đoạn, đang thử kết nối lại...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Đợi một khoảng thời gian ngắn trước khi thử lại
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Nếu camera không còn được kết nối vật lý, chuyển qua fallback
      if (_isBroadcasting && !_isDeviceAttached) {
        logger.warning('BroadcastScreen: Device appears physically disconnected, trying fallback mode');
        
        if (!_isUsingFallbackStream) {
          try {
            await _createFallbackStream();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Camera bị ngắt kết nối, đã chuyển sang chế độ dự phòng'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
    } catch (e) {
            logger.error('BroadcastScreen: Failed to create fallback stream during recovery - $e');
          }
        }
      }
      
      // Thử khởi tạo lại controller
      if (_selectedDevice != null && _isDeviceAttached) {
        try {
          await _initializeCameraController();
          logger.info('BroadcastScreen: Successfully recovered from preview interruption');
        } catch (e) {
          logger.error('BroadcastScreen: Failed to recover from preview interruption - $e');
          
          // Nếu đang phát sóng và khôi phục thất bại, thử fallback
          if (_isBroadcasting && !_isUsingFallbackStream) {
            try {
              await _createFallbackStream();
              logger.info('BroadcastScreen: Switched to fallback stream after failed recovery');
            } catch (fallbackError) {
              logger.error('BroadcastScreen: Fallback creation also failed - $fallbackError');
            }
          }
        }
      } else {
        logger.warning('BroadcastScreen: Cannot recover - device not attached or selected');
      }
    } catch (e) {
      logger.error('BroadcastScreen: Preview recovery error - $e');
    }
  }

  void _startStatusUpdates() {
    final logger = ref.read(loggerProvider);
    try {
      logger.info('BroadcastScreen: Starting status updates...');
      _statusUpdateTimer?.cancel();
      _statusUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _updateDeviceStatus();
      });
    } catch (e) {
      logger.error('BroadcastScreen: Status updates error - $e');
    }
  }

  Future<void> _updateDeviceStatus() async {
    final logger = ref.read(loggerProvider);
    try {
      if (_selectedDeviceId == null) return;

      await logger.info('BroadcastScreen: Updating device status - Broadcasting: $_isBroadcasting');
      final deviceService = ref.read(deviceServiceProvider);
      await deviceService.updateDeviceStatus(
        _selectedDeviceId!,
        isActive: true,
        isBroadcasting: _isBroadcasting,
      );
    } catch (e) {
      await logger.error('BroadcastScreen: Device status update error - $e');
    }
  }

  Future<void> _startBroadcasting() async {
    final logger = ref.read(loggerProvider);
    
    try {
      await logger.info('BroadcastScreen: Starting broadcast preparation...');
      
      setState(() {
        _errorMessage = null;
      });
      
      // 1. Kiểm tra tình trạng camera
    if (!_isCameraConnected || _cameraController == null || !_cameraController!.value.isInitialized) {
      await logger.warning('BroadcastScreen: Cannot start broadcasting - camera not ready');
      setState(() {
        _errorMessage = 'Camera chưa được kết nối hoặc khởi tạo';
      });
        
        // Thông báo cho người dùng
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể bắt đầu phát sóng - camera chưa sẵn sàng'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      return;
    }

      // 2. Kiểm tra trạng thái quyền truy cập
      await logger.info('BroadcastScreen: Checking permission status before broadcast...');
      
      final cameraPermission = await Permission.camera.status;
      final micPermission = await Permission.microphone.status;
      
      await logger.info('BroadcastScreen: Current permissions - Camera: $cameraPermission, Microphone: $micPermission');
      
      if (!cameraPermission.isGranted) {
        await logger.error('BroadcastScreen: Cannot start broadcasting - camera permission not granted');
        
        // Yêu cầu quyền truy cập camera
        final newStatus = await _requestCameraPermission();
        if (!newStatus) {
      setState(() {
            _errorMessage = 'Không có quyền truy cập camera';
      });
      return;
        }
      }
      
      if (!micPermission.isGranted) {
        await logger.warning('BroadcastScreen: Microphone permission not granted - will broadcast without audio');
        
        // Yêu cầu quyền truy cập microphone (nhưng có thể tiếp tục nếu không được cấp)
        final newStatus = await _requestMicrophonePermission();
        if (!newStatus) {
          // Thông báo cho người dùng nhưng vẫn tiếp tục
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không có quyền truy cập microphone. Phát sóng sẽ không có âm thanh.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }

      await logger.info('BroadcastScreen: Starting broadcast with validated permissions...');
      
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('Chưa đăng nhập');
      }

      // 3. Thiết lập WebRTC service
      try {
        await _setupWebRTCForBroadcasting();
      } catch (e) {
        await logger.error('BroadcastScreen: Failed to setup WebRTC service - $e');
        throw Exception('Không thể khởi tạo dịch vụ WebRTC: $e');
      }

      // 4. Tạo media stream với catch toàn diện
      bool mediaStreamSuccess = false;
      try {
        await logger.info('BroadcastScreen: Attempting to create media stream with full video+audio');
        await _createMediaStreamForBroadcasting();
        mediaStreamSuccess = _localStream != null || _isUsingFallbackStream;
      } catch (streamError) {
        await logger.error('BroadcastScreen: Media stream creation failed completely - $streamError');
        mediaStreamSuccess = false;
      }

      // 5. Nếu vẫn thất bại, sử dụng phương pháp phát không có media cuối cùng
      if (!mediaStreamSuccess && !_isUsingFallbackStream) {
        await logger.warning('BroadcastScreen: All media stream methods failed, using no-media broadcast');
        _isUsingFallbackStream = true;
        
        _staticNoiseTimer = Timer.periodic(Duration(milliseconds: 200), (_) {
          if (mounted) setState(() {/* trigger UI update */});
        });
        
        // Thông báo cho người dùng
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể truy cập camera. Đang sử dụng chế độ phát không có video.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }

      // 6. Bắt đầu phát sóng với phương thức phù hợp
      if (_webRTCService != null) {
        if (_localStream != null) {
          await logger.info('BroadcastScreen: Starting WebRTC broadcast with full stream...');
        await _webRTCService!.startBroadcast(_localStream!, user.name);
        } else {
          // Không có stream nào, sử dụng phương thức không có media
          await logger.warning('BroadcastScreen: Starting broadcast without media stream...');
          await _webRTCService!.startBroadcastWithoutMedia(user.name);
        }
      } else {
        throw Exception('WebRTC service chưa được khởi tạo');
      }

      // 7. Cập nhật trạng thái thiết bị
      if (_selectedDeviceId != null) {
        await logger.info('BroadcastScreen: Updating device broadcasting status...');
        final deviceService = ref.read(deviceServiceProvider);
        await deviceService.startBroadcasting(_selectedDeviceId!);
      }

      // 8. Bắt đầu lắng nghe tín hiệu rung
      _startListeningForSignals();
      
      // 9. Bắt đầu cập nhật trạng thái thiết bị định kỳ
      _startStatusUpdates();

      // 10. Cập nhật UI trạng thái
      setState(() {
        _isBroadcasting = true;
      });

      await logger.info('BroadcastScreen: Broadcasting started successfully');
      
      // Hiển thị thông báo phù hợp với mode
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isUsingFallbackStream 
              ? 'Đã bắt đầu phát sóng (chế độ dự phòng)' 
              : 'Đã bắt đầu phát sóng'),
            backgroundColor: _isUsingFallbackStream ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      await logger.error('BroadcastScreen: Broadcasting start error - $e');
      
      // Cập nhật UI
      setState(() {
        _errorMessage = 'Lỗi khi bắt đầu phát sóng: ${e.toString()}';
      });
      
      // Hiển thị thông báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi bắt đầu phát sóng: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      
      // Dọn dẹp mọi tài nguyên
      try {
        // Dọn dẹp stream nếu có
        if (_localStream != null) {
          _localStream!.getTracks().forEach((track) {
            try {
              track.stop();
            } catch (trackError) {
              logger.error('BroadcastScreen: Error stopping track - $trackError');
            }
          });
          _localStream!.dispose();
          _localStream = null;
        }
        
        // Hủy timer
        _staticNoiseTimer?.cancel();
        _staticNoiseTimer = null;
        
        // Dọn dẹp WebRTC
        _webRTCService?.dispose();
        _webRTCService = null;
        
        // Reset trạng thái
        _isStreamInitialized = false;
        _isUsingFallbackStream = false;
      } catch (cleanupError) {
        await logger.error('BroadcastScreen: Error during cleanup - $cleanupError');
      }
    }
  }

  Future<void> _stopBroadcasting() async {
    final logger = ref.read(loggerProvider);
    setState(() {
      _errorMessage = null;
    });

    try {
      await logger.info('BroadcastScreen: Stopping broadcast...');
      
      // Dừng phát sóng
      if (_webRTCService != null) {
        await logger.info('BroadcastScreen: Stopping WebRTC broadcast...');
        await _webRTCService!.stopBroadcast();
      }

      // Dừng cập nhật trạng thái thiết bị
      _statusUpdateTimer?.cancel();
      _statusUpdateTimer = null;
      
      // Dừng lắng nghe tín hiệu
      _signalSubscription?.cancel();
      _signalSubscription = null;

      // Dừng stream
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) => track.stop());
        _localStream!.dispose();
        _localStream = null;
      }
      
      // Giải phóng WebRTC service
      _webRTCService?.dispose();
      _webRTCService = null;
      _isStreamInitialized = false;

      // Cập nhật trạng thái thiết bị
      if (_selectedDeviceId != null) {
        await logger.info('BroadcastScreen: Updating device broadcasting status...');
        final deviceService = ref.read(deviceServiceProvider);
        await deviceService.stopBroadcasting(_selectedDeviceId!);
      }

      setState(() {
        _isBroadcasting = false;
      });

      await logger.info('BroadcastScreen: Broadcasting stopped successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã dừng phát sóng'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      await logger.error('BroadcastScreen: Broadcasting stop error - $e');
      setState(() {
        _errorMessage = 'Lỗi khi dừng phát sóng: ${e.toString()}';
      });
    }
  }

  void _startListeningForSignals() {
    final logger = ref.read(loggerProvider);
    try {
      if (_selectedDeviceId == null) return;

      logger.info('BroadcastScreen: Starting to listen for vibration signals...');
      final deviceService = ref.read(deviceServiceProvider);
      _signalSubscription = deviceService
          .vibrationSignalsStream(_selectedDeviceId!)
          .listen(_handleVibrationSignal);

      if (_webRTCService != null) {
        _webRTCService!.startListeningForVibrations();
      }
    } catch (e) {
      logger.error('BroadcastScreen: Signal listening error - $e');
    }
  }

  void _handleVibrationSignal(List<VibrationSignal> signals) {
    final logger = ref.read(loggerProvider);
    try {
      if (signals.isEmpty) return;

      final latestSignal = signals.first;
      if (_recentSignals.any((s) => s.id == latestSignal.id)) return;

      logger.info('BroadcastScreen: Received vibration signal - count: ${latestSignal.count}');
      
      setState(() {
        _recentSignals.insert(0, latestSignal);
        if (_recentSignals.length > 10) {
          _recentSignals.removeLast();
        }
      });

      _vibrateDevice(latestSignal.count);
      _showVibrationNotification(latestSignal);
    } catch (e) {
      logger.error('BroadcastScreen: Vibration signal handling error - $e');
    }
  }

  Future<void> _vibrateDevice(int count) async {
    final logger = ref.read(loggerProvider);
    try {
      logger.info('BroadcastScreen: Vibrating device $count times');
      
      // Kiểm tra hỗ trợ rung
      final bool hasVibrator = await Vibration.hasVibrator() ?? false;
      await logger.info('BroadcastScreen: Device has vibrator: $hasVibrator');
      
      for (int i = 0; i < count; i++) {
        // Sử dụng cả HapticFeedback.vibrate và heavyImpact để đảm bảo thiết bị rung
        try {
          await logger.info('BroadcastScreen: Executing HapticFeedback.vibrate');
          HapticFeedback.vibrate();
          await Future.delayed(const Duration(milliseconds: 50));
        } catch (vibError) {
          await logger.error('BroadcastScreen: Error with HapticFeedback.vibrate - $vibError');
        }
        
        try {
          await logger.info('BroadcastScreen: Executing HapticFeedback.heavyImpact');
          HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 50));
        } catch (impactError) {
          await logger.error('BroadcastScreen: Error with HapticFeedback.heavyImpact - $impactError');
        }
        
        // Thêm mediumImpact để tăng khả năng thiết bị phản hồi
        try {
          await logger.info('BroadcastScreen: Executing HapticFeedback.mediumImpact');
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 50));
        } catch (mediumError) {
          await logger.error('BroadcastScreen: Error with HapticFeedback.mediumImpact - $mediumError');
        }
        
        // Sử dụng Vibration package nếu có hỗ trợ
        if (hasVibrator) {
          try {
            await logger.info('BroadcastScreen: Executing Vibration.vibrate');
            
            // Kiểm tra xem thiết bị có hỗ trợ điều khiển độ rung không
            final bool hasAmplitudeControl = await Vibration.hasAmplitudeControl() ?? false;
            await logger.info('BroadcastScreen: Device supports amplitude control: $hasAmplitudeControl');
            
            if (hasAmplitudeControl) {
              await Vibration.vibrate(duration: 500, amplitude: 255);
            } else {
              await Vibration.vibrate(duration: 500);
            }
            
          } catch (vibrationError) {
            await logger.error('BroadcastScreen: Error with Vibration package - $vibrationError');
          }
        }
        
        if (i < count - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      await logger.info('BroadcastScreen: Vibration sequence completed');
    } catch (e) {
      logger.error('BroadcastScreen: Device vibration error - $e');
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

  Future<void> _initializeCamera(UvcCameraDevice device) async {
    final logger = ref.read(loggerProvider);
    try {
      await logger.info('BroadcastScreen: Starting camera initialization for device: ${device.name}');
      
      // Clean up previous camera if any
      _cleanupCamera();
      
      setState(() {
        _selectedDevice = device;
        _isInitializing = true;
        _errorMessage = null;
      });

      // Check if UVC camera is supported
      final isSupported = await UvcCamera.isSupported();
      if (!isSupported) {
        throw Exception('Thiết bị không hỗ trợ camera UVC');
      }

      // Start listening for device events
      _startListeningForDeviceEvents();

      // Request permissions
      await _requestPermissions();
      
      if (!_hasCameraPermission || !_hasDevicePermission) {
        throw Exception('Camera hoặc thiết bị chưa được cấp quyền');
      }

      // Wait for device to be connected
      await logger.info('BroadcastScreen: Waiting for device to be connected...');
      setState(() {
        _isDeviceAttached = true;
      });

      // Request device permission again to trigger connection
      final hasPermission = await UvcCamera.requestDevicePermission(device);
      if (!hasPermission) {
        throw Exception('Quyền truy cập thiết bị bị từ chối');
      }

      // Device should now be connected and _initializeCameraController will be called by device event listener
    } catch (e) {
      await logger.error('BroadcastScreen: Camera initialization error - $e');
      setState(() {
        _errorMessage = 'Lỗi khởi tạo camera: $e';
        _isCameraConnected = false;
        _isDeviceAttached = false;
        _isDeviceConnected = false;
      });
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  // Chi tiết kiểm tra và xử lý quyền truy cập
  Future<PermissionStatus> _checkAndRequestPermission(Permission permission, String permissionName) async {
    final logger = ref.read(loggerProvider);
    
    try {
      await logger.info('BroadcastScreen: Checking $permissionName permission status...');
      
      PermissionStatus status = await permission.status;
      
      // Ghi log trạng thái hiện tại
      switch (status) {
        case PermissionStatus.granted:
          await logger.info('BroadcastScreen: $permissionName permission is already granted');
          break;
        case PermissionStatus.denied:
          await logger.info('BroadcastScreen: $permissionName permission is denied - requesting...');
          break;
        case PermissionStatus.permanentlyDenied:
          await logger.warning('BroadcastScreen: $permissionName permission is permanently denied');
          _showPermissionSettings(permissionName);
          break;
        case PermissionStatus.restricted:
          await logger.warning('BroadcastScreen: $permissionName permission is restricted');
          break;
        case PermissionStatus.limited:
          await logger.warning('BroadcastScreen: $permissionName permission is limited');
          break;
        default:
          await logger.info('BroadcastScreen: $permissionName permission status is unknown');
      }
      
      // Nếu chưa được cấp quyền, yêu cầu
      if (!status.isGranted) {
        await logger.info('BroadcastScreen: Requesting $permissionName permission...');
        status = await permission.request();
        
        // Ghi log kết quả yêu cầu
        switch (status) {
          case PermissionStatus.granted:
            await logger.info('BroadcastScreen: $permissionName permission has been granted');
            break;
          case PermissionStatus.denied:
            await logger.warning('BroadcastScreen: $permissionName permission is denied after request');
            break;
          case PermissionStatus.permanentlyDenied:
            await logger.error('BroadcastScreen: $permissionName permission is permanently denied after request');
            _showPermissionSettings(permissionName);
            break;
          default:
            await logger.warning('BroadcastScreen: $permissionName permission status is ${status.toString()} after request');
        }
      }
      
      return status;
    } catch (e) {
      await logger.error('BroadcastScreen: Error checking $permissionName permission - $e');
      return PermissionStatus.denied;
    }
  }
  
  // Hiển thị dialog yêu cầu người dùng mở màn hình cài đặt khi bị từ chối vĩnh viễn
  void _showPermissionSettings(String permissionName) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Cần quyền truy cập $permissionName'),
          content: Text('Quyền truy cập $permissionName đã bị từ chối vĩnh viễn. Bạn cần mở cài đặt để cho phép thủ công.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Không'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Mở cài đặt'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<bool> _requestMicrophonePermission() async {
    final logger = ref.read(loggerProvider);
    try {
      logger.info('BroadcastScreen: Requesting microphone permission...');
      
      final status = await _checkAndRequestPermission(Permission.microphone, 'microphone');
      
      if (status.isGranted) {
        return true;
      } else {
        // Hiển thị thông báo cho người dùng nếu quyền bị từ chối
        if (mounted && !status.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cần cấp quyền truy cập microphone để có âm thanh khi phát sóng'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      logger.error('BroadcastScreen: Microphone permission request error - $e');
      return false;
    }
  }

  Future<bool> _requestCameraPermission() async {
    final logger = ref.read(loggerProvider);
    try {
      logger.info('BroadcastScreen: Requesting camera permission...');
      
      final status = await _checkAndRequestPermission(Permission.camera, 'camera');
      
      if (status.isGranted) {
        return true;
      } else {
        // Hiển thị thông báo cho người dùng nếu quyền bị từ chối
        if (mounted && !status.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cần cấp quyền truy cập camera để sử dụng tính năng này'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      logger.error('BroadcastScreen: Camera permission request error - $e');
      return false;
    }
  }

  Future<bool> _requestDevicePermission() async {
    final logger = ref.read(loggerProvider);
    try {
      if (_selectedDevice == null) return false;
      
      logger.info('BroadcastScreen: Requesting device permission...');
      final result = await UvcCamera.requestDevicePermission(_selectedDevice!);
      logger.info('BroadcastScreen: Device permission result: $result');
      return result;
    } catch (e) {
      logger.error('BroadcastScreen: Device permission request error - $e');
      return false;
    }
  }

  // Phương thức xử lý lỗi toàn diện
  Future<void> _handleBroadcastingError(Exception error, {String contextMessage = ''}) async {
    final logger = ref.read(loggerProvider);
    
    try {
      // Ghi log lỗi
      await logger.error('BroadcastScreen: Error $contextMessage - $error');
      
      // Hiển thị lỗi trên UI
      setState(() {
        _errorMessage = 'Lỗi $contextMessage: ${error.toString()}';
      });
      
      // Nếu đang phát sóng, thử chuyển sang chế độ fallback
      if (_isBroadcasting && !_isUsingFallbackStream) {
        try {
          await logger.info('BroadcastScreen: Attempting fallback mode after error');
          
          // Kiểm tra xem stream hiện tại có vấn đề không
          bool currentStreamHasIssues = false;
          
          if (_localStream != null) {
            try {
              final videoTracks = _localStream!.getVideoTracks();
              final audioTracks = _localStream!.getAudioTracks();
              
              // Kiểm tra nếu các track có vấn đề
              if (videoTracks.isEmpty || audioTracks.isEmpty || 
                  videoTracks.any((track) => !track.enabled) || 
                  audioTracks.any((track) => !track.enabled)) {
                currentStreamHasIssues = true;
              }
            } catch (trackError) {
              await logger.error('BroadcastScreen: Error checking stream tracks - $trackError');
              currentStreamHasIssues = true;
            }
          } else {
            currentStreamHasIssues = true;
          }
          
          // Chỉ tạo fallback khi stream có vấn đề
          if (currentStreamHasIssues) {
            await _createFallbackStream();
            
            // Thông báo cho người dùng
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã chuyển sang chế độ phát sóng dự phòng do lỗi'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        } catch (fallbackError) {
          // Ghi log nếu fallback cũng thất bại
          await logger.error('BroadcastScreen: Fallback creation failed - $fallbackError');
          
          // Nếu fallback cũng thất bại, thử phương án không có media
          if (_isBroadcasting && _webRTCService != null) {
            try {
              final user = ref.read(currentUserProvider);
              if (user != null) {
                await logger.warning('BroadcastScreen: Attempting broadcast without media as last resort');
                
                // Dọn dẹp stream hiện tại nếu có
                if (_localStream != null) {
                  _localStream!.getTracks().forEach((track) {
                    try { track.stop(); } catch (_) {}
                  });
                  _localStream!.dispose();
                  _localStream = null;
                }
                
                // Bật chế độ fallback UI
                _isUsingFallbackStream = true;
                _staticNoiseTimer = Timer.periodic(Duration(milliseconds: 200), (_) {
                  if (mounted) setState(() {/* trigger UI update */});
                });
                
                // Thông báo cho người dùng
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang sử dụng chế độ dự phòng cuối cùng - không có video và âm thanh'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              }
            } catch (noMediaError) {
              await logger.error('BroadcastScreen: No-media fallback also failed - $noMediaError');
            }
          }
        }
      }
    } catch (handlingError) {
      // Ghi log nếu xử lý lỗi cũng gặp vấn đề
      await logger.error('BroadcastScreen: Error while handling error - $handlingError');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Phát sóng'),
        ),
        body: Center(
          child: Text('Vui lòng đăng nhập để phát sóng'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phát sóng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAvailableDevices,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Camera selection
            if (_selectedDevice == null) ...[
              const Text(
                'Chọn một camera để bắt đầu:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _isLoadingDevices
                  ? const Center(child: CircularProgressIndicator())
                  : _availableDevices.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              const Text('Không tìm thấy camera UVC nào'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadAvailableDevices,
                                child: const Text('Tải lại'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _availableDevices.length,
                          itemBuilder: (context, index) {
                            final device = _availableDevices[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.videocam),
                                title: Text(device.name),
                                subtitle: Text(
                                    '${device.vendorId}:${device.productId}'),
                                trailing: ElevatedButton(
                                  onPressed: () => _initializeCamera(device),
                                  child: const Text('Kết nối'),
                                ),
                              ),
                            );
                          },
                        ),
              const SizedBox(height: 16),
            ] else ...[
              // Camera preview
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isInitializing
                    ? const Center(child: CircularProgressIndicator())
                    : _isCameraConnected
                        ? Stack(
                            children: [
                              ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                                child: _isBroadcasting && _localRenderer != null && _localStream != null
                                    ? RTCVideoView(
                              _localRenderer!,
                                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                      )
                                    : _cameraController != null && _cameraController!.value.isInitialized
                                        ? UvcCameraPreview(
                                            _cameraController!,
                                          )
                                        : _isUsingFallbackStream
                                            ? Stack(
                                                children: [
                                                  CustomPaint(
                                                    size: Size(300, 300),
                                                    painter: StaticNoisePainter(_random),
                                                  ),
                                                  // Fallback mode warning
                                                  Positioned.fill(
                                                    child: Center(
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(0.6),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              Icons.warning_amber_rounded,
                                                              color: Colors.amber,
                                                              size: 48,
                                                            ),
                                                            const SizedBox(height: 12),
                                                            const Text(
                                                              'Đang sử dụng chế độ dự phòng',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 8),
                                                            const Text(
                                                              'Không thể kết nối với camera, nhưng vẫn đang phát sóng.',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: Colors.white70,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const Center(
                                                child: Text(
                                                  'Đang kết nối camera...',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                              ),
                              // Indicator to show current mode
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _isBroadcasting 
                                      ? (_isUsingFallbackStream ? Colors.orange.withOpacity(0.8) : Colors.red.withOpacity(0.8)) 
                                      : Colors.grey.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isBroadcasting 
                                          ? (_isUsingFallbackStream ? Icons.warning : Icons.videocam) 
                                          : Icons.preview,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _isBroadcasting 
                                          ? (_isUsingFallbackStream ? 'FALLBACK MODE' : 'ĐANG PHÁT SÓNG') 
                                          : 'CHẾ ĐỘ PREVIEW',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Recording indicator (pulsing red dot) when broadcasting
                              if (_isBroadcasting)
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.7),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          _initializeCameraController(),
                                      child: const Text('Kết nối lại'),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedDevice = null;
                                          _isCameraConnected = false;
                                        });
                                      },
                                      child: const Text('Chọn camera khác'),
                                    ),
                                  ],
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
                        'Camera: ${_selectedDevice!.name}',
                        style: const TextStyle(fontSize: 14),
                      ),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isCameraConnected
                                    ? _startBroadcasting
                                    : null,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Bắt đầu phát sóng'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
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

// Widget vẽ nhiễu cho fallback stream
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
