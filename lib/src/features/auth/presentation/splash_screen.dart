import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/routes/app_router.dart';
import 'package:lavie/src/theme/app_theme.dart';

@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      final currentUser = ref.read(currentUserProvider);
      print('DEBUG: currentUser = $currentUser');
      if (currentUser != null) {
        final authService = ref.read(authServiceProvider);
        print('DEBUG: user roles: admin=${authService.isAdmin(currentUser)}, broadcaster=${authService.isBroadcaster(currentUser)}, viewer=${authService.isViewer(currentUser)}');
        if (authService.isAdmin(currentUser)) {
          context.router.replace(const AdminDashboardRoute());
        } else if (authService.isBroadcaster(currentUser)) {
          context.router.replace(const BroadcastRoute());
        } else if (authService.isViewer(currentUser)) {
          context.router.replace(const ViewerRoute());
        } else {
          context.router.replace(const LoginRoute());
        }
      } else {
        print('DEBUG: No user, go to login');
        context.router.replace(const LoginRoute());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'LAVIE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // App name
            const Text(
              'Lavie',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Tagline
            const Text(
              'Connect. Share. Experience.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
