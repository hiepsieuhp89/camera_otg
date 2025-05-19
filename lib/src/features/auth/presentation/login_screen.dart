import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/auth/domain/user_model.dart';
import 'package:lavie/src/routes/app_router.dart';
import 'package:lavie/src/theme/app_theme.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // Fill sẵn user: tungcan2000@gmail.com/123123123
  final _emailController = TextEditingController(text: 'tungcan2000@gmail.com');
  final _passwordController = TextEditingController(text: '123123123');
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isRegisterMode = false;
  UserRole _selectedRole = UserRole.viewer;
  
  // Added for email selection
  String _selectedEmail = 'tungcan2000@gmail.com'; // Default selected email
  final List<String> _availableEmails = ['tungcan2000@gmail.com', 'tungcan2001@gmail.com'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Step 1: Attempting login...');
      await ref.read(currentUserProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      print('Step 2: Login successful, checking mounted...');
      if (mounted) {
        final currentUser = ref.read(currentUserProvider);
        print('Step 3: Current user: $currentUser');
        if (currentUser != null) {
          if (ref.read(authServiceProvider).isAdmin(currentUser)) {
            print('Step 4: User is admin, navigating to AdminDashboardRoute');
            context.router.replace(const AdminDashboardRoute());
          } else {
            // For non-admin users, check if they are already paired
            print('Step 5: User is not admin, checking pairedDeviceId...');
            if (currentUser.pairedDeviceId != null) {
              print('Step 6: User is paired, checking role...');
              if (ref.read(authServiceProvider).isBroadcaster(currentUser)) {
                print('Step 7: User is broadcaster, navigating to BroadcastRoute');
                context.router.replace(const BroadcastRoute());
              } else if (ref.read(authServiceProvider).isViewer(currentUser)) {
                print('Step 8: User is viewer, navigating to ViewerRoute');
                context.router.replace(const ViewerRoute());
              } else {
                print('Step 9: User is paired but role is unknown');
              }
            } else {
              print('Step 10: User is not paired, navigating to DevicePairingRoute');
              context.router.replace(const DevicePairingRoute());
            }
          }
        } else {
          print('Step 11: currentUser is null after login');
        }
      } else {
        print('Step 12: Widget is not mounted');
      }
    } catch (e, stack) {
      print('LOGIN ERROR: $e');
      print('STACKTRACE: $stack');
      setState(() {
        _errorMessage = 'Invalid email or password. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      print('Step 1: Attempting registration...');
      await ref.read(currentUserProvider.notifier).createUser(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        _selectedRole,
      );
      
      print('Step 2: Registration successful, logging in...');
      await ref.read(currentUserProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (mounted) {
        final currentUser = ref.read(currentUserProvider);
        print('Step 3: Current user after registration: $currentUser');
        
        if (currentUser != null) {
          // New users always need to pair first
          print('Step 4: New user, navigating to DevicePairingRoute');
          context.router.replace(const DevicePairingRoute());
        } else {
          print('Step 5: currentUser is null after registration');
          _errorMessage = 'Registration successful but failed to log in. Please log in manually.';
          setState(() {
            _isRegisterMode = false;
          });
        }
      }
    } catch (e, stack) {
      print('REGISTRATION ERROR: $e');
      print('STACKTRACE: $stack');
      setState(() {
        _errorMessage = 'Failed to register: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'LAVIE',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Title
                  Text(
                    _isRegisterMode ? 'Create Account' : 'Welcome Back',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegisterMode ? 'Sign up to get started' : 'Sign in to continue',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
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
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Name field (only in register mode)
                  if (_isRegisterMode) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Email selection radio buttons
                  if (!_isRegisterMode) ...[ // Only show in login mode
                    const Text(
                      'Select email:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _availableEmails.map((email) => RadioListTile<String>(
                        title: Text(email),
                        value: email,
                        groupValue: _selectedEmail,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedEmail = value ?? _availableEmails.first;
                            _emailController.text = _selectedEmail; // Update text field
                          });
                        },
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (_isRegisterMode && value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Role selection (only in register mode)
                  if (_isRegisterMode) ...[
                    const Text(
                      'Select your role:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<UserRole>(
                            title: const Text('Viewer'),
                            subtitle: const Text('Can view camera feed'),
                            value: UserRole.viewer,
                            groupValue: _selectedRole,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (UserRole? value) {
                              setState(() {
                                _selectedRole = value ?? UserRole.viewer;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<UserRole>(
                            title: const Text('Broadcaster'),
                            subtitle: const Text('Can broadcast camera'),
                            value: UserRole.broadcaster,
                            groupValue: _selectedRole,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (UserRole? value) {
                              setState(() {
                                _selectedRole = value ?? UserRole.broadcaster;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Note about device requirements
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedRole == UserRole.broadcaster
                                ? 'Broadcaster Requirements:'
                                : 'Viewer Information:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedRole == UserRole.broadcaster
                                ? '• Connect a USB camera via OTG adapter\n• Camera will be used for broadcasting\n• Your device will vibrate when a viewer sends a notification'
                                : '• Will receive video from broadcaster\n• Can send vibration notifications to broadcaster\n• Does not require a camera connection',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Login/Register button
                  ElevatedButton(
                    onPressed: _isLoading ? null : (_isRegisterMode ? _register : _login),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isRegisterMode ? 'SIGN UP' : 'SIGN IN',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Toggle between login and register
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegisterMode = !_isRegisterMode;
                        _errorMessage = null;
                        // Reset selected email to default when switching modes
                        _selectedEmail = _availableEmails.first;
                        _emailController.text = _selectedEmail;
                      });
                    },
                    child: Text(
                      _isRegisterMode
                          ? 'Already have an account? Sign In'
                          : 'Don\'t have an account? Sign Up',
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // App version
                  const Text(
                    'Lavie v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Add UVC Camera Test Button
                  OutlinedButton.icon(
                    onPressed: () {
                      context.router.push(const UVCCameraRoute());
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Test UVC Camera'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
