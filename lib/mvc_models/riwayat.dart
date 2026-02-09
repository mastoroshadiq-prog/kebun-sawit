class Riwayat {
  final String id;           // Nomor SPK
  final String objectId;     // referensi ke pohon.objectId
  final String tanggal;      // format bebas: yyyy-mm-dd
  final String jenis;        // contoh: "Eridikasi", "Pemupukan", "Penyemprotan", "Penyakit"
  final String keterangan;   // catatan bebas
  final String status;       // contoh: "SELESAI", "TUNDA", "DELEGASI"

  Riwayat({
    required this.id,
    required this.objectId,
    required this.tanggal,
    required this.jenis,
    required this.keterangan,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'objectId': objectId,
      'tanggal': tanggal,
      'jenis': jenis,
      'keterangan': keterangan,
      'status': status,
    };
  }

  factory Riwayat.fromMap(Map<String, dynamic> map) {
    return Riwayat(
      id: map['id'] ?? '',
      objectId: map['objectId'] ?? '',
      tanggal: map['tanggal'] ?? '',
      jenis: map['jenis'] ?? '',
      keterangan: map['keterangan'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
