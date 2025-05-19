import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';
import 'package:lavie/src/core/utils/logger_service.dart';

// Provider để quản lý UVC camera controller
final uvcCameraControllerProvider = Provider<UVCCameraController>((ref) {
  final controller = UVCCameraController();
  ref.onDispose(() {
    controller.closeCamera();
    controller.dispose();
  });
  return controller;
});

@RoutePage()
class UVCCameraScreen extends ConsumerStatefulWidget {
  const UVCCameraScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UVCCameraScreen> createState() => _UVCCameraScreenState();
}

class _UVCCameraScreenState extends ConsumerState<UVCCameraScreen> {
  final LoggerService _logger = LoggerService();
  bool _isLoading = true;
  String _statusMessage = "Đang khởi tạo...";
  bool _isRecording = false;
  bool _isCameraOpen = false;
  List<PreviewSize>? _previewSizes;
  PreviewSize? _selectedSize;
  
  @override
  void initState() {
    super.initState();
    _logger.info('UVC Camera screen initialized');
    _initUVCCamera();
  }
  
  Future<void> _initUVCCamera() async {
    try {
      final controller = ref.read(uvcCameraControllerProvider);
      
      // Thiết lập các callback
      controller.cameraStateCallback = (state) {
        _logger.info('Camera state changed: $state');
        setState(() {
          _isCameraOpen = state == UVCCameraState.opened;
          
          if (state == UVCCameraState.opened) {
            _statusMessage = "Camera đã mở";
            _getPreviewSizes();
          } else if (state == UVCCameraState.closed) {
            _statusMessage = "Camera đã đóng";
          }
        });
      };
      
      controller.msgCallback = (msg) {
        _logger.info('Camera message: $msg');
        
        // Xử lý lỗi quyền từ message
        if (msg.contains("Permission denied")) {
          setState(() {
            _statusMessage = "Không có quyền truy cập USB. Vui lòng thử lại.";
          });
          
          // Hiển thị hướng dẫn
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quyền truy cập USB bị từ chối. Vui lòng rút và cắm lại thiết bị, sau đó thử lại.'),
                duration: Duration(seconds: 10),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          setState(() {
            _statusMessage = msg;
          });
        }
      };
      
      // Khởi tạo camera
      await controller.initializeCamera();
      
      setState(() {
        _isLoading = false;
        _statusMessage = "Sẵn sàng mở camera";
      });
    } catch (e) {
      _logger.error('Failed to initialize UVC Camera: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = "Lỗi khởi tạo camera: $e";
      });
    }
  }
  
  Future<void> _openCamera() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = "Đang mở camera...";
      });
      
      // Cần một khoảng thời gian nhỏ để đảm bảo view đã được khởi tạo đầy đủ
      await Future.delayed(const Duration(milliseconds: 500));
      
      final controller = ref.read(uvcCameraControllerProvider);
      
      // Hiển thị hội thoại hướng dẫn người dùng về quyền USB
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chấp nhận quyền truy cập USB khi được hỏi'),
          duration: Duration(seconds: 5),
        ),
      );
      
      // Thử mở camera với cách tiếp cận khác, thử lại nhiều lần
      bool success = false;
      int retryCount = 0;
      const maxRetries = 3;
      
      while (!success && retryCount < maxRetries) {
        try {
          _logger.info('Thử mở camera lần ${retryCount + 1}');
          controller.openUVCCamera();
          
          // Chờ một chút để xem kết quả
          await Future.delayed(const Duration(seconds: 1));
          
          // Nếu không có lỗi được throw ra, xem như thành công
          success = true;
          _logger.info('Mở camera thành công sau ${retryCount + 1} lần thử');
        } catch (e) {
          _logger.error('Lỗi khi thử mở camera lần ${retryCount + 1}: $e');
          retryCount++;
          // Chờ một chút trước khi thử lại
          await Future.delayed(const Duration(seconds: 1));
        }
      }
      
      if (!success) {
        // Nếu vẫn thất bại sau nhiều lần thử
        _logger.error('Không thể mở camera sau $maxRetries lần thử');
        setState(() {
          _isLoading = false;
          _statusMessage = "Không thể mở camera. Vui lòng rút và cắm lại thiết bị USB.";
        });
        
        _showPermissionGuide();
        return;
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _logger.error('Failed to open UVC camera: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = "Lỗi khi mở camera: $e";
      });
      _showPermissionGuide();
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
  
  Future<void> _closeCamera() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = "Đang đóng camera...";
      });
      
      final controller = ref.read(uvcCameraControllerProvider);
      controller.closeCamera();
      
      setState(() {
        _isLoading = false;
        _isCameraOpen = false;
        _selectedSize = null;
        _previewSizes = null;
      });
    } catch (e) {
      _logger.error('Failed to close UVC camera: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = "Lỗi khi đóng camera: $e";
      });
    }
  }
  
  Future<void> _getPreviewSizes() async {
    try {
      final controller = ref.read(uvcCameraControllerProvider);
      final sizes = await controller.getAllPreviewSizes();
      
      setState(() {
        _previewSizes = sizes;
        if (sizes.isNotEmpty) {
          _selectedSize = sizes.first;
          _updateResolution(sizes.first);
        }
      });
    } catch (e) {
      _logger.error('Failed to get preview sizes: $e');
    }
  }
  
  Future<void> _updateResolution(PreviewSize size) async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = "Đang cài đặt độ phân giải ${size.width}x${size.height}...";
      });
      
      final controller = ref.read(uvcCameraControllerProvider);
      controller.updateResolution(size);
      
      setState(() {
        _selectedSize = size;
        _isLoading = false;
        _statusMessage = "Đã cài đặt độ phân giải ${size.width}x${size.height}";
      });
    } catch (e) {
      _logger.error('Failed to update resolution: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = "Lỗi cài đặt độ phân giải: $e";
      });
    }
  }
  
  Future<void> _takePicture() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = "Đang chụp ảnh...";
      });
      
      final controller = ref.read(uvcCameraControllerProvider);
      final path = await controller.takePicture();
      
      setState(() {
        _isLoading = false;
        _statusMessage = path != null 
            ? "Đã lưu ảnh tại: $path" 
            : "Không thể chụp ảnh";
      });
    } catch (e) {
      _logger.error('Failed to take picture: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = "Lỗi khi chụp ảnh: $e";
      });
    }
  }
  
  Future<void> _toggleRecording() async {
    try {
      final controller = ref.read(uvcCameraControllerProvider);
      
      if (_isRecording) {
        setState(() {
          _statusMessage = "Đang dừng ghi video...";
        });
      } else {
        setState(() {
          _statusMessage = "Đang bắt đầu ghi video...";
        });
      }
      
      final path = await controller.captureVideo();
      
      setState(() {
        _isRecording = !_isRecording;
        if (path != null && !_isRecording) {
          _statusMessage = "Đã lưu video tại: $path";
        } else if (_isRecording) {
          _statusMessage = "Đang ghi video...";
        }
      });
    } catch (e) {
      _logger.error('Failed to toggle recording: $e');
      setState(() {
        _statusMessage = "Lỗi khi ${_isRecording ? 'dừng' : 'bắt đầu'} ghi video: $e";
      });
    }
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(uvcCameraControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('UVC Camera'),
      ),
      body: _isLoading 
          ? _buildLoadingView() 
          : Column(
              children: [
                // Status bar
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.blue.shade50,
                  width: double.infinity,
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.contains("Lỗi") ? Colors.red : Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Camera view or placeholder
                Expanded(
                  child: _isCameraOpen
                      ? _buildCameraPreviewView(controller)
                      : _buildCameraPlaceholderWithView(controller),
                ),
              ],
            ),
    );
  }
  
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_statusMessage),
        ],
      ),
    );
  }
  
  Widget _buildCameraPlaceholderWithView(UVCCameraController controller) {
    return Stack(
      children: [
        // The UVCCameraView is always rendered but initially invisible
        Opacity(
          opacity: 0.01, // Almost invisible but still in the widget tree
          child: SizedBox.expand(
            child: UVCCameraView(
              cameraController: controller,
              width: 640,
              height: 480,
            ),
          ),
        ),
        // The placeholder UI shown on top
        Center(
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
                onPressed: _openCamera,
                child: const Text("Mở Camera"),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCameraPreviewView(UVCCameraController controller) {
    return Column(
      children: [
        // Resolution selection
        if (_previewSizes != null && _previewSizes!.isNotEmpty)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _previewSizes!.length,
              itemBuilder: (context, index) {
                final size = _previewSizes![index];
                final isSelected = _selectedSize?.width == size.width && 
                                  _selectedSize?.height == size.height;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text("${size.width ?? 0}x${size.height ?? 0}"),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _updateResolution(size);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        
        // Camera preview
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: _selectedSize != null && _selectedSize!.width != null && _selectedSize!.height != null
                    ? (_selectedSize!.width!.toDouble() / _selectedSize!.height!.toDouble())
                    : 4 / 3,
                child: UVCCameraView(
                  cameraController: controller,
                  width: _selectedSize?.width?.toDouble() ?? 640,
                  height: _selectedSize?.height?.toDouble() ?? 480,
                ),
              ),
            ),
          ),
        ),
        
        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt),
                tooltip: "Chụp ảnh",
                iconSize: 32,
              ),
              IconButton(
                onPressed: _toggleRecording,
                icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
                tooltip: _isRecording ? "Dừng ghi video" : "Ghi video",
                color: _isRecording ? Colors.red : null,
                iconSize: 32,
              ),
              IconButton(
                onPressed: _closeCamera,
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