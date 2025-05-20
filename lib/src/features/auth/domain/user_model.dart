import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  broadcaster,
  viewer,
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? pairedDeviceId;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.pairedDeviceId,
    required this.createdAt,
    required this.lastLogin,
    this.isActive = true,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle potential null timestamps by using the current time as a fallback
    final DateTime now = DateTime.now();
    DateTime createdAtDate = now;
    DateTime lastLoginDate = now;
    
    // Safely convert timestamps
    if (data['createdAt'] != null) {
      createdAtDate = (data['createdAt'] as Timestamp).toDate();
    }
    
    if (data['lastLogin'] != null) {
      lastLoginDate = (data['lastLogin'] as Timestamp).toDate();
    }
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: _roleFromString(data['role'] ?? 'viewer'),
      pairedDeviceId: data['pairedDeviceId'],
      createdAt: createdAtDate,
      lastLogin: lastLoginDate,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': _roleToString(role),
      'pairedDeviceId': pairedDeviceId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? pairedDeviceId,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      pairedDeviceId: pairedDeviceId ?? this.pairedDeviceId,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  static UserRole _roleFromString(String roleStr) {
    switch (roleStr) {
      case 'admin':
        return UserRole.admin;
      case 'broadcaster':
        return UserRole.broadcaster;
      case 'viewer':
        return UserRole.viewer;
      default:
        return UserRole.viewer;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.broadcaster:
        return 'broadcaster';
      case UserRole.viewer:
        return 'viewer';
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, role: ${_roleToString(role)})';
  }
} 