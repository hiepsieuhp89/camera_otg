import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/core/providers/logger_provider.dart';
import 'package:lavie/src/features/auth/domain/user_model.dart';

// Device model
class DeviceModel {
  final String id;
  final String name;
  final String ownerId;
  final bool isActive;
  final bool isBroadcasting;
  final DateTime lastSeen;
  final String? viewerId;

  DeviceModel({
    required this.id,
    required this.name,
    required this.ownerId,
    this.isActive = true,
    this.isBroadcasting = false,
    required this.lastSeen,
    this.viewerId,
  });

  factory DeviceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeviceModel(
      id: doc.id,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      isActive: data['isActive'] ?? false,
      isBroadcasting: data['isBroadcasting'] ?? false,
      lastSeen: (data['lastSeen'] as Timestamp).toDate(),
      viewerId: data['viewerId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ownerId': ownerId,
      'isActive': isActive,
      'isBroadcasting': isBroadcasting,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'viewerId': viewerId,
    };
  }

  DeviceModel copyWith({
    String? id,
    String? name,
    String? ownerId,
    bool? isActive,
    bool? isBroadcasting,
    DateTime? lastSeen,
    String? viewerId,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      isActive: isActive ?? this.isActive,
      isBroadcasting: isBroadcasting ?? this.isBroadcasting,
      lastSeen: lastSeen ?? this.lastSeen,
      viewerId: viewerId != null ? viewerId : this.viewerId,
    );
  }
}

class DeviceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _devicesCollection = FirebaseFirestore.instance.collection('devices');
  
  // Get all available devices (not paired with any user)
  Future<List<DeviceModel>> getAvailableDevices() async {
    try {
      QuerySnapshot snapshot = await _devicesCollection
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => DeviceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all active broadcaster devices
  Future<List<DeviceModel>> getActiveBroadcasterDevices() async {
    try {
      QuerySnapshot snapshot = await _devicesCollection
          .where('isActive', isEqualTo: true)
          .where('isBroadcasting', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => DeviceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Register a new device
  Future<DeviceModel> registerDevice(String deviceId, String deviceName, String ownerId) async {
    try {
      // Check if device already exists
      DocumentSnapshot doc = await _devicesCollection.doc(deviceId).get();
      
      if (doc.exists) {
        // Update existing device
        await _devicesCollection.doc(deviceId).update({
          'name': deviceName,
          'ownerId': ownerId,
          'isActive': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new device
        await _devicesCollection.doc(deviceId).set({
          'name': deviceName,
          'ownerId': ownerId,
          'isActive': true,
          'isBroadcasting': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
      
      // Get the updated/created device
      DocumentSnapshot updatedDoc = await _devicesCollection.doc(deviceId).get();
      return DeviceModel.fromFirestore(updatedDoc);
    } catch (e) {
      rethrow;
    }
  }
  
  // Start broadcasting with a device
  Future<void> startBroadcasting(String deviceId) async {
    try {
      await _devicesCollection.doc(deviceId).update({
        'isBroadcasting': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Stop broadcasting with a device
  Future<void> stopBroadcasting(String deviceId) async {
    try {
      await _devicesCollection.doc(deviceId).update({
        'isBroadcasting': false,
        'viewerId': null,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Connect a viewer to a broadcasting device
  Future<void> connectViewer(String deviceId, String viewerId) async {
    try {
      await _devicesCollection.doc(deviceId).update({
        'viewerId': viewerId,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Disconnect a viewer from a broadcasting device
  Future<void> disconnectViewer(String deviceId) async {
    try {
      await _devicesCollection.doc(deviceId).update({
        'viewerId': null,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Update device status
  Future<void> updateDeviceStatus(String deviceId, {bool? isActive, bool? isBroadcasting}) async {
    try {
      final Map<String, dynamic> updates = {
        'lastSeen': FieldValue.serverTimestamp(),
      };
      
      if (isActive != null) {
        updates['isActive'] = isActive;
      }
      
      if (isBroadcasting != null) {
        updates['isBroadcasting'] = isBroadcasting;
        if (!isBroadcasting) {
          updates['viewerId'] = null;
        }
      }
      
      await _devicesCollection.doc(deviceId).update(updates);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get a specific device
  Future<DeviceModel?> getDevice(String deviceId) async {
    try {
      DocumentSnapshot doc = await _devicesCollection.doc(deviceId).get();
      if (doc.exists) {
        return DeviceModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get devices owned by a specific user
  Future<List<DeviceModel>> getUserDevices(String userId) async {
    try {
      QuerySnapshot snapshot = await _devicesCollection
          .where('ownerId', isEqualTo: userId)
          .get();
      
      return snapshot.docs
          .map((doc) => DeviceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Listen to changes on a specific device
  Stream<DeviceModel?> deviceStream(String deviceId) {
    return _devicesCollection.doc(deviceId).snapshots().map((doc) {
      if (doc.exists) {
        return DeviceModel.fromFirestore(doc);
      }
      return null;
    });
  }
  
  // Send a vibration signal to a broadcasting device
  Future<void> sendVibrationSignal(String deviceId, int count) async {
    try {
      // Create a signal in a subcollection
      await _devicesCollection.doc(deviceId).collection('signals').add({
        'type': 'vibration',
        'count': count,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Listen for vibration signals on a device
  Stream<List<VibrationSignal>> vibrationSignalsStream(String deviceId) {
    return _devicesCollection
        .doc(deviceId)
        .collection('signals')
        .where('type', isEqualTo: 'vibration')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return VibrationSignal(
              id: doc.id,
              count: data['count'] ?? 1,
              timestamp: (data['timestamp'] as Timestamp).toDate(),
            );
          }).toList();
        });
  }
}

// Vibration signal model
class VibrationSignal {
  final String id;
  final int count;
  final DateTime timestamp;
  
  VibrationSignal({
    required this.id,
    required this.count,
    required this.timestamp,
  });
}

// Device service provider
final deviceServiceProvider = Provider<DeviceService>((ref) {
  final logger = ref.watch(loggerProvider);
  return DeviceService();
}); 