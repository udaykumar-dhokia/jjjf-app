import 'package:flutter/material.dart';

class CustomDatePickerField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;

  const CustomDatePickerField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.selectedDate,
    required this.onDateSelected,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Format date as DD/MM/YYYY
    final displayDate = selectedDate != null 
        ? "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}"
        : "";

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(text: displayDate),
        validator: validator,
        onTap: () async {
          // Unfocus any currently focused field
          FocusScope.of(context).unfocus();
          
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)), // Default ~18 years ago
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF5E35B1), // Primary Purple
                    onPrimary: Colors.white,
                    onSurface: Colors.black87,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onDateSelected(picked);
          }
        },
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
          suffixIcon: const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: UnconstrainedBox(
              child: Icon(Icons.calendar_today, color: Colors.black54, size: 18),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
      ),
    );
  }
}
