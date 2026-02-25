/// Placeholder operator lookup service.
///
/// TODO: Connect to real API endpoint when available.
/// Currently returns mock data for demonstration purposes.

class Operator {
  const Operator({required this.id, required this.name});
  final String id;
  final String name;
}

/// Mock operator database. Replace with real API call.
const _mockOperators = <String, String>{
  '12345678': 'AERI',
  '11111111': 'WAHYU',
  '87654321': 'BUDI SANTOSO',
  '11223344': 'CITRA DEWI',
  '55667788': 'DANI PRATAMA',
  '99887766': 'EKO WIDODO',
};

/// Fetches an operator by their ID.
///
/// Returns [Operator] if found, `null` if not found.
/// In production, replace the mock lookup with a real HTTP call.
///
/// ```dart
/// // TODO: Replace with real API call, e.g.:
/// // final response = await dio.get('/api/operators/$id');
/// // if (response.statusCode == 200) return Operator.fromJson(response.data);
/// // return null;
/// ```
Future<Operator?> fetchOperatorById(String id) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 600));

  final name = _mockOperators[id];
  if (name != null) {
    return Operator(id: id, name: name);
  }
  return null;
}
