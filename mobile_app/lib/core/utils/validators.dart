String? validateCode(String? value) {
  final code = value?.trim() ?? '';
  if (code.isEmpty) return 'Please enter your code';
  if (code.length < 4) return 'Code must be at least 4 characters';
  return null;
}
