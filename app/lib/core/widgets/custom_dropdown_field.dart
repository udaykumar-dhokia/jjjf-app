import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;

  const CustomDropdownField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(fontWeight: FontWeight.w500)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
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
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
        dropdownColor: Colors.white,
      ),
    );
  }
}
