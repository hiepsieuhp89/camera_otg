import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/device/data/device_service.dart';
import 'package:lavie/src/features/auth/domain/user_model.dart';
import 'package:lavie/src/routes/routes.dart';
import 'package:lavie/src/theme/app_theme.dart';

@RoutePage()
class DevicePairingScreen extends ConsumerStatefulWidget {
  const DevicePairingScreen({super.key});

  @override
  ConsumerState<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends ConsumerState<DevicePairingScreen> {
  final _deviceIdController = TextEditingController();
  final _deviceNameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<DeviceModel> _availableDevices = [];
  
  @override
  void initState() {
    super.initState();
    _loadAvailableDevices();
  }
  
  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAvailableDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final deviceService = ref.read(deviceServiceProvider);
      final currentUser = ref.read(currentUserProvider);
      
      if (currentUser == null) {
        throw Exception('Chưa đăng nhập');
      }
      
      // For broadcasters, show all available devices
      // For viewers, show only active broadcaster devices
      if (ref.read(authServiceProvider).isBroadcaster(currentUser)) {
        _availableDevices = await deviceService.getAvailableDevices();
      } else if (ref.read(authServiceProvider).isViewer(currentUser)) {
        _availableDevices = await deviceService.getActiveBroadcasterDevices();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải danh sách thiết bị: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _pairWithDevice(DeviceModel device) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('Chưa đăng nhập');
      }
      
      // Update user's paired device
      await ref.read(currentUserProvider.notifier).updatePairedDevice(device.id);
      
      // Navigate to the appropriate screen based on user role
      if (mounted) {
        final updatedUser = ref.read(currentUserProvider);
        if (updatedUser != null) {
          if (ref.read(authServiceProvider).isBroadcaster(updatedUser)) {
            context.router.replaceNamed(Routes.broadcastRoute);
          } else if (ref.read(authServiceProvider).isViewer(updatedUser)) {
            context.router.replaceNamed(Routes.viewerRoute);
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi ghép nối thiết bị: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _registerNewDevice() async {
    if (_deviceIdController.text.isEmpty || _deviceNameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập ID và tên thiết bị';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final deviceService = ref.read(deviceServiceProvider);
      final currentUser = ref.read(currentUserProvider);
      
      if (currentUser == null) {
        throw Exception('Chưa đăng nhập');
      }
      
      // Register the new device
      final device = await deviceService.registerDevice(
        _deviceIdController.text.trim(),
        _deviceNameController.text.trim(),
        currentUser.id,
      );
      
      // Update user's paired device
      await ref.read(currentUserProvider.notifier).updatePairedDevice(device.id);
      
      // Navigate to the broadcaster screen
      if (mounted) {
        context.router.replaceNamed(Routes.broadcastRoute);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi đăng ký thiết bị: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Widget _buildDeviceList() {
    if (_availableDevices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Không có thiết bị khả dụng. Đăng ký thiết bị mới hoặc thử lại sau.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _availableDevices.length,
      itemBuilder: (context, index) {
        final device = _availableDevices[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(device.name),
            subtitle: Text('ID: ${device.id}'),
            trailing: ElevatedButton(
              onPressed: _isLoading ? null : () => _pairWithDevice(device),
              child: const Text('Kết nối'),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildNewDeviceForm() {
    final currentUser = ref.watch(currentUserProvider);
    
    // Only broadcasters can register new devices
    if (currentUser == null || !ref.read(authServiceProvider).isBroadcaster(currentUser)) {
      return const SizedBox.shrink();
    }
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Đăng ký thiết bị mới',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deviceIdController,
              decoration: const InputDecoration(
                labelText: 'ID thiết bị',
                hintText: 'Nhập định danh thiết bị',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deviceNameController,
              decoration: const InputDecoration(
                labelText: 'Tên thiết bị',
                hintText: 'Nhập tên cho thiết bị của bạn',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _registerNewDevice,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Đăng ký & Kết nối'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghép nối thiết bị'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAvailableDevices,
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('Vui lòng đăng nhập trước'))
          : RefreshIndicator(
              onRefresh: _loadAvailableDevices,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User info
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xin chào, ${currentUser.name}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bạn đang đăng nhập với vai trò ${_getRoleText(currentUser.role)}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            if (currentUser.pairedDeviceId != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.link, color: AppTheme.primaryColor),
                                  const SizedBox(width: 8),
                                  const Text('Đang kết nối với thiết bị: '),
                                  Text(
                                    currentUser.pairedDeviceId!,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ref.read(currentUserProvider.notifier).removePairedDevice();
                                },
                                icon: const Icon(Icons.link_off),
                                label: const Text('Ngắt kết nối'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Available devices section
                    const Text(
                      'Thiết bị khả dụng',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    if (_isLoading && _availableDevices.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildDeviceList(),
                    
                    // New device form
                    const SizedBox(height: 24),
                    _buildNewDeviceForm(),
                    
                    // Sign out button
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(currentUserProvider.notifier).signOut();
                        if (mounted) {
                          context.router.replaceNamed(Routes.loginRoute);
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Quản trị viên';
      case UserRole.broadcaster:
        return 'Người phát sóng';
      case UserRole.viewer:
        return 'Người xem';
    }
  }
} 