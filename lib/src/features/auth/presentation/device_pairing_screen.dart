import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/core/utils/device_pairing_service.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/auth/domain/user_model.dart';
import 'package:lavie/src/routes/app_router.dart';
import 'package:lavie/src/theme/app_theme.dart';

@RoutePage()
class DevicePairingScreen extends ConsumerStatefulWidget {
  const DevicePairingScreen({super.key});

  @override
  ConsumerState<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends ConsumerState<DevicePairingScreen> {
  List<Map<String, dynamic>> _availableUsers = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
  }

  Future<void> _loadAvailableUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Determine which role to search for
      final targetRole = ref.read(authServiceProvider).isBroadcaster(currentUser)
          ? UserRole.viewer
          : UserRole.broadcaster;

      final pairingService = ref.read(devicePairingServiceProvider);
      final users = await pairingService.findAvailableUsers(targetRole);

      setState(() {
        _availableUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load available users: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _pairWithUser() async {
    if (_selectedUserId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final pairingService = ref.read(devicePairingServiceProvider);
      
      // Determine the broadcaster and viewer IDs
      String broadcasterId, viewerId;
      if (ref.read(authServiceProvider).isBroadcaster(currentUser)) {
        broadcasterId = currentUser.id;
        viewerId = _selectedUserId!;
      } else {
        broadcasterId = _selectedUserId!;
        viewerId = currentUser.id;
      }

      await pairingService.pairDevices(broadcasterId, viewerId);
      
      // Update the current user state
      await ref.read(currentUserProvider.notifier).pairWithDevice(_selectedUserId!);

      if (mounted) {
        // Navigate to the appropriate screen based on user role
        if (ref.read(authServiceProvider).isBroadcaster(currentUser)) {
          context.router.replace(const BroadcastRoute());
        } else {
          context.router.replace(const ViewerRoute());
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pair with user: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userRole = currentUser != null
        ? ref.read(authServiceProvider).isBroadcaster(currentUser)
            ? 'Broadcaster'
            : 'Viewer'
        : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Pairing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Connect Your $userRole Device',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a ${userRole == 'Broadcaster' ? 'viewer' : 'broadcaster'} to pair with',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Loading indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_availableUsers.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No available ${userRole == 'Broadcaster' ? 'viewers' : 'broadcasters'} found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadAvailableUsers,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Users',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _availableUsers.length,
                        itemBuilder: (context, index) {
                          final user = _availableUsers[index];
                          final isSelected = _selectedUserId == user['id'];

                          return Card(
                            elevation: isSelected ? 4 : 1,
                            margin: const EdgeInsets.only(bottom: 12),
                            color: isSelected
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedUserId = user['id'];
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.grey.shade200,
                                      child: Icon(
                                        userRole == 'Broadcaster'
                                            ? Icons.visibility
                                            : Icons.videocam,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user['displayName'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            user['email'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Radio<String>(
                                      value: user['id'],
                                      groupValue: _selectedUserId,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedUserId = value;
                                        });
                                      },
                                      activeColor: AppTheme.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Pair button
            if (!_isLoading && _availableUsers.isNotEmpty) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedUserId != null ? _pairWithUser : null,
                  icon: const Icon(Icons.link),
                  label: const Text('PAIR DEVICE'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
