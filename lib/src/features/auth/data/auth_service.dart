import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/core/providers/logger_provider.dart';
import 'package:lavie/src/core/utils/logger_service.dart';
import 'package:lavie/src/features/auth/domain/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  
  // User authentication state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get the current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  // Create a new user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
  
  // Get user document from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        
        // Check if document has the required data
        if (data == null) {
          print('Document exists but data is null for user: $uid');
          return null;
        }
        
        try {
          return UserModel.fromFirestore(doc);
        } catch (e) {
          print('Error parsing user data: $e');
          // If there's an error in parsing, attempt to repair the document
          await _repairUserDocument(uid, data);
          
          // Fetch the document again after repair
          DocumentSnapshot repairedDoc = await _usersCollection.doc(uid).get();
          if (repairedDoc.exists) {
            return UserModel.fromFirestore(repairedDoc);
          }
        }
      } else {
        print('No user document found for uid: $uid');
      }
      return null;
    } catch (e) {
      print('Error in getUserData: $e');
      rethrow;
    }
  }
  
  // Repair a user document with missing fields
  Future<void> _repairUserDocument(String uid, Map<String, dynamic> existingData) async {
    try {
      final now = Timestamp.now();
      final updates = <String, dynamic>{};
      
      // Check and repair required fields
      if (existingData['createdAt'] == null) {
        updates['createdAt'] = now;
      }
      
      if (existingData['lastLogin'] == null) {
        updates['lastLogin'] = now;
      }
      
      if (existingData['role'] == null) {
        updates['role'] = 'viewer'; // Default role
      }
      
      if (existingData['isActive'] == null) {
        updates['isActive'] = true;
      }
      
      // Only update if there are fields to repair
      if (updates.isNotEmpty) {
        print('Repairing user document for $uid with updates: $updates');
        await _usersCollection.doc(uid).update(updates);
      }
    } catch (e) {
      print('Error repairing user document: $e');
    }
  }
  
  // Create user document in Firestore
  Future<void> createUserData(String uid, String email, String name, UserRole role) async {
    try {
      final now = FieldValue.serverTimestamp();
      await _usersCollection.doc(uid).set({
        'email': email,
        'name': name,
        'role': role.toString().split('.').last,
        'createdAt': now,
        'lastLogin': now,
        'isActive': true,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Update user's last login time
  Future<void> updateLastLogin(String uid) async {
    try {
      // Check if document exists first
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      
      if (doc.exists) {
        // Document exists, update it
        await _usersCollection.doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // Document doesn't exist, create a new one with basic information
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          final email = firebaseUser.email ?? '';
          final name = firebaseUser.displayName ?? email.split('@').first;
          
          await createUserData(uid, email, name, UserRole.viewer);
          print('Created new user document for uid: $uid');
        }
      }
    } catch (e) {
      print('Error in updateLastLogin: $e');
      rethrow;
    }
  }
  
  // Update user's paired device ID
  Future<void> updatePairedDevice(String uid, String? deviceId) async {
    try {
      await _usersCollection.doc(uid).update({
        'pairedDeviceId': deviceId,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Role-based authorization checks
  bool isAdmin(UserModel user) => user.role == UserRole.admin;
  bool isBroadcaster(UserModel user) => user.role == UserRole.broadcaster;
  bool isViewer(UserModel user) => user.role == UserRole.viewer;
  
  // Get all users (for admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _usersCollection.get();
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Update user data (for admin)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete user (for admin)
  Future<void> deleteUser(String uid) async {
    try {
      // Delete from Firestore
      await _usersCollection.doc(uid).delete();
      
      // If user is currently signed in, also delete from Firebase Auth
      User? currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        await currentUser.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Current user notifier
class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final AuthService _authService;
  final LoggerService _logger;
  
  CurrentUserNotifier(this._authService, this._logger) : super(null) {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        try {
          // Get user data from Firestore
          final userData = await _authService.getUserData(firebaseUser.uid);
          state = userData;
        } catch (e) {
          _logger.error("Error loading user data: ${e.toString()}");
          state = null;
        }
      } else {
        state = null;
      }
    });
  }
  
  // Login with email and password
  Future<void> login(String email, String password) async {
    try {
      // 1. Authenticate with Firebase Auth
      final userCredential = await _authService.signInWithEmailAndPassword(email, password);
      if (userCredential.user == null) {
        throw Exception('Authentication successful but user is null');
      }
      
      final uid = userCredential.user!.uid;
      _logger.info("User authenticated successfully: $uid");
      
      // 2. Get or create Firestore user document
      UserModel? userData;
      try {
        // First, update last login (this will create a document if needed)
        await _authService.updateLastLogin(uid);
        
        // Then, get the user data
        userData = await _authService.getUserData(uid);
      } catch (e) {
        _logger.error("Error accessing Firestore: ${e.toString()}");
        
        // If we failed to get/create user data, create it now as a last resort
        if (userData == null) {
          try {
            final displayName = userCredential.user!.displayName ?? email.split('@').first;
            await _authService.createUserData(
              uid, 
              email, 
              displayName,
              UserRole.viewer // Default role
            );
            userData = await _authService.getUserData(uid);
          } catch (createError) {
            _logger.error("Failed to create user document: ${createError.toString()}");
            rethrow;
          }
        }
      }
      
      // 3. Set the user state
      state = userData;
      
    } catch (e) {
      _logger.error("Login error: ${e.toString()}");
      rethrow;
    }
  }
  
  // Create a new user
  Future<void> createUser(String email, String password, String name, UserRole role) async {
    try {
      final userCredential = await _authService.createUserWithEmailAndPassword(email, password);
      if (userCredential.user != null) {
        await _authService.createUserData(userCredential.user!.uid, email, name, role);
        final userData = await _authService.getUserData(userCredential.user!.uid);
        state = userData;
      }
    } catch (e) {
      _logger.error("User creation error: ${e.toString()}");
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = null;
    } catch (e) {
      _logger.error("Sign out error: ${e.toString()}");
      rethrow;
    }
  }
  
  // Update user's paired device
  Future<void> updatePairedDevice(String deviceId) async {
    if (state == null) return;
    try {
      await _authService.updatePairedDevice(state!.id, deviceId);
      // Update the local state
      final updatedUser = await _authService.getUserData(state!.id);
      state = updatedUser;
    } catch (e) {
      _logger.error("Update paired device error: ${e.toString()}");
      rethrow;
    }
  }
  
  // Remove paired device
  Future<void> removePairedDevice() async {
    if (state == null) return;
    try {
      await _authService.updatePairedDevice(state!.id, null);
      // Update the local state
      final updatedUser = await _authService.getUserData(state!.id);
      state = updatedUser;
    } catch (e) {
      _logger.error("Remove paired device error: ${e.toString()}");
      rethrow;
    }
  }
}

// Current user provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final logger = ref.watch(loggerProvider);
  return CurrentUserNotifier(authService, logger);
}); 