
class AuditLog {
  final String idAudit;
  final String userId;
  final String action;
  final String detail;
  final String logDate;
  final String device;
  final int flag;

  AuditLog({
    required this.idAudit,
    required this.userId,
    required this.action,
    required this.detail,
    required this.logDate,
    required this.device,
    required this.flag,
  });

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      idAudit: map['id_audit'],
      userId: map['user_id'],
      action: map['action'],
      detail: map['detail'],
      logDate: map['log_date'],
      device: map['device'],
      flag: map['flag'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_audit': idAudit,
      'user_id': userId,
      'action': action,
      'detail': detail,
      'log_date': logDate,
      'device': device,
      'flag': flag,
    };
  }
}
