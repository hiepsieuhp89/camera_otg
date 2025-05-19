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
        debugPrint('Device: ${device['name']} (VID: ${device['vid']}, PID: ${device['pid']})');
      }
      return devices.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error getting USB devices: $e');
      throw Exception('Failed to get connected devices: $e');
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
      throw Exception('Failed to check device connection: $e');
    }
  }
  
  /// Pair a broadcaster with a viewer
  Future<void> pairDevices(String broadcasterId, String viewerId) async {
    try {
      debugPrint('Pairing devices: Broadcaster=$broadcasterId, Viewer=$viewerId');
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
        debugPrint('No USB devices connected');
        throw Exception('No USB devices connected. Please connect your camera via OTG.');
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
