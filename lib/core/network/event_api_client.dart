import '../events/event_models.dart';

enum ApiEventResultType { applied, duplicate, rejectedConflict, transientFailure }

class ApiEventResult {
  ApiEventResult({
    required this.type,
    this.code,
    this.message,
  });

  final ApiEventResultType type;
  final String? code;
  final String? message;
}

abstract class EventApiClient {
  Future<ApiEventResult> postEvent(EventEnvelope event);

  Future<List<Assignment>> getAssignments({
    required String unitId,
    DateTime? sinceUtc,
  });
}
