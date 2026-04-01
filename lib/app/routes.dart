import 'package:flutter/material.dart';
import 'package:ptba_mdt/features/start_shift/start_shift_step1_page.dart';
import 'package:ptba_mdt/features/start_shift/start_shift_step2_page.dart';
import 'package:ptba_mdt/features/summary/summary_page.dart';
import 'package:ptba_mdt/features/activity/main_activity_page.dart';
import 'package:ptba_mdt/features/timesheet/timesheet_page.dart';

/// Named routes — per 06_ARCHITECTURE.md §4.1.
class AppRoutes {
  AppRoutes._();

  static const String startShift = '/';
  static const String startShiftStep2 = '/start-shift/step-2';
  static const String mainActivity = '/main-activity';
  static const String timesheet = '/timesheet';
  static const String shiftEnded = '/shift-ended';

  static Map<String, WidgetBuilder> get routes => {
        startShift: (context) => const StartShiftStep1Page(),
        startShiftStep2: (context) => const StartShiftStep2Page(),
        mainActivity: (context) => const MainActivityPage(),
        timesheet: (context) => const TimesheetPage(),
        shiftEnded: (context) => const SummaryPage(),
      };
}
