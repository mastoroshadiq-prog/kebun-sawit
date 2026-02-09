
import 'package:kebun_sawit/mvc_libs/pw_tables.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:kebun_sawit/mvc_models/laporan.dart';

Future<Uint8List> generateLaporanPdf(
    InformasiUmum infoUmum,
    RingkasanAktivitas ringkasan,
    List<RekapPekerjaan> rekapPekerjaan,
    KesehatanTanaman kesehatanTanaman, // Data D
    String catatanLapangan, // Data E
    bool fotoTerlampir, // Data F
    bool dokumentasiVisualTersedia, // Data F
    ValidasiPengesahan validasi, // Data G
    InformasiSistem infoSistem, // Data H
    ) async {
  final pdf = pw.Document();

  // Gaya umum untuk teks kecil/normal
  const normalStyle = pw.TextStyle(fontSize: 10);
  //final headerStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // --- Header (PT. PERKEBUNAN SAWIT) ---
            pw.Center(
              child: pw.Text('PT. PERKEBUNAN SAWIT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ),
            pw.Center(
              child: pw.Text('LAPORAN HARIAN OPERASIONAL LAPANGAN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ),
            pw.SizedBox(height: 10),

            // --- A. INFORMASI UMUM ---
            _buildSectionTitle('A. INFORMASI UMUM'),
            //_buildGeneralInfoTable(infoUmum),
            buildGeneralInfoTable(infoUmum),

            pw.SizedBox(height: 10),

            // --- B. RINGKASAN AKTIVITAS HARIAN ---
            _buildSectionTitle('B. RINGKASAN AKTIVITAS HARIAN'),
            //_buildSummaryTable(ringkasan),
            buildSummaryTable(ringkasan),

            pw.SizedBox(height: 5),
            pw.Text('Status Umum Pekerjaan: ${ringkasan.statusUmum} (jelaskan di bagian catatan)', style: normalStyle),

            pw.SizedBox(height: 10),

            // --- C. REKAP PEKERJAAN UTAMA ---
            _buildSectionTitle('C. REKAP PEKERJAAN UTAMA'),
            //_buildRekapPekerjaanTable(rekapPekerjaan),
            buildRekapPekerjaanTable(rekapPekerjaan),

            pw.SizedBox(height: 10),

            // --- D. KESEHATAN / REPOSISI TANAMAN ---
            _buildSectionTitle('D. KESEHATAN / REPOSISI TANAMAN (JIKA ADA)'),
            //_buildKesehatanTable(kesehatanTanaman),
            buildKesehatanTable(kesehatanTanaman),

            pw.SizedBox(height: 10),

            // --- E. CATATAN LAPANGAN ---
            _buildSectionTitle('E. CATATAN LAPANGAN'),
            pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(catatanLapangan, style: normalStyle),
            ),

            pw.SizedBox(height: 10),

            // --- F. DOKUMENTASI ---
            _buildSectionTitle('F. DOKUMENTASI'),
            _buildDokumentasi(fotoTerlampir, dokumentasiVisualTersedia),

            pw.Spacer(), // Mendorong validasi ke bawah halaman

            // --- G. VALIDASI & PENGESAHAN ---
            pw.Divider(),
            _buildSectionTitle('G. VALIDASI & PENGESAHAN'),
            _buildValidasiPengesahan(validasi),

            // --- H. INFORMASI SISTEM (OTOMATIS) ---
            _buildSectionTitle('H. INFORMASI SISTEM (OTOMATIS)'),
            //_buildInformasiSistem(infoSistem),
            buildInformasiSistem(infoSistem),

            pw.SizedBox(height: 5),
            pw.Text('Laporan ini dihasilkan oleh Aplikasi Manajemen Kebun Sawit dan menjadi dokumen resmi perusahaan sebagai bukti pelaksanaan pekerjaan lapangan.', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic))
          ],
        );
      },
    ),
  );

  return pdf.save();
}

// --- Helper Widgets (Fungsi Pembantu) ---

pw.Widget _buildSectionTitle(String title) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 5),
    child: pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blueGrey700)),
  );
}


pw.Widget _buildDokumentasi(bool fotoTerlampir, bool visualTersedia) {
  return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('${fotoTerlampir ? '☒' : '☐'} Foto terlampir dalam sistem aplikasi', style: const pw.TextStyle(fontSize: 10)),
        pw.Text('${visualTersedia ? '☒' : '☐'} Dokumentasi visual tersedia (PDF / Arsip Sistem)', style: const pw.TextStyle(fontSize: 10)),
      ]
  );
}

pw.Widget _buildValidasiPengesahan(ValidasiPengesahan data) {
  return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Dibuat Oleh
        pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Dibuat Oleh', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.Text('Nama: ${data.dibuatNama}', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('ID: ${data.dibuatId}', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Tanggal: ${data.dibuatTanggal}', style: const pw.TextStyle(fontSize: 9)),
            ]
        ),
        // Diperiksa Oleh
        pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Diperiksa Oleh', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.Text('Nama: ${data.diperiksaNama}', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Jabatan: ${data.diperiksaJabatan}', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Tanggal: ${data.diperiksaTanggal}', style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 5),
              pw.Text('Catatan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
              pw.Text(data.catatanPemeriksa, style: const pw.TextStyle(fontSize: 9)),
            ]
        ),
      ]
  );
}

