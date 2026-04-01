import 'package:flutter_test/flutter_test.dart';
import 'package:ptba_mdt/domain/models/enums.dart';

void main() {
  group('ActivityCategory', () {
    test('has exactly 4 values', () {
      expect(ActivityCategory.values.length, 4);
    });

    test('values match doc names', () {
      expect(ActivityCategory.values.map((e) => e.name).toList(),
          ['operation', 'standby', 'delay', 'breakdown']);
    });
  });

  group('ActivitySubtype', () {
    test('has exactly 20 values', () {
      expect(ActivitySubtype.values.length, 20);
    });

    test('operation subtypes', () {
      final subs = categorySubtypes[ActivityCategory.operation]!;
      expect(subs.map((s) => s.name).toList(),
          ['loading', 'hauling', 'dumping', 'nonProductive']);
    });

    test('standby subtypes', () {
      final subs = categorySubtypes[ActivityCategory.standby]!;
      expect(subs.length, 4);
      expect(subs.contains(ActivitySubtype.changeShift), isTrue);
      expect(subs.contains(ActivitySubtype.break_), isTrue);
    });

    test('delay subtypes', () {
      final subs = categorySubtypes[ActivityCategory.delay]!;
      expect(subs.length, 6);
      expect(subs.map((s) => s.name),
          containsAll(['rain', 'flood', 'roadIssue', 'extremeDust',
              'lightningStorm', 'landslide']));
    });

    test('breakdown subtypes', () {
      final subs = categorySubtypes[ActivityCategory.breakdown]!;
      expect(subs.length, 6);
      expect(subs.map((s) => s.name),
          containsAll(['engine', 'hydraulic', 'electrical',
              'transmission', 'undercarriageBody', 'brakeSteering']));
    });
  });

  group('subtypeCategoryMap', () {
    test('every subtype has a parent category', () {
      for (final subtype in ActivitySubtype.values) {
        expect(subtypeCategoryMap.containsKey(subtype), isTrue,
            reason: '${subtype.name} must be in subtypeCategoryMap');
      }
    });

    test('loading belongs to operation', () {
      expect(subtypeCategoryMap[ActivitySubtype.loading],
          ActivityCategory.operation);
    });

    test('changeShift belongs to standby', () {
      expect(subtypeCategoryMap[ActivitySubtype.changeShift],
          ActivityCategory.standby);
    });

    test('rain belongs to delay', () {
      expect(subtypeCategoryMap[ActivitySubtype.rain],
          ActivityCategory.delay);
    });

    test('engine belongs to breakdown', () {
      expect(subtypeCategoryMap[ActivitySubtype.engine],
          ActivityCategory.breakdown);
    });
  });

  group('subtypeToString / subtypeFromString', () {
    test('break_ converts to "break" for storage', () {
      expect(subtypeToString(ActivitySubtype.break_), 'break');
    });

    test('other subtypes use .name directly', () {
      expect(subtypeToString(ActivitySubtype.loading), 'loading');
      expect(subtypeToString(ActivitySubtype.changeShift), 'changeShift');
    });

    test('"break" converts back to break_', () {
      expect(subtypeFromString('break'), ActivitySubtype.break_);
    });

    test('round-trip all subtypes', () {
      for (final subtype in ActivitySubtype.values) {
        final str = subtypeToString(subtype);
        final restored = subtypeFromString(str);
        expect(restored, subtype,
            reason: 'Round-trip failed for ${subtype.name}');
      }
    });
  });

  group('EventName', () {
    test('has exactly 4 values', () {
      expect(EventName.values.length, 4);
    });

    test('values match doc names', () {
      expect(EventName.values.map((e) => e.name).toList(),
          ['SHIFT_STARTED', 'ACTIVITY_STARTED',
           'ACTIVITY_ENDED', 'SHIFT_ENDED']);
    });
  });

  group('ShiftStatus', () {
    test('has exactly 2 values', () {
      expect(ShiftStatus.values.length, 2);
    });

    test('values are active and ended', () {
      expect(ShiftStatus.values.map((e) => e.name).toList(),
          ['active', 'ended']);
    });
  });
}
