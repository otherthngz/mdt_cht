import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:ptba_mdt/domain/services/operator_activity_api.dart';

/// HTTP implementation for dispatching operator activity to external APIs.
///
/// Configure with `--dart-define`, for example:
/// `--dart-define=MDT_API_BASE_URL=http://10.0.2.2:8080`
class HttpOperatorActivityApi implements OperatorActivityApi {
  HttpOperatorActivityApi({
    required this.baseUrl,
    this.startShiftPath = '/mock-api/shift/start',
    this.switchActivityPath = '/mock-api/activity/switch',
    this.endShiftPath = '/mock-api/shift/end',
    this.interactionPath = '',
    HttpClient? httpClient,
    this.timeout = const Duration(seconds: 5),
  }) : _httpClient = httpClient ?? HttpClient();

  factory HttpOperatorActivityApi.fromEnvironment() {
    return HttpOperatorActivityApi(
      baseUrl: const String.fromEnvironment('MDT_API_BASE_URL'),
      startShiftPath: const String.fromEnvironment(
        'MDT_API_START_SHIFT_PATH',
        defaultValue: '/mock-api/shift/start',
      ),
      switchActivityPath: const String.fromEnvironment(
        'MDT_API_SWITCH_ACTIVITY_PATH',
        defaultValue: '/mock-api/activity/switch',
      ),
      endShiftPath: const String.fromEnvironment(
        'MDT_API_END_SHIFT_PATH',
        defaultValue: '/mock-api/shift/end',
      ),
      interactionPath: const String.fromEnvironment(
        'MDT_API_INTERACTION_PATH',
        defaultValue: '',
      ),
    );
  }

  final String baseUrl;
  final String startShiftPath;
  final String switchActivityPath;
  final String endShiftPath;
  final String interactionPath;
  final Duration timeout;
  final HttpClient _httpClient;

  bool get _isEnabled => baseUrl.trim().isNotEmpty;

  Uri _resolveUri(String path) => Uri.parse(baseUrl).resolve(path);

  @override
  Future<void> postStartShift({
    required String unitId,
    required String operatorId,
    required double hmStart,
  }) async {
    await _postJson(
      path: startShiftPath,
      payload: {'unitId': unitId, 'operatorId': operatorId, 'hmStart': hmStart},
      debugLabel: 'startShift',
    );
  }

  @override
  Future<void> postSwitchActivity({
    required String shiftSessionId,
    required String nextActivityCategory,
    required String nextActivitySubtype,
    String? loaderCode,
    String? haulingCode,
  }) async {
    final payload = <String, Object?>{
      'shiftSessionId': shiftSessionId,
      'nextActivityCategory': nextActivityCategory,
      'nextActivitySubtype': nextActivitySubtype,
    };
    if (loaderCode != null) {
      payload['loaderCode'] = loaderCode;
    }
    if (haulingCode != null) {
      payload['haulingCode'] = haulingCode;
    }

    await _postJson(
      path: switchActivityPath,
      payload: payload,
      debugLabel: 'switchActivity',
    );
  }

  @override
  Future<void> postEndShift({
    required String shiftSessionId,
    required double hmEnd,
  }) async {
    await _postJson(
      path: endShiftPath,
      payload: {'shiftSessionId': shiftSessionId, 'hmEnd': hmEnd},
      debugLabel: 'endShift',
    );
  }

  @override
  Future<void> postInteraction({
    required String action,
    String? shiftSessionId,
    String? unitId,
    String? operatorId,
    Map<String, Object?> metadata = const {},
  }) async {
    await _postJson(
      path: interactionPath,
      payload: {
        'action': action,
        'occurredAt': DateTime.now().toIso8601String(),
        'shiftSessionId': shiftSessionId,
        'unitId': unitId,
        'operatorId': operatorId,
        'metadata': metadata,
      },
      debugLabel: 'interaction:$action',
    );
  }

  Future<void> _postJson({
    required String path,
    required Map<String, Object?> payload,
    required String debugLabel,
  }) async {
    if (!_isEnabled || path.trim().isEmpty) return;

    try {
      final request = await _httpClient
          .postUrl(_resolveUri(path))
          .timeout(timeout);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));

      final response = await request.close().timeout(timeout);
      await response.drain<void>();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        developer.log(
          'Operator API call failed with status ${response.statusCode}',
          name: 'HttpOperatorActivityApi',
          error: debugLabel,
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'Operator API call failed',
        name: 'HttpOperatorActivityApi',
        error: '$debugLabel: $error',
        stackTrace: stackTrace,
      );
    }
  }
}
