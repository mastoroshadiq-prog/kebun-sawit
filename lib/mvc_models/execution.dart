// models/execution.dart

class TaskExecution {
  final String id;
  final String spkNumber;
  final String taskName;
  final String taskState;
  final String petugas;
  final String taskDate;
  final int flag;
  final String keterangan;
  final String? imagePath;

  TaskExecution({
    required this.id,
    required this.spkNumber,
    required this.taskName,
    required this.taskState,
    required this.petugas,
    required this.taskDate,
    required this.flag,
    required this.keterangan,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'spkNumber': spkNumber,
      'taskName': taskName,
      'taskState': taskState,
      'petugas': petugas,
      'taskDate': taskDate,
      'flag': flag,
      'keterangan': keterangan,
      'imagePath': imagePath,
    };
  }

  factory TaskExecution.fromMap(Map<String, dynamic> map) {
    return TaskExecution(
      id: map['id'] ?? '',
      spkNumber: map['spkNumber'] ?? '',
      taskName: map['taskName'] ?? '',
      taskState: map['taskState'] ?? '',
      petugas: map['petugas'] ?? '',
      taskDate: map['taskDate'] ?? '',
      flag: map['flag'] ?? 0,
      keterangan: map['keterangan'] ?? '',
      imagePath: map['imagePath'],
    );
  }
}