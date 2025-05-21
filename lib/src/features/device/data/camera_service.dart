import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uvccamera/uvccamera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  Future<List<UvcCameraDevice>> getConnectedCameras() async {
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
      
      return devices.values.toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> requestCameraPermission(UvcCameraDevice device) async {
    return await UvcCamera.requestDevicePermission(device);
  }
}

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
}); 