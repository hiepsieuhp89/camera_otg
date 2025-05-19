import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

/// A service to handle vibration signals between devices
class VibrationHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _vibrationSubscription;
  final String userId;
  
  VibrationHandler({required this.userId});
  
  /// Start listening for vibration signals
  Future<void> startListening() async {
    final isSupported = await Vibration.hasVibrator();
    if (isSupported != true) return;
    
    _vibrationSubscription = _firestore
        .collection('vibrations')
        .where('toUserId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final pattern = data['pattern'] as int;
        
        // Execute vibration based on pattern
        if (pattern == 1) {
          Vibration.vibrate(duration: 300);
        } else if (pattern == 2) {
          Vibration.vibrate(pattern: [0, 300, 100, 300]);
        }
        
        // Delete the vibration request after processing
        await snapshot.docs.first.reference.delete();
      }
    });
  }
  
  /// Send a vibration signal to another device
  Future<void> sendVibration(String targetUserId, int pattern) async {
    try {
      await _firestore.collection('vibrations').add({
        'fromUserId': userId,
        'toUserId': targetUserId,
        'pattern': pattern,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Also vibrate the current device for feedback
      if (pattern == 1) {
        Vibration.vibrate(duration: 300);
      } else if (pattern == 2) {
        Vibration.vibrate(pattern: [0, 300, 100, 300]);
      }
    } catch (e) {
      print('Error sending vibration: $e');
    }
  }
  
  /// Stop listening for vibration signals
  void stopListening() {
    _vibrationSubscription?.cancel();
    _vibrationSubscription = null;
  }
  
  /// Dispose the handler
  void dispose() {
    stopListening();
  }
}

/// Provider for the vibration handler
final vibrationHandlerProvider = Provider.family<VibrationHandler, String>(
  (ref, userId) {
    final handler = VibrationHandler(userId: userId);
    ref.onDispose(() {
      handler.dispose();
    });
    return handler;
  },
);
