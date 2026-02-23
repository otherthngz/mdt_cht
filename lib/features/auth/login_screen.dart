import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _maxLength = 8;
  final TextEditingController _inputController = TextEditingController();
  String _input = '';
  bool _submitting = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _append(String value) {
    if (_input.length >= _maxLength) {
      return;
    }
    setState(() {
      _input = '$_input$value';
      _inputController.value = TextEditingValue(
        text: _input,
        selection: TextSelection.collapsed(offset: _input.length),
      );
    });
  }

  void _backspace() {
    if (_input.isEmpty) {
      return;
    }
    setState(() {
      _input = _input.substring(0, _input.length - 1);
      _inputController.value = TextEditingValue(
        text: _input,
        selection: TextSelection.collapsed(offset: _input.length),
      );
    });
  }

  Future<void> _submit() async {
    if (_input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID wajib diisi.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final service = ref.read(mdtServiceProvider);
      await service.recordLogin(operatorId: _input);
      ref.read(sessionProvider.notifier).setOperator(_input);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.hmMulai);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _keyButton({required String label, VoidCallback? onTap}) {
    return SizedBox(
      width: 64,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  readOnly: true,
                  enableInteractiveSelection: false,
                  controller: _inputController,
                  decoration: InputDecoration(
                    labelText: 'Masukan ID Anda',
                    hintText: 'Masukan ID Anda',
                    suffixText: '${_input.length}/$_maxLength',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final value in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
                      _keyButton(label: value, onTap: () => _append(value)),
                    _keyButton(
                      label: 'C',
                      onTap: () => setState(() {
                        _input = '';
                        _inputController.clear();
                      }),
                    ),
                    _keyButton(label: '0', onTap: () => _append('0')),
                    _keyButton(label: '⌫', onTap: _backspace),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Text(_submitting ? 'Masuk...' : 'Masuk'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
