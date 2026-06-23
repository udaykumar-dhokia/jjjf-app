import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../../../providers/complete_profile_provider.dart';
import '../../../../core/widgets/custom_text_field.dart';

class StepPassword extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const StepPassword({super.key, required this.formKey});

  @override
  State<StepPassword> createState() => _StepPasswordState();
}

class _StepPasswordState extends State<StepPassword> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  double _passwordStrength = 0.0;
  Color _strengthColor = Colors.grey;
  String _strengthText = "Too Short";

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.25) {
        _strengthColor = Colors.red;
        _strengthText = "Weak";
      } else if (strength <= 0.5) {
        _strengthColor = Colors.orange;
        _strengthText = "Fair";
      } else if (strength <= 0.75) {
        _strengthColor = Colors.yellow[700]!;
        _strengthText = "Good";
      } else {
        _strengthColor = Colors.green;
        _strengthText = "Strong";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompleteProfileProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set Your Password",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Create a strong password to secure your account.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            CustomTextField(
              initialValue: provider.password,
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
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              onChanged: (val) {
                provider.password = val;
                _checkPasswordStrength(val);
              },
              validator: (val) {
                if (val == null || val.isEmpty) return "Password is required";
                if (val.length < 8) return "Must be at least 8 characters";
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Password Strength Indicator
            if (provider.password.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Password Strength",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        _strengthText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _strengthColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: Colors.grey[300],
                    color: _strengthColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            CustomTextField(
              initialValue: provider.confirmPassword,
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              obscureText: _obscureConfirmPassword,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedLockPassword,
                color: Colors.black54,
                size: 18,
              ),
              suffixIcon: IconButton(
                icon: HugeIcon(
                  icon: _obscureConfirmPassword
                      ? HugeIcons.strokeRoundedViewOff
                      : HugeIcons.strokeRoundedView,
                  color: Colors.black54,
                  size: 18,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
              onChanged: (val) => provider.confirmPassword = val,
              validator: (val) {
                if (val == null || val.isEmpty)
                  return "Please confirm your password";
                if (val != provider.password) return "Passwords do not match";
                return null;
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
