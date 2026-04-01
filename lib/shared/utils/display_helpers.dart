import 'package:flutter/material.dart';
import 'package:ptba_mdt/app/theme/theme.dart';

// ─── Time Formatting ────────────────────────────────────────────────────

/// Format elapsed seconds as HH:MM:SS.
String formatElapsed(int totalSeconds) {
  if (totalSeconds < 0) totalSeconds = 0;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

/// Format a DateTime as HH:mm (24h clock).
String formatClock(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

/// Format a DateTime as dd MMM yyyy (e.g. "01 Apr 2026").
String formatDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
}

// ─── Display Labels (Indonesian) ────────────────────────────────────────

/// Category enum string → Indonesian display label.
String categoryDisplayLabel(String? category) {
  switch (category) {
    case 'operation':
      return 'Operasi';
    case 'standby':
      return 'Standby';
    case 'delay':
      return 'Delay';
    case 'breakdown':
      return 'Breakdown';
    default:
      return category ?? '-';
  }
}

/// Subtype enum string → Indonesian display label.
String subtypeDisplayLabel(String? subtype) {
  switch (subtype) {
    // Operation
    case 'loading':
      return 'Loading';
    case 'hauling':
      return 'Hauling';
    case 'dumping':
      return 'Dumping';
    case 'nonProductive':
      return 'Non Produksi';
    // Standby
    case 'changeShift':
      return 'Change Shift';
    case 'refueling':
      return 'Refueling';
    case 'waiting':
      return 'Antri';
    case 'break':
    case 'break_':
      return 'Istirahat';
    // Delay
    case 'rain':
      return 'Hujan';
    case 'flood':
      return 'Banjir';
    case 'roadIssue':
      return 'Gangguan Jalan';
    case 'extremeDust':
      return 'Debu Ekstrem';
    case 'lightningStorm':
      return 'Petir / Badai';
    case 'landslide':
      return 'Longsor';
    // Breakdown
    case 'engine':
      return 'Engine';
    case 'hydraulic':
      return 'Hydraulic';
    case 'electrical':
      return 'Electrical';
    case 'transmission':
      return 'Transmission';
    case 'undercarriageBody':
      return 'Undercarriage / Body';
    case 'brakeSteering':
      return 'Brake & Steering';
    default:
      return subtype ?? '-';
  }
}

// ─── Category Colors ────────────────────────────────────────────────────

/// Map category string to its themed accent color.
Color categoryColor(String? category) {
  switch (category) {
    case 'operation':
      return MdtTheme.operationColor;
    case 'standby':
      return MdtTheme.standbyColor;
    case 'delay':
      return MdtTheme.delayColor;
    case 'breakdown':
      return MdtTheme.breakdownColor;
    default:
      return Colors.grey;
  }
}

/// Map category string to an icon.
IconData categoryIcon(String? category) {
  switch (category) {
    case 'operation':
      return Icons.engineering;
    case 'standby':
      return Icons.hourglass_empty;
    case 'delay':
      return Icons.warning_amber_rounded;
    case 'breakdown':
      return Icons.build_circle;
    default:
      return Icons.help_outline;
  }
}
