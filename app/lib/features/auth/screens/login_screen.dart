import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../main/screens/main_screen.dart';
import 'register_screen.dart';
import 'otp_verification_screen.dart';
import '../../profile/screens/complete_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _otpEmailController = TextEditingController();
  final _passwordEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _otpFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isPasswordLogin = true;

  @override
  void dispose() {
    _otpEmailController.dispose();
    _passwordEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    FocusScope.of(context).unfocus();

    final email = _otpEmailController.text.trim();
    await authProvider.sendOtp(email);

    if (authProvider.error == null) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(email: email),
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handlePasswordLogin() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    FocusScope.of(context).unfocus();

    final email = _passwordEmailController.text.trim();
    final password = _passwordController.text;

    final success = await authProvider.loginWithPassword(email, password);

    if (success) {
      if (mounted) {
        if (!authProvider.isProfileComplete) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPasswordForm(AuthProvider authProvider) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _passwordEmailController,
            labelText: 'Email Address',
            hintText: 'Enter your email',
            prefixIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedMail01,
              color: Colors.black54,
              size: 18,
            ),
            keyboardType: TextInputType.emailAddress,
            readOnly: authProvider.isLoading,
            validator: (val) {
              if (val == null || val.isEmpty) return "Required";
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Enter your password',
            obscureText: _obscurePassword,
            prefixIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedLockPassword,
              color: Colors.black54,
              size: 18,
            ),
            suffixIcon: IconButton(
              icon: HugeIcon(
                icon: _obscurePassword
                    ? HugeIcons.strokeRoundedViewOff
                    : HugeIcons.strokeRoundedView,
                color: Colors.black54,
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            readOnly: authProvider.isLoading,
            validator: (val) {
              if (val == null || val.isEmpty) return "Required";
              return null;
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handlePasswordLogin,
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Login', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isPasswordLogin = false;
                });
              },
              child: const Text(
                'Login with OTP instead?',
                style: TextStyle(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm(AuthProvider authProvider) {
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _otpEmailController,
            labelText: 'Email Address',
            hintText: 'Enter your email',
            prefixIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedMail01,
              color: Colors.black54,
              size: 18,
            ),
            keyboardType: TextInputType.emailAddress,
            readOnly: authProvider.isLoading,
            validator: (val) {
              if (val == null || val.isEmpty) return "Required";
              return null;
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleSendOtp,
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Send OTP', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isPasswordLogin = true;
                });
              },
              child: const Text(
                'Login with Password instead?',
                style: TextStyle(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Welcome\nBack",
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.black87,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Log in to connect with the thriving Jain community.",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Center(
                        child: Image.asset(
                          'assets/images/login.png',
                          height: 160,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 160,
                              width: 160,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedLock,
                                  size: 60,
                                  color: Colors.black12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 40),

                      if (_isPasswordLogin)
                        _buildPasswordForm(authProvider)
                      else
                        _buildOtpForm(authProvider),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
