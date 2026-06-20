import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final int maxLines;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null 
            ? Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: UnconstrainedBox(child: prefixIcon),
              ) 
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0, 
          minHeight: 0,
        ),
        suffixIcon: suffixIcon != null 
            ? Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: UnconstrainedBox(child: suffixIcon),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
      ),
    );
  }
}
