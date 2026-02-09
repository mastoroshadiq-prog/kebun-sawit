class Petugas {
  final String akun;       // PRIMARY KEY (ID unik akun)
  final String nama;       // nama lengkap
  final String kontak;     // nomor telepon atau email
  final String peran;      // contoh: Mandor, Krani, Admin
  final String lastSync;   // yyyy-mm-dd HH:mm:ss
  final String blok;       // opsional
  final String divisi;     // opsional

  Petugas({
    required this.akun,
    required this.nama,
    required this.kontak,
    required this.peran,
    required this.lastSync,
    required this.blok,
    required this.divisi,
  });

  Map<String, dynamic> toMap() {
    return {
      'akun': akun,
      'nama': nama,
      'kontak': kontak,
      'peran': peran,
      'lastSync': lastSync,
      'blok': blok,
      'divisi': divisi,
    };
  }

  factory Petugas.fromMap(Map<String, dynamic> map) {
    return Petugas(
      akun: map['akun'] ?? '',
      nama: map['nama'] ?? '',
      kontak: map['kontak'] ?? '',
      peran: map['peran'] ?? '',
      lastSync: map['lastSync'] ?? '',
      blok: map['blok'] ?? '',
      divisi: map['divisi'] ?? '',
    );
  }
}
