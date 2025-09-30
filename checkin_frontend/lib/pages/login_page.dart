// lib/pages/login_page.dart
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final String? errorMessage;

  const LoginPage({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prihlásenie')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Chyba: $errorMessage',
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            const Text('Použite tlačidlo "Prihlásiť sa" v hornej lište.'),
          ],
        ),
      ),
    );
  }
}
