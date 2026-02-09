import 'package:flutter/material.dart';
import 'package:kebun_sawit/mvc_models/laporan.dart';
import 'package:printing/printing.dart';
import 'pdf_generator.dart';

class PreviewLaporanPdf extends StatelessWidget {
  final InformasiUmum infoUmum;
  final RingkasanAktivitas ringkasan;
  final List<RekapPekerjaan> rekapPekerjaan;
  final KesehatanTanaman kesehatanTanaman;
  final String catatanLapangan;
  final bool fotoTerlampir;
  final bool dokumentasiVisualTersedia;
  final ValidasiPengesahan validasi;
  final InformasiSistem infoSistem;

  const PreviewLaporanPdf({
    super.key,
    required this.infoUmum,
    required this.ringkasan,
    required this.rekapPekerjaan,
    required this.kesehatanTanaman,
    required this.catatanLapangan,
    required this.fotoTerlampir,
    required this.dokumentasiVisualTersedia,
    required this.validasi,
    required this.infoSistem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Laporan PDF'),
      ),
      body: PdfPreview(
        build: (format) async => await generateLaporanPdf(
          // Isi dengan data yang sesuai
          infoUmum,
          ringkasan,
          rekapPekerjaan,
          kesehatanTanaman,
          catatanLapangan,
          fotoTerlampir,
          dokumentasiVisualTersedia,
          validasi,
          infoSistem,
        ),
      ),
    );
  }
}
