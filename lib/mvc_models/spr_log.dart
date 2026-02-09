class SPRLog {
  final String idLog;    // PRIMARY KEY
  final String blok;
  final String nbaris;
  final String sprAwal;
  final String sprAkhir;
  final String keterangan;
  final String petugas;
  final int flag;

  SPRLog({
    required this.idLog,
    required this.blok,
    required this.nbaris,
    required this.sprAwal,
    required this.sprAkhir,
    required this.keterangan,
    required this.petugas,
    required this.flag,
  });

  Map<String, dynamic> toMap() {
    return {
      'idLog': idLog,
      'blok': blok,
      'nbaris': nbaris,
      'sprAwal': sprAwal,
      'sprAkhir': sprAkhir,
      'keterangan': keterangan,
      'petugas': petugas,
      'flag': flag,
    };
  }

  factory SPRLog.fromMap(Map<String, dynamic> map) {
    return SPRLog(
      idLog: map['idLog'] ?? '',
      blok: map['blok'] ?? '',
      nbaris: map['nbaris'] ?? '',
      sprAwal: map['sprAwal'] ?? '',
      sprAkhir: map['sprAkhir'] ?? '',
      keterangan: map['keterangan'] ?? '',
      petugas: map['petugas'] ?? '',
      flag: map['flag'] ?? 0,
    );
  }
}
