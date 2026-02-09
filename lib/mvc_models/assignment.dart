// models/assignment.dart
class Assignment {
  final String id;
  final String spkNumber;
  final String taskName;
  final String estate;
  final String division;
  final String block;
  final String rowNumber;
  final String treeNumber;
  final String petugas;

  Assignment({
    required this.id,
    required this.spkNumber,
    required this.taskName,
    required this.estate,
    required this.division,
    required this.block,
    required this.rowNumber,
    required this.treeNumber,
    required this.petugas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'spkNumber': spkNumber,
      'taskName': taskName,
      'estate': estate,
      'division': division,
      'block': block,
      'rowNumber': rowNumber,
      'treeNumber': treeNumber,
      'petugas': petugas,
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'] ?? '',
      spkNumber: map['spkNumber'] ?? '',
      taskName: map['taskName'] ?? '',
      estate: map['estate'] ?? '',
      division: map['division'] ?? '',
      block: map['block'] ?? '',
      rowNumber: map['rowNumber'] ?? '',
      treeNumber: map['treeNumber'] ?? '',
      petugas: map['petugas'] ?? '',
    );
  }

  String get fullLocation => 'Estate $estate / Divisi $division / Blok $block / Baris $rowNumber / Pohon ke $treeNumber';
  String get location => 'Estate $estate / Divisi $division / Blok $block';
}