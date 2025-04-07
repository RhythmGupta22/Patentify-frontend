import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      backgroundColor: Color.fromRGBO(33, 33, 33, 1), // Deep black background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Banner (optional, mimic Cloudflare style)
              const SizedBox(height: 40),
              // Logo/Title
              const Text(
                'Sign in to Patentify',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 30),
              // Social Login Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 400),
                child: _SignInButton(
                  icon: FontAwesomeIcons.google,
                  label: 'Continue with Google',
                  color: Color.fromRGBO(66, 66, 66, 1),
                  iconColor: Colors.white, // Google red
                  onPressed: () => authController.signInWithGoogle(),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 400),
                child: _SignInButton(
                  icon: FontAwesomeIcons.apple,
                  label: 'Continue with Apple',
                  color: Color.fromRGBO(66, 66, 66, 1),
                  iconColor: Colors.white, // Apple white
                  onPressed: () => authController.signInWithApple(),
                ),
              ),
              SizedBox(height: 16,),
              const Text(
                'By continuing, you agree to Pantentify\'s Terms of Service and Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;

  const _SignInButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: FaIcon(icon, color: iconColor),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      onPressed: onPressed,
    );
  }
}