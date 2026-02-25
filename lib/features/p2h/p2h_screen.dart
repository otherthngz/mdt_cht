import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';

enum P2HItemStatus { belum, aman, bermasalah }

class P2HScreen extends ConsumerStatefulWidget {
  const P2HScreen({super.key});

  @override
  ConsumerState<P2HScreen> createState() => _P2HScreenState();
}

class _P2HScreenState extends ConsumerState<P2HScreen> {
  static const _items = <String>[
    'BAN, VELG,\nBAUT RODA',
    'AIR RADIATOR',
    'APAR',
    'SPION',
    'KLAKSON &\nALRM MUNDUR',
    'PANEL\nKONTROL',
    'FATIGUE ALARM',
    'AIR\nCONDITIONER\n(AC)',
    'WIPER',
    'V-BELT',
    'KACA DEPAN,\nSAMPING,\nBELAKANG',
    'RADIO\nKOMUNIKASI',
    'BENDERA\nBREAKDOWN',
    'TRAFFIC CONE',
    'WHEEL CHOCK',
    'SAFETY SWITCH\nSUMPING',
  ];

  final Map<String, P2HItemStatus> _statusByItem = {
    for (final item in _items) item: P2HItemStatus.belum,
  };

  bool _saving = false;

  Color _background(P2HItemStatus status) {
    return switch (status) {
      P2HItemStatus.belum => Colors.white,
      P2HItemStatus.aman => const Color(0xFFD9F5EA),
      P2HItemStatus.bermasalah => const Color(0xFFFBE1E6),
    };
  }

  P2HItemStatus _next(P2HItemStatus status) {
    return switch (status) {
      P2HItemStatus.belum => P2HItemStatus.aman,
      P2HItemStatus.aman => P2HItemStatus.bermasalah,
      P2HItemStatus.bermasalah => P2HItemStatus.belum,
    };
  }

  String _wireStatus(P2HItemStatus status) {
    return switch (status) {
      P2HItemStatus.belum => 'unset',
      P2HItemStatus.aman => 'safe',
      P2HItemStatus.bermasalah => 'problem',
    };
  }

  Future<void> _toggleItem(String item) async {
    final session = ref.read(sessionProvider);
    if (session.operatorId == null || session.unitId == null) {
      return;
    }

    final next = _next(_statusByItem[item]!);
    setState(() {
      _statusByItem[item] = next;
    });

    await ref.read(mdtServiceProvider).emitP2HItemUpdated(
          operatorId: session.operatorId!,
          unitId: session.unitId!,
          item: item,
          status: _wireStatus(next),
        );
  }

  void _checkSemua(bool value) {
    setState(() {
      for (final key in _statusByItem.keys) {
        _statusByItem[key] = value ? P2HItemStatus.aman : P2HItemStatus.belum;
      }
    });
  }

  Future<void> _submit() async {
    final session = ref.read(sessionProvider);
    if (session.operatorId == null || session.unitId == null) {
      return;
    }

    final incomplete = _statusByItem.values.any((value) => value == P2HItemStatus.belum);
    if (incomplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua item P2H wajib diisi.')),
      );
      return;
    }

    // EDGE CASE B: block if >3 bermasalah items
    final bermasalahCount =
        _statusByItem.values.where((v) => v == P2HItemStatus.bermasalah).length;
    if (bermasalahCount > 3) {
      await showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Terlalu banyak temuan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B2A4A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Temuan bermasalah lebih dari 3. Anda harus melapor sebelum dapat melanjutkan.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2A4A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mengerti',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          barrierColor: Colors.black54,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apakah anda yakin?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B2A4A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pastikan semua data telah diisi dengan benar sebelum melanjutkan.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Kembali',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B2A4A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Ya, Lanjutkan',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    setState(() => _saving = true);
    try {
      final statuses = <String, String>{
        for (final entry in _statusByItem.entries)
          entry.key: _wireStatus(entry.value),
      };
      await ref.read(mdtServiceProvider).submitP2HChecklist(
            operatorId: session.operatorId!,
            unitId: session.unitId!,
            itemStatuses: statuses,
          );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.statusSaatIni);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allChecked = _statusByItem.values
        .every((value) => value == P2HItemStatus.aman);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengecekan dan Pemeriksaan Harian (P2H)'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              child: const Text('Selesai'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '1x klik Aman ; 2x klik bermasalah ; 3x klik reset',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Checkbox(
                  value: allChecked,
                  onChanged: (value) => _checkSemua(value ?? false),
                  activeColor: const Color(0xFF1B2A4A),
                ),
                Text(
                  'Check Semua',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  mainAxisExtent: 140,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final status = _statusByItem[item]!;
                  return _buildTile(item, status);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String item, P2HItemStatus status) {
    final bgColor = _background(status);
    final borderColor = switch (status) {
      P2HItemStatus.belum => Colors.grey.shade300,
      P2HItemStatus.aman => const Color(0xFFB0DFC8),
      P2HItemStatus.bermasalah => const Color(0xFFF0B3BD),
    };

    final statusIcon = switch (status) {
      P2HItemStatus.belum => '—',
      P2HItemStatus.aman => '✓',
      P2HItemStatus.bermasalah => '✕',
    };
    final statusLabel = switch (status) {
      P2HItemStatus.belum => 'belum',
      P2HItemStatus.aman => 'aman',
      P2HItemStatus.bermasalah => 'masalah',
    };
    final statusColor = switch (status) {
      P2HItemStatus.belum => Colors.grey,
      P2HItemStatus.aman => const Color(0xFF0EAE7A),
      P2HItemStatus.bermasalah => const Color(0xFFD92D20),
    };

    return InkWell(
      onTap: () => _toggleItem(item),
      borderRadius: BorderRadius.circular(11),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(11),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF1B2A4A),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$statusIcon ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
