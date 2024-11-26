import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class ProviderAuthService {
  static void checkTokenExpiration({required BuildContext context}) {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.isTokenExpired()) {
      _showSessionExpiredDialog(context: context);
    }
  }

  static void _showSessionExpiredDialog({required BuildContext context}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sesión expirada'),
          content: const Text(
              'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        );
      },
    );
  }
}
