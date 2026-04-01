import 'package:flutter/material.dart';

/// CodeInputModal — per 08_COMPONENT_SPEC.md §5.6.
///
/// Modes: Loading → requires loaderCode, Hauling → requires haulingCode
/// Behavior: alphanumeric only, submit disabled if invalid
/// Output: → enrich ACTIVITY_STARTED event
class CodeInputModal extends StatefulWidget {
  final String subtype;

  const CodeInputModal({super.key, required this.subtype});

  static Future<String?> show(BuildContext context, String subtype) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CodeInputModal(subtype: subtype),
    );
  }

  @override
  State<CodeInputModal> createState() => _CodeInputModalState();
}

class _CodeInputModalState extends State<CodeInputModal> {
  final _controller = TextEditingController();
  String? _errorText;

  bool get _isLoading => widget.subtype == 'loading';
  String get _title => _isLoading ? 'NOMOR LOADER' : 'NOMOR HAULING';
  String get _fieldLabel =>
      _isLoading ? 'Masukan Nomor Loader' : 'Masukan Nomor Hauling';

  bool _isValidCode(String value) {
    if (value.trim().isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(value.trim());
  }

  void _onChanged(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _errorText = null;
      } else if (!_isValidCode(value)) {
        _errorText = 'Hanya huruf, angka, dan tanda hubung';
      } else {
        _errorText = null;
      }
    });
  }

  void _onSubmit() {
    final value = _controller.text.trim();
    if (!_isValidCode(value)) return;
    Navigator.pop(context, value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _isValidCode(_controller.text);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, null),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: Colors.grey.shade500,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Label with required asterisk ──
              RichText(
                text: TextSpan(
                  text: _fieldLabel,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                  children: const [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── Input field ──
              TextField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: _fieldLabel,
                  errorText: _errorText,
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: Color(0xFF0F172A), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFEF4444)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: Color(0xFFEF4444), width: 1.5),
                  ),
                  hintStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  errorStyle: const TextStyle(fontSize: 13),
                ),
                onChanged: _onChanged,
                onSubmitted: (_) {
                  if (isValid) _onSubmit();
                },
              ),
              const SizedBox(height: 20),

              // ── Submit button ──
              ElevatedButton(
                onPressed: isValid ? _onSubmit : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  backgroundColor: const Color(0xFF0F172A),
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text('Masukan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
