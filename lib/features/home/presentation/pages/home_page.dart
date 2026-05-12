import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_session_controller.dart';
import '../../../auth/presentation/pages/auth_access_page.dart';
import '../../../app_shell/presentation/pages/app_shell_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(authSessionControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authSessionControllerProvider);

    if (authState.isRestoring) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 18),
              Text(
                'Restaurando acceso del Sistema...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!authState.isAuthenticated) {
      return const AuthAccessPage();
    }

    return const AppShellPage();
  }
}
