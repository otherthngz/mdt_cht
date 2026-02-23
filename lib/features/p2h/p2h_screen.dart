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

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Apakah anda yakin?'),
            content: const Text(
              'Pastikan semua data telah diisi dengan benar sebelum melanjutkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Kembali'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Ya, Lanjutkan'),
              ),
            ],
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1x klik Aman; 2x klik bermasalah; 3x klik reset'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Checkbox(
                  value: allChecked,
                  onChanged: (value) => _checkSemua(value ?? false),
                ),
                const Text('Check Semua'),
              ],
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.45,
                children: [
                  for (final item in _items)
                    InkWell(
                      onTap: () => _toggleItem(item),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _background(_statusByItem[item]!),
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: Text(
                          item,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
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
