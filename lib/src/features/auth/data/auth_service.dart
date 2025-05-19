import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lavie/src/features/auth/domain/user_model.dart';

part 'auth_service.g.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin credentials (fixed values as requested)
  static const String adminEmail = 'admin@lavie.com';
  static const String adminPassword = 'Admin@123';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        return getUserData(userCredential.user!.uid);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Create a new user account (only admin can do this)
  Future<UserModel?> createUserAccount(
      String email, String password, String displayName, UserRole role) async {
    try {
      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Create user document in Firestore
        final UserModel newUser = UserModel(
          id: userCredential.user!.uid,
          email: email,
          role: role,
          displayName: displayName,
          isLoggedIn: false,
        );
        
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toJson());
        
        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      final DocumentSnapshot doc = 
          await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update user device ID
  Future<void> updateUserDeviceId(String userId, String deviceId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'deviceId': deviceId,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Pair devices (link broadcaster and viewer)
  Future<void> pairDevices(String broadcasterId, String viewerId) async {
    try {
      // Update broadcaster
      await _firestore.collection('users').doc(broadcasterId).update({
        'pairedDeviceId': viewerId,
      });
      
      // Update viewer
      await _firestore.collection('users').doc(viewerId).update({
        'pairedDeviceId': broadcasterId,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is admin
  bool isAdmin(UserModel user) {
    return user.role == UserRole.admin;
  }

  // Check if user is broadcaster
  bool isBroadcaster(UserModel user) {
    return user.role == UserRole.broadcaster;
  }

  // Check if user is viewer
  bool isViewer(UserModel user) {
    return user.role == UserRole.viewer;
  }
}

@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService();
}

@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  @override
  UserModel? build() {
    return null;
  }

  Future<void> login(String email, String password) async {
    final authService = ref.read(authServiceProvider);
    final user = await authService.signInWithEmailAndPassword(email, password);
    state = user;
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    state = null;
  }

  Future<void> createUser(String email, String password, String displayName, UserRole role) async {
    final authService = ref.read(authServiceProvider);
    await authService.createUserAccount(email, password, displayName, role);
  }

  Future<void> updateDeviceId(String deviceId) async {
    if (state == null) return;
    
    final authService = ref.read(authServiceProvider);
    await authService.updateUserDeviceId(state!.id, deviceId);
    state = state!.copyWith(deviceId: deviceId);
  }

  Future<void> pairWithDevice(String otherDeviceId) async {
    if (state == null) return;
    
    final authService = ref.read(authServiceProvider);
    await authService.pairDevices(state!.id, otherDeviceId);
    state = state!.copyWith(pairedDeviceId: otherDeviceId);
  }
}
