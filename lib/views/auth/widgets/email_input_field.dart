import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class EmailInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final VoidCallback? onEditingComplete;

  const EmailInputField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onEditingComplete: onEditingComplete,
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Correo institucional',
        hintText: 'tu.correo@continental.edu.pe',
        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textHint),
                onPressed: enabled ? () => controller.clear() : null,
              )
            : null,
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
