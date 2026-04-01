import 'package:ptba_mdt/data/local_storage/hive_storage.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/repositories/shift_repository.dart';

/// Hive-backed implementation of [ShiftRepository].
class ShiftRepositoryImpl implements ShiftRepository {
  @override
  Future<void> saveShiftSession(ShiftSession session) async {
    final box = getShiftSessionBox();
    await box.put(kActiveShiftKey, session);
  }

  @override
  Future<ShiftSession?> getActiveShiftSession() async {
    final box = getShiftSessionBox();
    final session = box.get(kActiveShiftKey);
    if (session != null && session.status == 'active') {
      return session;
    }
    return null;
  }

  @override
  Future<void> updateShiftSession(ShiftSession session) async {
    final box = getShiftSessionBox();
    await box.put(kActiveShiftKey, session);
  }

  @override
  Future<ShiftSession?> getLatestShiftSession() async {
    final box = getShiftSessionBox();
    return box.get(kActiveShiftKey);
  }

  @override
  Future<void> clearShiftSession() async {
    final box = getShiftSessionBox();
    await box.delete(kActiveShiftKey);
  }
}
