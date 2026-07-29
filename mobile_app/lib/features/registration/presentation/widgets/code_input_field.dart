import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';

class CodeInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const CodeInputField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      autofillHints: const [AutofillHints.oneTimeCode],
      decoration: const InputDecoration(
        labelText: 'Code',
        border: OutlineInputBorder(),
      ),
      validator: validateCode,
    );
  }
}
