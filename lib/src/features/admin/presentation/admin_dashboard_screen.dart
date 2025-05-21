import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/auth/domain/user_model.dart';
import 'package:lavie/src/features/device/data/device_service.dart';
import 'package:lavie/src/routes/routes.dart';
import 'package:lavie/src/theme/app_theme.dart';

@RoutePage()
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserModel> _users = [];
  List<DeviceModel> _devices = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = ref.read(authServiceProvider);
      final deviceService = ref.read(deviceServiceProvider);
      
      final users = await authService.getAllUsers();
      final devices = await deviceService.getAvailableDevices();
      
      setState(() {
        _users = users;
        _devices = devices;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _deleteUser(UserModel user) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await ref.read(authServiceProvider).deleteUser(user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete user: ${e.toString()}';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _updateUserRole(UserModel user, UserRole newRole) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await ref.read(authServiceProvider).updateUser(user.id, {
        'role': newRole.toString().split('.').last,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User role updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update user role: ${e.toString()}';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user role: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${user.email}'),
              const SizedBox(height: 8),
              Text('Role: ${_getRoleText(user.role)}'),
              const SizedBox(height: 8),
              Text('ID: ${user.id}'),
              const SizedBox(height: 8),
              Text('Created: ${_formatDateTime(user.createdAt)}'),
              const SizedBox(height: 8),
              Text('Last Login: ${_formatDateTime(user.lastLogin)}'),
              const SizedBox(height: 8),
              Text('Paired Device: ${user.pairedDeviceId ?? 'None'}'),
              const SizedBox(height: 16),
              const Text('Change Role:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _roleButton(user, UserRole.viewer),
                  _roleButton(user, UserRole.broadcaster),
                  _roleButton(user, UserRole.admin),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(user);
              },
              child: const Text('Delete User', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  
  Widget _roleButton(UserModel user, UserRole role) {
    final bool isCurrentRole = user.role == role;
    return ElevatedButton(
      onPressed: isCurrentRole ? null : () {
        Navigator.of(context).pop();
        _updateUserRole(user, role);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrentRole ? Colors.grey : AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Text(_getRoleText(role)),
    );
  }

  void _showDeviceDetails(DeviceModel device) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(device.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${device.id}'),
              const SizedBox(height: 8),
              Text('Owner ID: ${device.ownerId}'),
              const SizedBox(height: 8),
              Text('Active: ${device.isActive ? 'Yes' : 'No'}'),
              const SizedBox(height: 8),
              Text('Broadcasting: ${device.isBroadcasting ? 'Yes' : 'No'}'),
              const SizedBox(height: 8),
              Text('Last Seen: ${_formatDateTime(device.lastSeen)}'),
              const SizedBox(height: 8),
              Text('Viewer ID: ${device.viewerId ?? 'None'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  
  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.broadcaster:
        return 'Broadcaster';
      case UserRole.viewer:
        return 'Viewer';
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Devices'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.shade100,
                    width: double.infinity,
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUsersTab(),
                      _buildDevicesTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _tabController.index == 0 
          ? FloatingActionButton(
              onPressed: _showCreateUserDialog,
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }
  
  Widget _buildUsersTab() {
    if (_users.isEmpty) {
      return const Center(
        child: Text('No users found'),
      );
    }
    
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getRoleColor(user.role),
            child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
          ),
          title: Text(user.name),
          subtitle: Text('${user.email} • ${_getRoleText(user.role)}'),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showUserDetails(user),
          ),
          onTap: () => _showUserDetails(user),
        );
      },
    );
  }
  
  Widget _buildDevicesTab() {
    if (_devices.isEmpty) {
      return const Center(
        child: Text('No devices found'),
      );
    }
    
    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: device.isBroadcasting ? Colors.green : Colors.grey,
            child: Icon(
              device.isBroadcasting ? Icons.videocam : Icons.videocam_off,
              color: Colors.white,
            ),
          ),
          title: Text(device.name),
          subtitle: Text(
            device.isBroadcasting
                ? 'Broadcasting • Last seen: ${_formatDateTime(device.lastSeen)}'
                : 'Offline • Last seen: ${_formatDateTime(device.lastSeen)}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDeviceDetails(device),
          ),
          onTap: () => _showDeviceDetails(device),
        );
      },
    );
  }
  
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.broadcaster:
        return Colors.blue;
      case UserRole.viewer:
        return Colors.green;
    }
  }
  
  Future<void> _logout() async {
    try {
      await ref.read(authServiceProvider).signOut();
      if (mounted) {
        context.router.pushNamed('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCreateUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole selectedRole = UserRole.viewer;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select role:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    RadioListTile<UserRole>(
                      title: const Text('Viewer'),
                      value: UserRole.viewer,
                      groupValue: selectedRole,
                      onChanged: (UserRole? value) {
                        setState(() {
                          selectedRole = value ?? UserRole.viewer;
                        });
                      },
                    ),
                    RadioListTile<UserRole>(
                      title: const Text('Broadcaster'),
                      value: UserRole.broadcaster,
                      groupValue: selectedRole,
                      onChanged: (UserRole? value) {
                        setState(() {
                          selectedRole = value ?? UserRole.broadcaster;
                        });
                      },
                    ),
                    RadioListTile<UserRole>(
                      title: const Text('Admin'),
                      value: UserRole.admin,
                      groupValue: selectedRole,
                      onChanged: (UserRole? value) {
                        setState(() {
                          selectedRole = value ?? UserRole.admin;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _createUser(
                      nameController.text.trim(),
                      emailController.text.trim(),
                      passwordController.text,
                      selectedRole,
                    );
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<void> _createUser(String name, String email, String password, UserRole role) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await ref.read(currentUserProvider.notifier).createUser(
        email,
        password,
        name,
        role,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create user: ${e.toString()}';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create user: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 