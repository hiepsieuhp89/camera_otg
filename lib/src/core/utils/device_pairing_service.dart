import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/features/auth/domain/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to manage device pairing between broadcaster and viewer
class DevicePairingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const platform = MethodChannel('com.lavie.app/usb');
  
  /// Get list of connected USB devices
  Future<List<Map<String, dynamic>>> getConnectedDevices() async {
    try {
      debugPrint('Checking for USB devices...');
      final List<dynamic> devices = await platform.invokeMethod('getUsbDevices');
      debugPrint('Found ${devices.length} USB devices:');
      for (var device in devices) {
        debugPrint('Device: ${device['name']} (VID: ${device['vid']}, PID: ${device['pid']}, Source: ${device['source']})');
      }
      return devices.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error getting USB devices: $e');
      // Try requesting permission if the error might be permission-related
      if (e is PlatformException) {
        await _requestUsbPermission();
        // Try again after requesting permission
        try {
          final List<dynamic> devices = await platform.invokeMethod('getUsbDevices');
          debugPrint('After permission request, found ${devices.length} USB devices');
          return devices.cast<Map<String, dynamic>>();
        } catch (retryError) {
          debugPrint('Still failed after permission request: $retryError');
        }
      }
      throw Exception('Failed to get connected devices: $e');
    }
  }
  
  /// Request USB permission for connected devices
  Future<bool> _requestUsbPermission() async {
    try {
      debugPrint('Requesting USB permission...');
      final bool result = await platform.invokeMethod('requestUsbPermission');
      debugPrint('USB permission request result: $result');
      return result;
    } catch (e) {
      debugPrint('Error requesting USB permission: $e');
      return false;
    }
  }

  /// Check if a device is connected via OTG
  Future<bool> isDeviceConnected() async {
    try {
      debugPrint('Checking if any USB devices are connected...');
      final devices = await getConnectedDevices();
      final isConnected = devices.isNotEmpty;
      debugPrint('Device connected: $isConnected');
      return isConnected;
    } catch (e) {
      debugPrint('Error checking device connection: $e');
      // If there was an error getting devices, try requesting permission and check again
      await _requestUsbPermission();
      // Try one more time
      try {
        final devices = await getConnectedDevices();
        final isConnected = devices.isNotEmpty;
        debugPrint('After permission request - Device connected: $isConnected');
        return isConnected;
      } catch (retryError) {
        debugPrint('Still failed after permission request: $retryError');
        throw Exception('Failed to check device connection: $e');
      }
    }
  }
  
  /// Pair a broadcaster with a viewer
  Future<void> pairDevices(String broadcasterId, String viewerId) async {
    try {
      debugPrint('Pairing devices: Broadcaster=$broadcasterId, Viewer=$viewerId');
      
      // Validate inputs
      if (broadcasterId.isEmpty || viewerId.isEmpty) {
        debugPrint('Error: Empty ID detected');
        throw Exception('Broadcaster ID or Viewer ID cannot be empty');
      }
      
      // First check if broadcaster exists
      final broadcasterDoc = await _firestore.collection('users').doc(broadcasterId).get();
      if (!broadcasterDoc.exists) {
        debugPrint('Error: Broadcaster not found: $broadcasterId');
        throw Exception('Broadcaster not found');
      }
      
      // Check if viewer exists
      final viewerDoc = await _firestore.collection('users').doc(viewerId).get();
      if (!viewerDoc.exists) {
        debugPrint('Error: Viewer not found: $viewerId');
        throw Exception('Viewer not found');
      }
      
      debugPrint('Both users found. Proceeding with pairing...');
      
      // Create a transaction to ensure both updates happen or none
      await _firestore.runTransaction((transaction) async {
        // Update broadcaster
        final broadcasterRef = _firestore.collection('users').doc(broadcasterId);
        transaction.update(broadcasterRef, {
          'pairedDeviceId': viewerId,
        });
        
        // Update viewer
        final viewerRef = _firestore.collection('users').doc(viewerId);
        transaction.update(viewerRef, {
          'pairedDeviceId': broadcasterId,
        });
      });
      
      // Verify the pairing was successful
      final updatedBroadcasterDoc = await _firestore.collection('users').doc(broadcasterId).get();
      final updatedViewerDoc = await _firestore.collection('users').doc(viewerId).get();
      
      final broadcasterPairedId = updatedBroadcasterDoc.data()?['pairedDeviceId'] as String?;
      final viewerPairedId = updatedViewerDoc.data()?['pairedDeviceId'] as String?;
      
      debugPrint('Verification - Broadcaster paired with: $broadcasterPairedId');
      debugPrint('Verification - Viewer paired with: $viewerPairedId');
      
      if (broadcasterPairedId != viewerId || viewerPairedId != broadcasterId) {
        debugPrint('Warning: Pairing verification failed');
        throw Exception('Pairing verification failed');
      }
      
      debugPrint('Devices paired successfully');
    } catch (e) {
      debugPrint('Error pairing devices: $e');
      throw Exception('Failed to pair devices: $e');
    }
  }
  
  /// Unpair devices
  Future<void> unpairDevices(String userId) async {
    try {
      debugPrint('Unpairing device for user: $userId');
      // Get user data to find paired device
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      
      final userData = userDoc.data();
      final pairedDeviceId = userData?['pairedDeviceId'] as String?;
      
      if (pairedDeviceId != null) {
        debugPrint('Found paired device: $pairedDeviceId');
        // Create a transaction to ensure both updates happen or none
        await _firestore.runTransaction((transaction) async {
          // Update current user
          final userRef = _firestore.collection('users').doc(userId);
          transaction.update(userRef, {
            'pairedDeviceId': null,
          });
          
          // Update paired device
          final pairedRef = _firestore.collection('users').doc(pairedDeviceId);
          transaction.update(pairedRef, {
            'pairedDeviceId': null,
          });
        });
        debugPrint('Devices unpaired successfully');
      } else {
        debugPrint('No paired device found');
        // Just update the current user if no paired device
        await _firestore.collection('users').doc(userId).update({
          'pairedDeviceId': null,
        });
      }
    } catch (e) {
      debugPrint('Error unpairing devices: $e');
      throw Exception('Failed to unpair devices: $e');
    }
  }
  
  /// Find available users to pair with
  Future<List<Map<String, dynamic>>> findAvailableUsers(UserRole targetRole) async {
    try {
      debugPrint('Finding available users with role: ${targetRole.toString().split('.').last}');
      
      // First check if any USB devices are connected
      final isDeviceConnected = await this.isDeviceConnected();
      if (!isDeviceConnected) {
        // Before giving up, explicitly request permission which might trigger camera detection
        await _requestUsbPermission();
        
        // Check once more after permission request
        final deviceList = await getConnectedDevices();
        if (deviceList.isEmpty) {
          debugPrint('No USB devices connected after permission request');
          throw Exception(
            'Không tìm thấy thiết bị USB nào. '
            'Vui lòng kiểm tra kết nối camera hoặc thiết bị OTG của bạn và thử lại.'
          );
        }
      }

      debugPrint('Querying Firestore for available users...');
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: targetRole.toString().split('.').last)
          .where('pairedDeviceId', isNull: true)
          .get();
      
      final users = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'displayName': doc.data()['displayName'],
                'email': doc.data()['email'],
              })
          .toList();
      
      debugPrint('Found ${users.length} available users');
      return users;
    } catch (e) {
      debugPrint('Error finding available users: $e');
      throw Exception('Failed to find available users: $e');
    }
  }
}

/// Provider for the device pairing service
final devicePairingServiceProvider = Provider<DevicePairingService>((ref) {
  return DevicePairingService();
});
