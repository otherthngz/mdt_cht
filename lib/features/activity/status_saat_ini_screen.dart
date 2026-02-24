import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';
import '../../core/events/event_models.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const _kGreen = Color(0xFF0EAE7A);
const _kGreenBg = Color(0xFFE6F9F3);
const _kYellow = Color(0xFFB88700);
const _kYellowBg = Color(0xFFFFF9E6);
const _kRed = Color(0xFFD92D20);
const _kRedBg = Color(0xFFFEECEB);
const _kNavy = Color(0xFF1A2B4A);

class StatusSaatIniScreen extends ConsumerStatefulWidget {
  const StatusSaatIniScreen({super.key});

  @override
  ConsumerState<StatusSaatIniScreen> createState() =>
      _StatusSaatIniScreenState();
}

class _StatusSaatIniScreenState extends ConsumerState<StatusSaatIniScreen> {
  Timer? _clock;
  String _shiftTimer = '00:00:00';
  String _activityTimer = '00:24:32';
  bool _isOnline = false;
  StreamSubscription<dynamic>? _connectivitySub;
  bool _stopping = false;

  @override
  void initState() {
    super.initState();
    _recompute();
    _clock = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _recompute(),
    );
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final c = Connectivity();
    _updateOnline(await c.checkConnectivity());
    _connectivitySub = c.onConnectivityChanged.listen(_updateOnline);
  }

  void _updateOnline(dynamic result) {
    final online = result is List
        ? result.any((r) => r != ConnectivityResult.none)
        : result != ConnectivityResult.none;
    if (mounted && online != _isOnline) setState(() => _isOnline = online);
  }

  @override
  void dispose() {
    _clock?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }

  void _recompute() {
    final session = ref.read(sessionProvider);

    // Shift timer
    final shiftStart = session.shiftStartedAtUtc;
    if (shiftStart != null) {
      final d = DateTime.now().toUtc().difference(shiftStart);
      final next = _fmtDuration(d);
      if (mounted && next != _shiftTimer) setState(() => _shiftTimer = next);
    }

    // Activity timer
    final actStart = session.activityStartedAtUtc;
    if (actStart != null) {
      final d = DateTime.now().toUtc().difference(actStart);
      final next = _fmtDuration(d);
      if (mounted && next != _activityTimer) {
        setState(() => _activityTimer = next);
      }
    }
  }

  String _fmtDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _stopActivity() async {
    final session = ref.read(sessionProvider);
    if (session.operatorId == null || session.unitId == null) return;

    setState(() => _stopping = true);
    try {
      final elapsed = await ref.read(mdtServiceProvider).stopActivity(
            operatorId: session.operatorId!,
            unitId: session.unitId!,
          );
      if (session.activeStatus != null) {
        ref.read(sessionProvider.notifier).addActivityDuration(
              category: session.activeStatus!,
              elapsed: elapsed,
            );
      }
      ref.read(sessionProvider.notifier).clearActivity();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _stopping = false);
    }
  }

  Future<void> _openActivityLog(ActivityState state) async {
    await Navigator.of(context)
        .pushNamed(AppRoutes.activityLog, arguments: {'state': state.name});
    _recompute();
  }

  Future<void> _confirmEndShift() async {
    final session = ref.read(sessionProvider);
    if (session.operatorId == null || session.unitId == null) return;

    if (session.activeActivityLabel != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hentikan aktivitas yang berjalan sebelum mengakhiri shift.'),
        ),
      );
      return;
    }

    final service = ref.read(mdtServiceProvider);
    await service.requestEndShift(
      operatorId: session.operatorId!,
      unitId: session.unitId!,
    );

    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Akhiri Shift?'),
        content: const Text(
          'Apakah anda yakin ingin mengakhiri pekerjaan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Akhiri'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    await service.confirmEndShift(
      operatorId: session.operatorId!,
      unitId: session.unitId!,
    );
    if (!mounted) return;
    Navigator.of(context).pushNamed(AppRoutes.hmAkhir);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final hasActivity = session.activeActivityLabel != null;
    final activityState = session.activeStatus;

    // Derive active button colour for the running state pill
    Color stateColor = _kGreen;
    if (activityState == ActivityState.standbyDelay) stateColor = _kYellow;
    if (activityState == ActivityState.breakdown) stateColor = _kRed;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // BukitAsam branding
                  _BukitAsamLogo(),
                  const SizedBox(width: 20),
                  _HeaderDivider(),
                  const SizedBox(width: 16),
                  _HeaderChip(
                    label: 'Operator',
                    value: session.operatorId ?? '-',
                  ),
                  const SizedBox(width: 12),
                  _HeaderDivider(),
                  const SizedBox(width: 12),
                  _HeaderChip(
                    label: 'Unit',
                    value: session.unitId ?? 'H515',
                  ),
                  const SizedBox(width: 12),
                  _HeaderDivider(),
                  const SizedBox(width: 12),
                  _StatusChip(online: _isOnline),
                  const SizedBox(width: 12),
                  _HeaderDivider(),
                  const SizedBox(width: 12),
                  _HeaderChip(label: 'Timer', value: _shiftTimer, mono: true),
                  const Spacer(),
                  // End Shift button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('End Shift'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kRed,
                      side: const BorderSide(color: _kRed),
                    ),
                    onPressed: _confirmEndShift,
                  ),
                ],
              ),
            ),

            // ── Main body ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT — current status label
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Saat Ini',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: _kNavy,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (!hasActivity)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Belum Ada Aktivitas',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: _kGreenBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _kGreen),
                              ),
                              child: Text(
                                session.activeActivityLabel!,
                                style: const TextStyle(
                                  color: _kGreen,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // RIGHT — activity timer + Stop (shown only when active)
                    if (hasActivity)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _activityTimer,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: _kNavy,
                                  fontFeatures: [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: stateColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  session.activeActivityLabel ?? '',
                                  style: TextStyle(
                                    color: stateColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _stopping ? null : _stopActivity,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _kRed,
                                    minimumSize: const Size(0, 52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _stopping
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Stop',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Bottom buttons ───────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  _ActivityButton(
                    label: 'ACTIVITY',
                    icon: Icons.settings,
                    color: _kGreen,
                    bg: _kGreenBg,
                    enabled: !hasActivity,
                    onTap: () => _openActivityLog(ActivityState.running),
                  ),
                  const SizedBox(width: 12),
                  _ActivityButton(
                    label: 'STANDBY',
                    icon: Icons.hourglass_bottom,
                    color: _kYellow,
                    bg: _kYellowBg,
                    enabled: !hasActivity,
                    onTap: () => _openActivityLog(ActivityState.standbyDelay),
                  ),
                  const SizedBox(width: 12),
                  _ActivityButton(
                    label: 'BREAKDOWN',
                    icon: Icons.warning_amber_rounded,
                    color: _kRed,
                    bg: _kRedBg,
                    enabled: !hasActivity,
                    onTap: () => _openActivityLog(ActivityState.breakdown),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _BukitAsamLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Mountain/sun icon approximation using coloured containers
        SizedBox(
          width: 32,
          height: 32,
          child: CustomPaint(painter: _BukitAsamIconPainter()),
        ),
        const SizedBox(width: 6),
        const Text(
          'BukitAsam',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: Color(0xFF1A3A80),
          ),
        ),
      ],
    );
  }
}

class _BukitAsamIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Yellow arc (sun)
    final yellow = Paint()..color = const Color(0xFFF5A623);
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.45),
      size.width * 0.28,
      yellow,
    );
    // Dark blue mountain
    final blue = Paint()..color = const Color(0xFF1A3A80);
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, blue);
    // Red circle accent
    final red = Paint()..color = const Color(0xFFE53935);
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.25),
      size.width * 0.18,
      red,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.value,
    this.mono = false,
  });
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 13),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: mono ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 20, child: VerticalDivider(width: 1));
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.online});
  final bool online;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 13),
        children: [
          const TextSpan(text: 'Status '),
          TextSpan(
            text: online ? 'Online' : 'Offline',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: online ? _kGreen : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityButton extends StatelessWidget {
  const _ActivityButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1.0 : 0.4,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
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
