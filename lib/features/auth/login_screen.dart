import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';
import '../../core/network/operator_lookup.dart';

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
  String? _validationError;

  // ── Operator lookup state ──
  Operator? _operator;
  bool _isLookingUp = false;
  String? _lookupError;
  Timer? _debounceTimer;
  String _lastLookedUpId = '';

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _inputController.dispose();
    super.dispose();
  }

  void _onIdChanged() {
    _debounceTimer?.cancel();
    setState(() {
      _validationError = null;
      // Clear operator if id changed from what was looked up
      if (_input != _lastLookedUpId) {
        _operator = null;
        _lookupError = null;
      }
    });

    if (_input.length < 4) {
      // Too short — clear everything
      setState(() {
        _operator = null;
        _isLookingUp = false;
        _lookupError = null;
        _lastLookedUpId = '';
      });
      return;
    }

    if (_input.length == _maxLength) {
      // Immediate lookup at full length
      _performLookup(_input);
    } else {
      // Debounce for partial input (4–7 chars)
      _debounceTimer = Timer(const Duration(milliseconds: 400), () {
        _performLookup(_input);
      });
    }
  }

  Future<void> _performLookup(String id) async {
    if (id == _lastLookedUpId && _operator != null) return;

    setState(() {
      _isLookingUp = true;
      _lookupError = null;
      _operator = null;
    });

    final capturedId = id;
    try {
      final result = await fetchOperatorById(id);

      // Guard: if id has changed since we started, ignore this result
      if (!mounted || _input != capturedId) return;

      setState(() {
        _isLookingUp = false;
        _lastLookedUpId = capturedId;
        if (result != null) {
          _operator = result;
          _lookupError = null;
        } else {
          _operator = null;
          _lookupError = 'ID tidak ditemukan';
        }
      });
    } catch (_) {
      if (!mounted || _input != capturedId) return;
      setState(() {
        _isLookingUp = false;
        _lookupError = 'Gagal mencari operator';
      });
    }
  }

  void _append(String value) {
    if (_input.length >= _maxLength) return;
    setState(() {
      _input = '$_input$value';
      _inputController.value = TextEditingValue(
        text: _input,
        selection: TextSelection.collapsed(offset: _input.length),
      );
    });
    _onIdChanged();
  }

  void _backspace() {
    if (_input.isEmpty) return;
    setState(() {
      _input = _input.substring(0, _input.length - 1);
      _inputController.value = TextEditingValue(
        text: _input,
        selection: TextSelection.collapsed(offset: _input.length),
      );
    });
    _onIdChanged();
  }

  Future<void> _submit() async {
    if (_input.length != _maxLength) {
      setState(() => _validationError = 'Masukkan 8 digit ID.');
      return;
    }
    if (_operator == null) {
      setState(() => _validationError =
          _lookupError ?? (_isLookingUp ? 'Menunggu pencarian...' : 'ID tidak ditemukan.'));
      return;
    }

    setState(() {
      _submitting = true;
      _validationError = null;
    });
    try {
      final service = ref.read(mdtServiceProvider);
      await service.recordLogin(operatorId: _input);
      ref.read(sessionProvider.notifier).setOperator(_input);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.hmMulai);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Card ──
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Top row: Logo + Online pill ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              height: 30,
                              fit: BoxFit.contain,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22A86B),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Online',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Input row ──
                        TextField(
                          readOnly: true,
                          enableInteractiveSelection: false,
                          controller: _inputController,
                          style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Masukan ID Anda',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              letterSpacing: 0,
                              fontSize: 15,
                            ),
                            suffixText: '${_input.length}/$_maxLength',
                            suffixStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),

                        // ── Operator name row ──
                        const SizedBox(height: 12),
                        _buildOperatorRow(),

                        // ── Inline validation ──
                        if (_validationError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _validationError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // ── Keypad ──
                        _buildKeypad(),
                      ],
                    ),
                  ),
                ),

                // ── Footer ──
                const SizedBox(height: 24),
                Text(
                  'V 1.0',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorRow() {
    Widget valueWidget;

    if (_isLookingUp) {
      valueWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Mencari…',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    } else if (_operator != null) {
      valueWidget = Text(
        _operator!.name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1B2A4A),
        ),
      );
    } else if (_lookupError != null) {
      valueWidget = Text(
        _lookupError!,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.red,
        ),
      );
    } else {
      valueWidget = Text(
        '-',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade400,
        ),
      );
    }

    return Row(
      children: [
        Text(
          'Nama Operator: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(child: valueWidget),
      ],
    );
  }

  Widget _buildKeypad() {
    final keys = <_KeyDef>[
      _KeyDef.digit('1'),
      _KeyDef.digit('2'),
      _KeyDef.digit('3'),
      _KeyDef.digit('4'),
      _KeyDef.digit('5'),
      _KeyDef.digit('6'),
      _KeyDef.digit('7'),
      _KeyDef.digit('8'),
      _KeyDef.digit('9'),
      _KeyDef.icon(Icons.backspace_outlined, 'backspace'),
      _KeyDef.digit('0'),
      _KeyDef.icon(Icons.arrow_forward, 'enter'),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      children: keys.map((key) => _buildKeyButton(key)).toList(),
    );
  }

  Widget _buildKeyButton(_KeyDef key) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _submitting
            ? null
            : () {
                if (key.type == _KeyType.digit) {
                  _append(key.label!);
                } else if (key.action == 'backspace') {
                  _backspace();
                } else if (key.action == 'enter') {
                  _submit();
                }
              },
        customBorder: const CircleBorder(),
        splashColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Center(
            child: key.type == _KeyType.digit
                ? Text(
                    key.label!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  )
                : Icon(
                    key.icon,
                    size: 22,
                    color: const Color(0xFF555555),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Key definition helper ──

enum _KeyType { digit, icon }

class _KeyDef {
  final _KeyType type;
  final String? label;
  final IconData? icon;
  final String? action;

  const _KeyDef._({
    required this.type,
    this.label,
    this.icon,
    this.action,
  });

  factory _KeyDef.digit(String label) =>
      _KeyDef._(type: _KeyType.digit, label: label);

  factory _KeyDef.icon(IconData icon, String action) =>
      _KeyDef._(type: _KeyType.icon, icon: icon, action: action);
}
