import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ptba_mdt/domain/services/operator_activity_api.dart';

/// Remote operator activity sync is optional.
/// The default provider is a no-op and can be overridden in `main.dart`.
final operatorActivityApiProvider = Provider<OperatorActivityApi>((ref) {
  return const NoopOperatorActivityApi();
});
