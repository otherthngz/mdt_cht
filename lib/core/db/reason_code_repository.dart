import 'package:drift/drift.dart';

import '../events/event_models.dart';
import 'app_database.dart';

class ReasonCodeRepository {
  ReasonCodeRepository(this._db);

  final AppDatabase _db;

  Future<List<ReasonCode>> listActive() async {
    final rows = await _db.customSelect(
      '''
        SELECT * FROM reason_codes
        WHERE active = 1
        ORDER BY group_name, label
      ''',
    ).get();

    return rows
        .map(
          (row) => ReasonCode(
            code: row.read<String>('code'),
            groupName: row.read<String>('group_name'),
            label: row.read<String>('label'),
            active: row.read<int>('active') == 1,
          ),
        )
        .toList();
  }
}
