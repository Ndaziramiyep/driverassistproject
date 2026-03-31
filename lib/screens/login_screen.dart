import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/biometric_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      final error = auth.error ?? 'Failed to sign in';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _loginWithBiometric() async {
    final biometric = context.read<BiometricProvider>();
    final auth = context.read<AuthProvider>();

    final authenticated = await biometric.authenticate();
    if (!authenticated) return;

    final credentials = await biometric.getBiometricCredentials();
    final email = credentials['email'];
    final password = credentials['password'];
    if (email == null || password == null) return;

    final ok = await auth.signIn(email, password);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final biometric = context.watch<BiometricProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Color(0xFF1E88E5),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to continue with DriverAssist',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Sign In',
                    isLoading: auth.isLoading,
                    onPressed: _login,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Sign In With Google',
                    type: ButtonType.secondary,
                    icon: Icons.g_mobiledata,
                    onPressed: () async {
                      final ok =
                          await context.read<AuthProvider>().signInWithGoogle();
                      if (!mounted) return;
                      if (ok) {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (biometric.isBiometricEnabled &&
                    biometric.isBiometricAvailable)
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: 'Sign In With Biometrics',
                      type: ButtonType.text,
                      icon: Icons.fingerprint,
                      onPressed: _loginWithBiometric,
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.register),
                  child: const Text('No account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
