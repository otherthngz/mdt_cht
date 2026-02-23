import 'package:flutter_test/flutter_test.dart';
import 'package:mdt_fms_ptba/core/events/event_models.dart';
import 'package:mdt_fms_ptba/core/events/p2h_rule_engine.dart';

void main() {
  group('P2HRuleEngine', () {
    test('returns FAIL when any critical issue exists', () {
      final issues = [
        P2HIssue(title: 'Brake fail', severity: IssueSeverity.critical),
      ];
      expect(P2HRuleEngine.evaluate(issues), P2HOutcome.fail);
    });

    test('returns PASS_WITH_NOTES when non-critical issues exist', () {
      final issues = [
        P2HIssue(title: 'Wiper worn', severity: IssueSeverity.normal),
      ];
      expect(P2HRuleEngine.evaluate(issues), P2HOutcome.passWithNotes);
    });

    test('returns PASS when no issues', () {
      expect(P2HRuleEngine.evaluate(const <P2HIssue>[]), P2HOutcome.pass);
    });
  });
}
