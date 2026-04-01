import 'package:flutter_test/flutter_test.dart';
import 'package:ptba_mdt/shared/utils/display_helpers.dart';

void main() {
  group('formatElapsed', () {
    test('zero seconds', () {
      expect(formatElapsed(0), '00:00:00');
    });

    test('negative clamps to zero', () {
      expect(formatElapsed(-10), '00:00:00');
    });

    test('59 seconds', () {
      expect(formatElapsed(59), '00:00:59');
    });

    test('60 seconds = 1 minute', () {
      expect(formatElapsed(60), '00:01:00');
    });

    test('3661 seconds = 1h 1m 1s', () {
      expect(formatElapsed(3661), '01:01:01');
    });

    test('86399 seconds = 23:59:59', () {
      expect(formatElapsed(86399), '23:59:59');
    });
  });

  group('formatClock', () {
    test('midnight', () {
      expect(formatClock(DateTime(2026, 1, 1, 0, 0)), '00:00');
    });

    test('afternoon', () {
      expect(formatClock(DateTime(2026, 1, 1, 14, 30)), '14:30');
    });

    test('single digit hour/minute', () {
      expect(formatClock(DateTime(2026, 1, 1, 9, 5)), '09:05');
    });
  });

  group('categoryDisplayLabel', () {
    test('maps operation → Operasi', () {
      expect(categoryDisplayLabel('operation'), 'Operasi');
    });

    test('maps standby → Standby', () {
      expect(categoryDisplayLabel('standby'), 'Standby');
    });

    test('maps delay → Delay', () {
      expect(categoryDisplayLabel('delay'), 'Delay');
    });

    test('maps breakdown → Breakdown', () {
      expect(categoryDisplayLabel('breakdown'), 'Breakdown');
    });

    test('null returns -', () {
      expect(categoryDisplayLabel(null), '-');
    });

    test('unknown returns as-is', () {
      expect(categoryDisplayLabel('xyz'), 'xyz');
    });
  });

  group('subtypeDisplayLabel', () {
    test('maps loading → Loading', () {
      expect(subtypeDisplayLabel('loading'), 'Loading');
    });

    test('maps changeShift → Change Shift', () {
      expect(subtypeDisplayLabel('changeShift'), 'Change Shift');
    });

    test('maps break → Istirahat', () {
      expect(subtypeDisplayLabel('break'), 'Istirahat');
    });

    test('maps break_ → Istirahat', () {
      expect(subtypeDisplayLabel('break_'), 'Istirahat');
    });

    test('maps nonProductive → Non Produksi', () {
      expect(subtypeDisplayLabel('nonProductive'), 'Non Produksi');
    });

    test('maps roadIssue → Gangguan Jalan', () {
      expect(subtypeDisplayLabel('roadIssue'), 'Gangguan Jalan');
    });

    test('maps undercarriageBody → Undercarriage / Body', () {
      expect(subtypeDisplayLabel('undercarriageBody'), 'Undercarriage / Body');
    });

    test('null returns -', () {
      expect(subtypeDisplayLabel(null), '-');
    });
  });
}
