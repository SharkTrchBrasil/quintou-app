import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DsTextField extends StatelessWidget {
  const DsTextField({
    super.key,
    this.title,
    this.hint,
    this.onChanged,
    this.enabled = true,
    this.formatters,
    this.keyboardType,
    this.validator,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
  });

  final String? initialValue;
  final String? title;
  final String? hint;
  final void Function(String)? onChanged;
  final bool enabled;
  final List<dynamic>? formatters; // using dynamic to avoid importing input formatters here if not needed directly
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          readOnly: !enabled,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A1A1A),
          ),
          keyboardType: keyboardType,
          inputFormatters: formatters as List<TextInputFormatter>?,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
