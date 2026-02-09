// file: laporan_data.dart
class InformasiUmum {
  final String tanggalLaporan;
  final String namaPetugas;
  final String idPetugas;
  final String jabatan;
  final String estateDivisi;

  InformasiUmum({
    required this.tanggalLaporan,
    required this.namaPetugas,
    required this.idPetugas,
    required this.jabatan,
    required this.estateDivisi,
  });
}

class RingkasanAktivitas {
  final int totalSpkDiterima;
  final int spkSelesai;
  final int spkDitunda;
  final int totalPohonDitangani;
  final String statusUmum; // Contoh: 'Lancar' atau 'Terkendala'

  RingkasanAktivitas({
    required this.totalSpkDiterima,
    required this.spkSelesai,
    required this.spkDitunda,
    required this.totalPohonDitangani,
    required this.statusUmum,
  });
}

class RekapPekerjaan {
  final String noSpk;
  final String jenisPekerjaan;
  final String lokasiBlok;
  final String status;

  RekapPekerjaan({
    required this.noSpk,
    required this.jenisPekerjaan,
    required this.lokasiBlok,
    required this.status,
  });
}

class InformasiSistem {
  final String idLaporan;
  final String waktuGenerate;
  final String perangkat;
  final String statusSinkronisasi; // Contoh: 'Sudah' atau 'Belum'
  InformasiSistem({
    required this.idLaporan,
    required this.waktuGenerate,
    required this.perangkat,
    required this.statusSinkronisasi,
  });
}

class ValidasiPengesahan {
  final String dibuatNama;
  final String dibuatId;
  final String dibuatTanggal;
  final String diperiksaNama;
  final String diperiksaJabatan;
  final String diperiksaTanggal;
  final String catatanPemeriksa;
  ValidasiPengesahan({
    required this.dibuatNama,
    required this.dibuatId,
    required this.dibuatTanggal,
    required this.diperiksaNama,
    required this.diperiksaJabatan,
    required this.diperiksaTanggal,
    required this.catatanPemeriksa,
  });
}

class KesehatanTanaman {
  final int kesehatanJumlah;
  final String kesehatanKeterangan;
  final int reposisiJumlah;
  final String reposisiKeterangan;
  KesehatanTanaman({
    required this.kesehatanJumlah,
    required this.kesehatanKeterangan,
    required this.reposisiJumlah,
    required this.reposisiKeterangan,
    });
}