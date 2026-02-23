import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/mdt_service.dart';
import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';

class RingkasanPekerjaanScreen extends ConsumerWidget {
  const RingkasanPekerjaanScreen({super.key});

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    Future<RingkasanPekerjaan> load() async {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Pekerjaan')),
      body: FutureBuilder<RingkasanPekerjaan>(
        future: load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(snapshot.error?.toString() ?? 'Gagal memuat ringkasan.'),
            );
          }

          final data = snapshot.data!;
          return Center(
            child: Card(
              child: SizedBox(
                width: 420,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Pekerjaan',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                      ),
                      const SizedBox(height: 12),
                      Text('Operator: ${data.operatorId}'),
                      Text('Unit: ${data.unitId}'),
                      Text('HM Mulai: ${data.hmMulai.toStringAsFixed(1)}'),
                      Text('HM Akhir: ${data.hmAkhir.toStringAsFixed(1)}'),
                      Text('Total Durasi Aktivitas: ${_fmt(data.durasiShift)}'),
                      Text('Jumlah Aktivitas: ${data.jumlahAktivitas}'),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            if (session.operatorId != null) {
                              await ref.read(mdtServiceProvider).recordLogout(
                                    operatorId: session.operatorId!,
                                    unitId: session.unitId,
                                  );
                            }
                            ref.read(sessionProvider.notifier).resetAll();
                            if (!context.mounted) {
                              return;
                            }
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.login,
                              (_) => false,
                            );
                          },
                          child: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
