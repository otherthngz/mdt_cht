import 'event_models.dart';

class P2HRuleEngine {
  static P2HOutcome evaluate(List<P2HIssue> issues) {
    if (issues.any((i) => i.severity == IssueSeverity.critical)) {
      return P2HOutcome.fail;
    }
    if (issues.isNotEmpty) {
      return P2HOutcome.passWithNotes;
    }
    return P2HOutcome.pass;
  }
}
