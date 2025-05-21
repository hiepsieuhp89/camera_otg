import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/auth/domain/user_model.dart';
import 'package:lavie/src/features/webrtc/data/webrtc_connection_service.dart';
import 'package:lavie/src/routes/routes.dart';
import 'package:lavie/src/theme/app_theme.dart';

@RoutePage()
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  List<UserModel> _users = [];
  List<Map<String, dynamic>> _activeStreams = [];
  bool _isLoading = false;
  String? _errorMessage;
  WebRTCConnectionService? _webRTCService;
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _initWebRTC();
  }
  
  @override
  void dispose() {
    _webRTCService?.dispose();
    super.dispose();
  }
  
  Future<void> _initWebRTC() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _webRTCService = ref.read(webRTCConnectionServiceProvider(
        WebRTCConnectionParams(
          userId: user.id,
          isBroadcaster: false,
        ),
      ));
      
      _webRTCService!.onAvailableStreamsChanged = (streams) {
        setState(() {
          _activeStreams = streams;
        });
      };
      
      await _refreshActiveStreams();
      
      // Start listening for active streams
      _webRTCService!.listenForActiveStreams();
    }
  }
  
  Future<void> _refreshActiveStreams() async {
    if (_webRTCService != null) {
      final streams = await _webRTCService!.getActiveStreams();
      setState(() {
        _activeStreams = streams;
      });
    }
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = ref.read(authServiceProvider);
      
      final users = await authService.getAllUsers();
      
      setState(() {
        _users = users;
      });
      
      await _refreshActiveStreams();
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Active Streams'),
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
                      children: [
                        _buildUsersTab(),
                        _buildActiveStreamsTab(),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateUserDialog,
          child: const Icon(Icons.person_add),
        ),
      ),
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
  
  Widget _buildActiveStreamsTab() {
    if (_activeStreams.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No active streams',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _activeStreams.length,
      itemBuilder: (context, index) {
        final stream = _activeStreams[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(
              Icons.videocam,
              color: Colors.white,
            ),
          ),
          title: Text(stream['broadcasterName'] ?? 'Unknown broadcaster'),
          subtitle: Text('ID: ${stream['broadcasterId']}'),
          trailing: const Icon(Icons.circle, color: Colors.green, size: 12),
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
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter user name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter email address',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    const Text('Role:'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _createRoleChip(UserRole.viewer, selectedRole, (role) {
                          setState(() {
                            selectedRole = role;
                          });
                        }),
                        _createRoleChip(UserRole.broadcaster, selectedRole, (role) {
                          setState(() {
                            selectedRole = role;
                          });
                        }),
                        _createRoleChip(UserRole.admin, selectedRole, (role) {
                          setState(() {
                            selectedRole = role;
                          });
                        }),
                      ],
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
                      nameController.text,
                      emailController.text,
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
  
  Widget _createRoleChip(UserRole role, UserRole selectedRole, Function(UserRole) onSelected) {
    return ChoiceChip(
      label: Text(_getRoleText(role)),
      selected: role == selectedRole,
      onSelected: (selected) {
        if (selected) {
          onSelected(role);
        }
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
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.createUserWithEmailAndPassword(email, password);
      await authService.createUserData(userCredential.user!.uid, email, name, role);
      
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
    }
  }
} 