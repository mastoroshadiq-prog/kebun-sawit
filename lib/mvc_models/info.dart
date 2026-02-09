
class Info {
  final String kode;
  final String istilah;
  final String namaError;
  final String keterangan;
  final String jenis;

  Info({
    required this.kode,
    required this.istilah,
    required this.namaError,
    required this.keterangan,
    required this.jenis,
  });

  Map<String, dynamic> toMap() {
    return {
      'kode': kode,
      'istilah': istilah,
      'namaError': namaError,
      'keterangan': keterangan,
      'jenis': jenis,
    };
  }

  factory Info.fromMap(Map<String, dynamic> map) {
    return Info(
      kode: map['kode'] ?? '',
      istilah: map['istilah'] ?? '',
      namaError: map['namaError'] ?? '',
      keterangan: map['keterangan'] ?? '',
      jenis: map['jenis'] ?? '',
    );
  }

}
