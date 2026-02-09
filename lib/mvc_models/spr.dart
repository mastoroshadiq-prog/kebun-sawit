class SPR {
  final String idSPR;    // PRIMARY KEY
  final String blok;
  final String nbaris;
  final String sprAwal;
  final String sprAkhir;
  final String keterangan;
  final String petugas;
  final int flag;

  SPR({
    required this.idSPR,
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
      'idSPR': idSPR,
      'blok': blok,
      'nbaris': nbaris,
      'sprAwal': sprAwal,
      'sprAkhir': sprAkhir,
      'keterangan': keterangan,
      'petugas': petugas,
      'flag': flag,
    };
  }

  factory SPR.fromMap(Map<String, dynamic> map) {
    return SPR(
      idSPR: map['idSPR'] ?? '',
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
