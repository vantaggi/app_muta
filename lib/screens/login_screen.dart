import 'package:flutter/material.dart';
import 'package:muta_manager/screens/main_navigator.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _skipLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Text(
                'Benvenuto in Muta Manager',
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Accedi per salvare e sincronizzare le tue mute su più dispositivi.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const Spacer(flex: 1),
              _SocialLoginButton(
                text: 'Sign in with Google',
                // A placeholder for the Google logo
                icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                backgroundColor: Colors.red,
                onPressed: () {
                  // Placeholder for Google sign-in logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google Sign-in non ancora implementato')),
                  );
                },
              ),
              const SizedBox(height: 12),
              _SocialLoginButton(
                text: 'Sign in with Apple',
                icon: const Icon(Icons.apple, color: Colors.white),
                backgroundColor: Colors.black,
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Apple Sign-in non ancora implementato')),
                  );
                },
              ),
              const SizedBox(height: 12),
              _SocialLoginButton(
                text: 'Sign in with Email',
                icon: const Icon(Icons.email, color: Colors.white),
                backgroundColor: Colors.blue,
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email Sign-in non ancora implementato')),
                  );
                },
              ),
              const Spacer(flex: 2),
              OutlinedButton(
                onPressed: () => _skipLogin(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continua come ospite',
                  style: textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String text;
  final Icon icon;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
