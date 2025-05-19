import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/features/auth/domain/user_model.dart';

/// Service to manage device pairing between broadcaster and viewer
class DevicePairingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Pair a broadcaster with a viewer
  Future<void> pairDevices(String broadcasterId, String viewerId) async {
    try {
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
    } catch (e) {
      throw Exception('Failed to pair devices: $e');
    }
  }
  
  /// Unpair devices
  Future<void> unpairDevices(String userId) async {
    try {
      // Get user data to find paired device
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      
      final userData = userDoc.data();
      final pairedDeviceId = userData?['pairedDeviceId'] as String?;
      
      if (pairedDeviceId != null) {
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
      } else {
        // Just update the current user if no paired device
        await _firestore.collection('users').doc(userId).update({
          'pairedDeviceId': null,
        });
      }
    } catch (e) {
      throw Exception('Failed to unpair devices: $e');
    }
  }
  
  /// Find available users to pair with
  Future<List<Map<String, dynamic>>> findAvailableUsers(UserRole targetRole) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: targetRole.toString().split('.').last)
          .where('pairedDeviceId', isNull: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'displayName': doc.data()['displayName'],
                'email': doc.data()['email'],
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to find available users: $e');
    }
  }
}

/// Provider for the device pairing service
final devicePairingServiceProvider = Provider<DevicePairingService>((ref) {
  return DevicePairingService();
});
