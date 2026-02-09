// models/report_summary.dart

// ===============================
// ENUM
// ===============================

enum ReportStatus {
  lancar,
  terkendala,
}

enum SyncStatus {
  synced,
  notSynced,
}

// ===============================
// REPORT SUMMARY (DTO)
// ===============================

class ReportSummary {
  // === Informasi Umum (Template Section A) ===
  final DateTime reportDate;
  final String userId;
  final String userName;
  final String estate;

  // === Ringkasan Aktivitas (Template Section B) ===
  final int totalSpk;
  final int completedSpk;
  final int pendingSpk;
  final int totalTreesHandled;
  final ReportStatus status;

  // === Informasi Sistem (Template Section H) ===
  final String reportId;
  final DateTime generatedAt;
  final SyncStatus syncStatus;

  ReportSummary({
    required this.reportDate,
    required this.userId,
    required this.userName,
    required this.estate,
    required this.totalSpk,
    required this.completedSpk,
    required this.pendingSpk,
    required this.totalTreesHandled,
    required this.status,
    required this.reportId,
    required this.generatedAt,
    required this.syncStatus,
  });

  // ===============================
  // HELPER (OPTIONAL, TAPI BERGUNA)
  // ===============================

  String get statusLabel {
    switch (status) {
      case ReportStatus.lancar:
        return 'Lancar';
      case ReportStatus.terkendala:
        return 'Terkendala';
    }
  }

  String get syncStatusLabel {
    switch (syncStatus) {
      case SyncStatus.synced:
        return 'Sudah';
      case SyncStatus.notSynced:
        return 'Belum';
    }
  }
}
