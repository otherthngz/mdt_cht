import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// EndShiftModal — per 08_COMPONENT_SPEC.md §5.11 ConfirmationDialog.
///
/// Use Case: End Shift ONLY
/// Output: → SHIFT_ENDED
///
/// Collects hmEnd input and shows inline confirmation.
class EndShiftModal extends StatefulWidget {
  final double hmStart;

  const EndShiftModal({super.key, required this.hmStart});

  static Future<double?> show(BuildContext context, {required double hmStart}) {
    return showDialog<double>(
      context: context,
      barrierDismissible: true,
      builder: (_) => EndShiftModal(hmStart: hmStart),
    );
  }

  @override
  State<EndShiftModal> createState() => _EndShiftModalState();
}

class _EndShiftModalState extends State<EndShiftModal> {
  final _controller = TextEditingController();
  String? _errorText;
  bool _isValid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _errorText = 'HM Akhir wajib diisi';
        _isValid = false;
        return;
      }

      final parsed = double.tryParse(value.trim());
      if (parsed == null) {
        _errorText = 'HM Akhir harus berupa angka';
        _isValid = false;
        return;
      }

      if (parsed < widget.hmStart) {
        _errorText =
            'HM Akhir harus ≥ HM Awal (${widget.hmStart.toStringAsFixed(1)})';
        _isValid = false;
        return;
      }

      _errorText = null;
      _isValid = true;
    });
  }

  void _onSubmit() {
    if (!_isValid) return;
    final value = double.parse(_controller.text.trim());
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          // ── Header ──
          Row(
            children: [
              const Icon(Icons.stop_circle_outlined,
                  color: Color(0xFFC62828), size: 28),
              const SizedBox(width: 12),
              Text(
                'Akhiri Shift',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF212121),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── HM Input ──
          Text(
            'HM Akhir',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: const Color(0xFF424242),
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
            ],
            onChanged: _validate,
            decoration: InputDecoration(
              hintText: 'Masukkan HM Akhir',
              errorText: _errorText,
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF1565C0), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFC62828), width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFC62828), width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintStyle: const TextStyle(fontSize: 16),
              errorStyle: const TextStyle(fontSize: 14),
            ),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // ── Confirmation message ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFFFCC02).withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFE65100), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Apakah Anda yakin ingin mengakhiri shift? '
                    'Data tidak dapat diubah setelah shift berakhir.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFE65100),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Action buttons ──
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    side: BorderSide(color: Colors.grey.shade400),
                    foregroundColor: const Color(0xFF424242),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isValid ? _onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    backgroundColor: const Color(0xFFC62828),
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Akhiri Shift'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}
