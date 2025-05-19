import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vibration/vibration.dart';

part 'vibration_service.g.dart';

class VibrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _vibrationSubscription;
  final String userId;

  VibrationService({required this.userId});

  Future<bool> isVibrationSupported() async {
    return await Vibration.hasVibrator() ?? false;
  }

  void startListening() async {
    final isSupported = await isVibrationSupported();
    if (!isSupported) return;

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

  void stopListening() {
    _vibrationSubscription?.cancel();
    _vibrationSubscription = null;
  }

  void dispose() {
    stopListening();
  }
}

@riverpod
VibrationService vibrationService(VibrationServiceRef ref, String userId) {
  final service = VibrationService(userId: userId);
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
}

@Riverpod(keepAlive: true)
class VibrationController extends _$VibrationController {
  StreamSubscription? _serviceSubscription;
  
  @override
  bool build() {
    ref.onDispose(() {
      _serviceSubscription?.cancel();
    });
    
    return false; // Initially not active
  }

  Future<void> startVibrationService(String userId) async {
    final service = ref.read(vibrationServiceProvider(userId));
    final isSupported = await service.isVibrationSupported();
    
    if (isSupported) {
      service.startListening();
      state = true;
    } else {
      state = false;
    }
  }

  void stopVibrationService() {
    state = false;
    _serviceSubscription?.cancel();
    _serviceSubscription = null;
  }
}
