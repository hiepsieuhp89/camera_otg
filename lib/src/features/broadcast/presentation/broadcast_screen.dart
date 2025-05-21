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

// Import debug helper
import 'package:lavie/src/features/broadcast/presentation/debug_helper.dart';
import 'package:lavie/src/features/broadcast/presentation/mock_camera_service.dart';

@RoutePage()
class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> with DebugModeToggle, WidgetsBindingObserver {
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
    DebugModeToggle.setRef(this, ref);
    _initializeWithLogging();
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

      // Kiểm tra tình trạng quyền truy cập
      if (!_hasDevicePermission || !_hasCameraPermission) {
        await logger.error('BroadcastScreen: Permissions not granted');
        throw Exception('Không có quyền truy cập cần thiết');
      }
      
      // Kiểm tra lại trạng thái kết nối
      if (!_isDeviceAttached || !_isDeviceConnected) {
        await logger.error('BroadcastScreen: Device not connected');
        throw Exception('Thiết bị camera không được kết nối');
      }

      await logger.info('BroadcastScreen: Getting user media...');
      
      // Bọc getUserMedia trong try-catch riêng để xử lý lỗi cụ thể
      try {
        // Sử dụng deviceId exact và thiết lập kích thước hợp lý
        Map<String, dynamic> mediaConstraints = {
          'audio': true,
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
        
        await logger.info('BroadcastScreen: Media stream obtained successfully');
      } catch (e) {
        await logger.error('BroadcastScreen: Error getting user media - $e');
        
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
      final completer = Completer<MediaStream?>();
      
      // Tạo timer cho timeout
      final timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          logger.error('BroadcastScreen: getUserMedia timeout after ${timeout.inSeconds} seconds');
          completer.complete(null);
        }
      });
      
      // Gọi getUserMedia trong try-catch
      try {
        final stream = await navigator.mediaDevices.getUserMedia(constraints);
        if (!completer.isCompleted) {
          completer.complete(stream);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          logger.error('BroadcastScreen: getUserMedia error - $e');
          completer.completeError(e);
        }
      }
      
      // Hủy timer nếu hoàn thành trước timeout
      final result = await completer.future;
      timer.cancel();
      return result;
    } catch (e) {
      logger.error('BroadcastScreen: _getUserMediaWithTimeout error - $e');
      return null;
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

      // Kiểm tra xem có đang ở debug mode không
      final isDebugMode = ref.read(debugModeProvider);
      final mockService = ref.read(mockCameraServiceProvider);
      
      List<UvcCameraDevice> deviceList = [];
      
      if (isDebugMode && mockService.isOverriding) {
        // Sử dụng mock devices
        await logger.info('BroadcastScreen: Using mock camera devices in debug mode');
        final mockDevices = await mockService.getMockDevices();
        
        // Convert mock devices to UvcCameraDevice objects
        for (final entry in mockDevices.entries) {
          final mock = entry.value;
          deviceList.add(UvcCameraDevice(
            name: mock['name'] as String,
            vendorId: (mock['vendorId'] as int?) ?? 0,
            productId: (mock['productId'] as int?) ?? 0,
            deviceClass: 0,
            deviceSubclass: 0,
          ));
        }
      } else {
        // Kiểm tra thiết bị thật
        final isSupported = await UvcCamera.isSupported();
        if (!isSupported) {
          await logger.warning('BroadcastScreen: UVC camera not supported on this device');
          
          if (isDebugMode) {
            // Tự động chuyển sang mock mode nếu đang debug
            mockService.setOverrideMode(true);
            final mockDevices = await mockService.getMockDevices();
            
            // Convert mock devices to UvcCameraDevice objects
            for (final entry in mockDevices.entries) {
              final mock = entry.value;
              deviceList.add(UvcCameraDevice(
                name: mock['name'] as String,
                vendorId: (mock['vendorId'] as int?) ?? 0,
                productId: (mock['productId'] as int?) ?? 0,
                deviceClass: 0,
                deviceSubclass: 0,
              ));
            }
          } else {
            throw Exception('Thiết bị không hỗ trợ camera UVC');
          }
        } else {
          // Sử dụng thiết bị thật
          final devices = await UvcCamera.getDevices();
          deviceList = devices.values.toList();
        }
      }
      
      await logger.info('BroadcastScreen: Found ${deviceList.length} devices');
      
      if (deviceList.isEmpty) {
        throw Exception('Không tìm thấy camera UVC');
      }

      setState(() {
        _availableDevices = deviceList;
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
      
      // Sử dụng stream từ mock service hoặc UvcCamera tùy vào chế độ
      final isDebugMode = ref.read(debugModeProvider);
      final mockService = ref.read(mockCameraServiceProvider);
      
      if (isDebugMode && mockService.isOverriding) {
        // For mock service, create a subscription that transforms mock events
        mockService.deviceEventStream.listen((mockEvent) {
          try {
            // Check if we have a selected device
            if (_selectedDevice == null) {
              logger.info('BroadcastScreen: Received mock event but no device is selected');
              return;
            }
            
            final eventType = mockEvent['type'] as String;
            final deviceName = mockEvent['device'] as String?;
            
            // Only process events for our selected device
            if (deviceName == null || deviceName != _selectedDevice!.name) {
              return;
            }
            
            // Convert mock event type to UvcCameraDeviceEventType
            UvcCameraDeviceEventType uvcEventType;
            switch (eventType) {
              case 'attached':
                uvcEventType = UvcCameraDeviceEventType.attached;
                break;
              case 'detached':
                uvcEventType = UvcCameraDeviceEventType.detached;
                break;
              case 'connected':
                uvcEventType = UvcCameraDeviceEventType.connected;
                break;
              case 'disconnected':
                uvcEventType = UvcCameraDeviceEventType.disconnected;
                break;
              default:
                return; // Ignore other event types
            }
            
            // Handle the device event with same logic as real events
            _processDeviceEvent(_selectedDevice!, uvcEventType);
          } catch (e) {
            logger.error('BroadcastScreen: Error processing mock device event - $e');
          }
        }, onError: (e) {
          logger.error('BroadcastScreen: Mock device event stream error - $e');
        });
      } else {
        // Use real UvcCamera device events
        _deviceEventSubscription = UvcCamera.deviceEventStream.listen((event) {
          // Check if this event is for our selected device
          if (_selectedDevice == null || event.device.name != _selectedDevice!.name) {
            return;
          }
          
          // Process the device event
          _processDeviceEvent(event.device, event.type);
        }, onError: (e) {
          logger.error('BroadcastScreen: Device event stream error - $e');
        });
      }
      
      logger.info('BroadcastScreen: Device event listener started');
    } catch (e) {
      logger.error('BroadcastScreen: Error starting device event listener - $e');
    }
  }
  
  // Helper method to process device events consistently
  void _processDeviceEvent(UvcCameraDevice device, UvcCameraDeviceEventType eventType) {
    final logger = ref.read(loggerProvider);
    
    try {
      logger.info('BroadcastScreen: Device event: $eventType for device: ${device.name}');
      
      // Process each event type
      if (eventType == UvcCameraDeviceEventType.attached) {
        // Thiết bị được kết nối vật lý
        setState(() {
          _isDeviceAttached = true;
          _isDeviceConnected = false;
        });
        
        // Yêu cầu quyền truy cập
        Future.microtask(() => _requestPermissions());
        
      } else if (eventType == UvcCameraDeviceEventType.detached) {
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
      } else if (eventType == UvcCameraDeviceEventType.connected) {
        logger.info('BroadcastScreen: Device connected: ${device.name}');
        
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
      } else if (eventType == UvcCameraDeviceEventType.disconnected) {
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
  }

  Future<void> _requestPermissions() async {
    final logger = ref.read(loggerProvider);
    try {
      logger.info('BroadcastScreen: Requesting permissions...');
      
      final hasCameraPermission = await _requestCameraPermission();
      setState(() {
        _hasCameraPermission = hasCameraPermission;
      });

      if (!hasCameraPermission) {
        logger.warning('BroadcastScreen: Camera permission denied');
        return;
      }

      if (_selectedDevice != null) {
        final hasDevicePermission = await _requestDevicePermission();
        setState(() {
          _hasDevicePermission = hasDevicePermission;
        });
      }
    } catch (e) {
      logger.error('BroadcastScreen: Permission request error - $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    final logger = ref.read(loggerProvider);
    try {
      logger.info('BroadcastScreen: Requesting camera permission...');
      var status = await Permission.camera.status;
      if (status.isGranted) {
        logger.info('BroadcastScreen: Camera permission already granted');
        return true;
      }
      
      status = await Permission.camera.request();
      logger.info('BroadcastScreen: Camera permission result: ${status.isGranted}');
      return status.isGranted;
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
    
    if (!_isCameraConnected || _cameraController == null || !_cameraController!.value.isInitialized) {
      await logger.warning('BroadcastScreen: Cannot start broadcasting - camera not ready');
      setState(() {
        _errorMessage = 'Camera chưa được kết nối hoặc khởi tạo';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      await logger.info('BroadcastScreen: Starting broadcast...');
      
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('Chưa đăng nhập');
      }

      // Kiểm tra quyền truy cập microphone
      final micPermission = await Permission.microphone.status;
      if (!micPermission.isGranted) {
        await logger.info('BroadcastScreen: Requesting microphone permission...');
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          await logger.warning('BroadcastScreen: Microphone permission denied');
          
          // Hiển thị cảnh báo
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không có quyền truy cập microphone. Phát sóng sẽ không có âm thanh.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          
          // Tiếp tục dù không có âm thanh
        }
      }
      
      // 1. Thiết lập WebRTC service
      try {
        await _setupWebRTCForBroadcasting();
      } catch (e) {
        await logger.error('BroadcastScreen: Failed to setup WebRTC service - $e');
        throw Exception('Không thể khởi tạo dịch vụ WebRTC: $e');
      }

      // 2. Tạo media stream với catch toàn diện
      bool mediaStreamSuccess = false;
      try {
        await logger.info('BroadcastScreen: Attempting to create media stream with full video+audio');
        await _createMediaStreamForBroadcasting();
        mediaStreamSuccess = _localStream != null || _isUsingFallbackStream;
      } catch (streamError) {
        await logger.error('BroadcastScreen: Media stream creation failed completely - $streamError');
        mediaStreamSuccess = false;
      }

      // Nếu vẫn thất bại, sử dụng phương pháp phát không có media cuối cùng
      if (!mediaStreamSuccess && !_isUsingFallbackStream) {
        await logger.warning('BroadcastScreen: All media stream methods failed, using no-media broadcast');
        _isUsingFallbackStream = true;
        
        _staticNoiseTimer = Timer.periodic(Duration(milliseconds: 200), (_) {
          if (mounted) setState(() {/* trigger UI update */});
        });
      }

      // 3. Bắt đầu phát sóng với phương thức phù hợp
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

      // 4. Cập nhật trạng thái thiết bị
      if (_selectedDeviceId != null) {
        await logger.info('BroadcastScreen: Updating device broadcasting status...');
        final deviceService = ref.read(deviceServiceProvider);
        await deviceService.startBroadcasting(_selectedDeviceId!);
      }

      // 5. Bắt đầu lắng nghe tín hiệu rung
      _startListeningForSignals();
      
      // 6. Bắt đầu cập nhật trạng thái thiết bị định kỳ
      _startStatusUpdates();

      // 7. Cập nhật UI trạng thái
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
      for (int i = 0; i < count; i++) {
        await HapticFeedback.heavyImpact();
        if (i < count - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
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
    final isDebugMode = ref.watch(debugModeProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Phát sóng'),
        ),
        body: Stack(
          children: [
            Center(
              child: Text('Vui lòng đăng nhập để phát sóng'),
            ),
            // Add the debug tap area
            buildDebugTapArea(),
          ],
        ),
      ).withDebugControls();
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                                    leading: isDebugMode && device.name.contains('Mock') 
                                      ? const Icon(Icons.bug_report, color: Colors.orange)
                                      : const Icon(Icons.videocam),
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
                                  
                                  // Debug mode indicator
                                  if (isDebugMode)
                                    Positioned(
                                      top: 50,
                                      right: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.bug_report,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'DEBUG MODE',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ],
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
          // Add debug controls
          buildDebugTapArea(),
          buildDebugControls(context),
        ],
      ),
    ).withDebugControls();
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
