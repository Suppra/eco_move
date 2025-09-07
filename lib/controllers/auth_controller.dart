import 'package:flutter/material.dart';
import '../providers/user_provider.dart';

class AuthController {
  final UserProvider userProvider;

  AuthController(this.userProvider);

  // Manejar inicio de sesión
  Future<void> handleSignIn(
    BuildContext context,
    String email,
    String password,
  ) async {
    final success = await userProvider.signIn(email, password);
    
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showError(context, userProvider.error ?? 'Error al iniciar sesión');
    }
  }

  // Manejar registro
  Future<void> handleSignUp(
    BuildContext context,
    String email,
    String password,
    String name,
    String document,
  ) async {
    final success = await userProvider.signUp(email, password, name, document);
    
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showError(context, userProvider.error ?? 'Error al crear cuenta');
    }
  }

  // Manejar cierre de sesión
  Future<void> handleSignOut(BuildContext context) async {
    await userProvider.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
