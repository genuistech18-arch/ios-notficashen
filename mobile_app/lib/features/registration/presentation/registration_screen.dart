import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exceptions.dart';
import '../../home/presentation/home_screen.dart';
import '../controller/registration_controller.dart';
import 'widgets/code_input_field.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  /// Pre-fills the code field and auto-submits, used by the deep-link flow
  /// (`myapp://open?code=1234`). On success the manual entry UI is skipped
  /// entirely; on failure it falls back to showing this screen with the
  /// code pre-filled and the error visible, rather than a dead end.
  final String? initialCode;
  final bool autoSubmit;

  const RegistrationScreen({
    super.key,
    this.initialCode,
    this.autoSubmit = false,
  });

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode ?? '');

    if (widget.autoSubmit && widget.initialCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _submit());
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref
        .read(registrationControllerProvider.notifier)
        .submit(_codeController.text.trim());

    if (success && mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  String _errorMessage(Object error) {
    if (error is CodeNotFoundException) {
      return 'Code not found, please check and try again';
    }
    if (error is NetworkException) {
      return 'Something went wrong, please retry';
    }
    return 'Something went wrong, please retry';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('متابعة الطالب - إدخال الكود')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CodeInputField(
                controller: _codeController,
                enabled: !state.isLoading,
              ),
              const SizedBox(height: 16),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage(state.error!),
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              FilledButton(
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('متابعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
