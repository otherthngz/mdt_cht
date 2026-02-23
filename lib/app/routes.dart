abstract final class AppRoutes {
  static const login = '/login';
  static const hmMulai = '/hm-mulai';
  static const p2h = '/p2h';
  static const statusSaatIni = '/status-saat-ini';
  static const activityLog = '/activity-log';
  static const activeTimer = '/active-timer';
  static const hmAkhir = '/hm-akhir';
  static const ringkasan = '/ringkasan-pekerjaan';

  // Backward-compatible aliases for legacy files not in current flow.
  static const selectUnit = hmMulai;
  static const hmStart = hmMulai;
  static const homeMenu = statusSaatIni;
  static const activity = statusSaatIni;
  static const dispatch = '/dispatch-legacy';
  static const endShift = hmAkhir;
  static const syncStatus = '/sync-status-legacy';
}
