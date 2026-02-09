class Kesehatan {
  final String idKesehatan;   // PRIMARY KEY
  final String idTanaman;     // referensi ke pohon.objectId
  final String statusAwal;    // 5,4,3,2,1--> SSB, SB, SS, SR, S
  final String statusAkhir;   // 5,4,3,2,1--> SSB, SB, SS, SR, S
  final String kodeStatus;    // contoh: G0, G1, G2, G3, G4
  final String jenisPohon;    // UTAMA, SISIP
  final String keterangan;    // catatan bebas
  final String petugas;
  final String fromDate;
  final int flag;        // 0: default, 1: sudah sinkron ke server

  Kesehatan({
    required this.idKesehatan,
    required this.idTanaman,
    required this.statusAwal,
    required this.statusAkhir,
    required this.kodeStatus,
    required this.jenisPohon,
    required this.keterangan,
    required this.petugas,
    required this.fromDate,
    required this.flag,
  });

  Map<String, dynamic> toMap() {
    return {
      'idKesehatan': idKesehatan,
      'idTanaman': idTanaman,
      'statusAwal': statusAwal,
      'statusAkhir': statusAkhir,
      'kodeStatus': kodeStatus,
      'jenisPohon': jenisPohon,
      'keterangan': keterangan,
      'petugas': petugas,
      'fromDate': fromDate,
      'flag': flag,
    };
  }

  factory Kesehatan.fromMap(Map<String, dynamic> map) {
    return Kesehatan(
      idKesehatan: map['idKesehatan'] ?? '',
      idTanaman: map['idTanaman'] ?? '',
      statusAwal: map['statusAwal'] ?? '',
      statusAkhir: map['statusAkhir'] ?? '',
      kodeStatus: map['kodeStatus'] ?? '',
      jenisPohon: map['jenisPohon'] ?? '',
      keterangan: map['keterangan'] ?? '',
      petugas: map['petugas'] ?? '',
      fromDate: map['fromDate'] ?? '',
      flag: map['flag'] ?? 0,
    );
  }
}
