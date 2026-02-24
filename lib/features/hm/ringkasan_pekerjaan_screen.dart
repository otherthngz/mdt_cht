import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/mdt_service.dart';
import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';

const _kNavy = Color(0xFF1A2B4A);

class RingkasanPekerjaanScreen extends ConsumerStatefulWidget {
  const RingkasanPekerjaanScreen({super.key});

  @override
  ConsumerState<RingkasanPekerjaanScreen> createState() =>
      _RingkasanPekerjaanScreenState();
}

class _RingkasanPekerjaanScreenState
    extends ConsumerState<RingkasanPekerjaanScreen> {
  late Future<RingkasanPekerjaan> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<RingkasanPekerjaan> _load() async {
    final session = ref.read(sessionProvider);
    if (session.operatorId == null ||
        session.unitId == null ||
        session.hmStart == null ||
        session.hmEnd == null) {
      throw ArgumentError('Data ringkasan belum lengkap.');
    }
    return ref.read(mdtServiceProvider).buildRingkasanPekerjaan(
          operatorId: session.operatorId!,
          unitId: session.unitId!,
          hmMulai: session.hmStart!,
          hmAkhir: session.hmEnd!,
        );
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F5),
      body: Center(
        child: FutureBuilder<RingkasanPekerjaan>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final data = snap.data;
            final err = snap.error;

            return Container(
              width: 560,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Row(
                    children: [
                      _BukitAsamLogo(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ringkasan Pekerjaan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _kNavy,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (err != null) ...[
                    Text(
                      'Gagal memuat ringkasan: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ] else if (data != null) ...[
                    // ── Info grid ──────────────────────────────────────────
                    Row(
                      children: [
                        _InfoTile(
                          icon: Icons.person_outline,
                          label: 'Driver',
                          value: data.operatorId,
                        ),
                        const SizedBox(width: 24),
                        _InfoTile(
                          icon: Icons.local_shipping_outlined,
                          label: 'Asset',
                          value: data.unitId,
                        ),
                        const SizedBox(width: 24),
                        _InfoTile(
                          icon: Icons.location_on_outlined,
                          label: 'HM Mulai',
                          value: data.hmMulai.toStringAsFixed(0),
                        ),
                        const SizedBox(width: 24),
                        _InfoTile(
                          icon: Icons.location_on,
                          label: 'HM Akhir',
                          value: data.hmAkhir.toStringAsFixed(0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    // ── Time breakdown ─────────────────────────────────────
                    Row(
                      children: [
                        _InfoTile(
                          icon: Icons.access_time,
                          label: 'Operational',
                          value: _fmt(session.totalOperational),
                        ),
                        const SizedBox(width: 24),
                        _InfoTile(
                          icon: Icons.access_time,
                          label: 'Standby',
                          value: _fmt(session.totalStandby),
                        ),
                        const SizedBox(width: 24),
                        _InfoTile(
                          icon: Icons.access_time,
                          label: 'Breakdown',
                          value: _fmt(session.totalBreakdown),
                        ),
                        const SizedBox(width: 24),
                        _InfoTile(
                          icon: Icons.access_time,
                          label: 'Total',
                          value: _fmt(session.totalShift),
                          bold: true,
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ── Login button ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _kNavy,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (session.operatorId != null) {
                          await ref.read(mdtServiceProvider).recordLogout(
                                operatorId: session.operatorId!,
                                unitId: session.unitId,
                              );
                        }
                        ref.read(sessionProvider.notifier).resetAll();
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (_) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _BukitAsamLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: CustomPaint(painter: _BukitAsamIconPainter()),
        ),
        const SizedBox(width: 6),
        const Text(
          'BukitAsam',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
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
    final yellow = Paint()..color = const Color(0xFFF5A623);
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.45),
      size.width * 0.28,
      yellow,
    );
    final blue = Paint()..color = const Color(0xFF1A3A80);
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, blue);
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.bold = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: _kNavy,
              fontFamily: label.contains('HM') || label == 'Total' ||
                      label == 'Operational' ||
                      label == 'Standby' ||
                      label == 'Breakdown'
                  ? 'monospace'
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
