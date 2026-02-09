// ignore_for_file: unused_local_variable
// lib/mvc_services/reporting_service.dart
import 'package:kebun_sawit/mvc_models/laporan.dart';

import '../mvc_dao/dao_petugas.dart';

class ReportingService {
  //Future<Uint8List> buatLaporanPDF() async {
  Future<void> buatLaporanPDF() async {
    final petugas = await PetugasDao().getPetugas();
    if (petugas == null) return;

    final infoUmum = InformasiUmum(
      tanggalLaporan: DateTime.now().toIso8601String(),
      namaPetugas: petugas.nama,
      idPetugas: petugas.akun,
      jabatan: petugas.peran,
      estateDivisi: '',
    );

    final ringkasan = RingkasanAktivitas(
      totalSpkDiterima: 10,
      spkSelesai: 8,
      spkDitunda: 2,
      totalPohonDitangani: 150,
      statusUmum: 'Sebagian',
    );

    final rekapPekerjaan = RekapPekerjaan(
      noSpk: 'SPK001',
      jenisPekerjaan: 'Pemupukan',
      lokasiBlok: 'Blok A1',
      status: 'Selesai',
    );

    final List<RekapPekerjaan> listRekapPekerjaan = [rekapPekerjaan];

    final informasiSistem = InformasiSistem(
      idLaporan: 'LAP123456',
      waktuGenerate: DateTime.now().toIso8601String(),
      perangkat: 'Android Device',
      statusSinkronisasi: 'Belum',
    );

    final kesehatanTanaman = KesehatanTanaman(
      kesehatanJumlah: 150,
      kesehatanKeterangan: 'Sehat',
      reposisiJumlah: 5,
      reposisiKeterangan: 'Ditemukan',
    );

    final validasi = ValidasiPengesahan(
      dibuatNama: petugas.nama,
      dibuatId: petugas.akun,
      dibuatTanggal: DateTime.now().toIso8601String(),
      diperiksaNama: '',
      diperiksaJabatan: '',
      diperiksaTanggal: '',
      catatanPemeriksa: '',
    );
  }
}


