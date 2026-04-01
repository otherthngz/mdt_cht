/// Contract for sending operator actions to external APIs.
///
/// The app remains local-first: implementations should avoid throwing and
/// should not block the core shift flow when remote sync fails.
abstract class OperatorActivityApi {
  Future<void> postStartShift({
    required String unitId,
    required String operatorId,
    required double hmStart,
  });

  Future<void> postSwitchActivity({
    required String shiftSessionId,
    required String nextActivityCategory,
    required String nextActivitySubtype,
    String? loaderCode,
    String? haulingCode,
  });

  Future<void> postEndShift({
    required String shiftSessionId,
    required double hmEnd,
  });

  Future<void> postInteraction({
    required String action,
    String? shiftSessionId,
    String? unitId,
    String? operatorId,
    Map<String, Object?> metadata,
  });
}

/// Safe default used in tests and when remote sync is not configured yet.
class NoopOperatorActivityApi implements OperatorActivityApi {
  const NoopOperatorActivityApi();

  @override
  Future<void> postEndShift({
    required String shiftSessionId,
    required double hmEnd,
  }) async {}

  @override
  Future<void> postInteraction({
    required String action,
    String? shiftSessionId,
    String? unitId,
    String? operatorId,
    Map<String, Object?> metadata = const {},
  }) async {}

  @override
  Future<void> postStartShift({
    required String unitId,
    required String operatorId,
    required double hmStart,
  }) async {}

  @override
  Future<void> postSwitchActivity({
    required String shiftSessionId,
    required String nextActivityCategory,
    required String nextActivitySubtype,
    String? loaderCode,
    String? haulingCode,
  }) async {}
}
