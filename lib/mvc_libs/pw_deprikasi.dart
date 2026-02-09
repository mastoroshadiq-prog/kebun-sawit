// ignore_for_file: unused_element
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:kebun_sawit/mvc_models/laporan.dart';

pw.Widget _buildGeneralInfoTable(InformasiUmum data) {
  return pw.TableHelper.fromTextArray(
    border: null,
    columnWidths: const {
      0: pw.FixedColumnWidth(100), // Item
      1: pw.FlexColumnWidth(3), // Keterangan
    },
    cellAlignment: pw.Alignment.centerLeft,
    cellPadding: const pw.EdgeInsets.all(2),
    cellStyle: const pw.TextStyle(fontSize: 10),
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
    data: <List<String>>[
      ['Item', 'Keterangan'],
      ['Tanggal Laporan', data.tanggalLaporan],
      ['Nama Petugas', data.namaPetugas],
      ['ID Petugas', data.idPetugas],
      ['Jabatan', data.jabatan],
      ['Estate / Divisi', data.estateDivisi],
      ['Aplikasi', 'Aplikasi Manajemen Kebun Sawit'],
    ],
  );
}

pw.Widget _buildSummaryTable(RingkasanAktivitas data) {
  return pw.TableHelper.fromTextArray(
    border: pw.TableBorder.all(color: PdfColors.grey300),
    cellAlignment: pw.Alignment.centerLeft,
    cellStyle: const pw.TextStyle(fontSize: 10),
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
    data: <List<String>>[
      ['Uraian', 'Jumlah'],
      ['Total SPK Diterima', '${data.totalSpkDiterima} SPK'],
      ['SPK Selesai', '${data.spkSelesai} SPK'],
      ['SPK Ditunda', '${data.spkDitunda} SPK'],
      ['Total Pohon Ditangani', '${data.totalPohonDitangani} Pohon'],
    ],
  );
}

pw.Widget _buildRekapPekerjaanTable(List<RekapPekerjaan> data) {
  final headers = [
    'No',
    'No. SPK',
    'Jenis Pekerjaan',
    'Lokasi (Blok)',
    'Status',
  ];

  final tableData = data.asMap().entries.map((entry) {
    int index = entry.key + 1;
    RekapPekerjaan item = entry.value;
    return [
      index.toString(),
      item.noSpk,
      item.jenisPekerjaan,
      item.lokasiBlok,
      item.status,
    ];
  }).toList();

  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: tableData,
    border: pw.TableBorder.all(color: PdfColors.grey300),
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
    cellStyle: const pw.TextStyle(fontSize: 9),
    cellAlignment: pw.Alignment.centerLeft,
  );
}

pw.Widget _buildKesehatanTable(KesehatanTanaman data) {
  return pw.TableHelper.fromTextArray(
    headers: ['Jenis', 'Jumlah Pohon', 'Keterangan Singkat'],
    data: [
      ['Kesehatan', data.kesehatanJumlah.toString(), data.kesehatanKeterangan],
      ['Reposisi', data.reposisiJumlah.toString(), data.reposisiKeterangan],
    ],
    border: pw.TableBorder.all(color: PdfColors.grey300),
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
    cellStyle: const pw.TextStyle(fontSize: 9),
    cellAlignment: pw.Alignment.centerLeft,
  );
}

pw.Widget _buildInformasiSistem(InformasiSistem data) {
  return pw.TableHelper.fromTextArray(
    border: null,
    columnWidths: const {
      0: pw.FixedColumnWidth(100), // Item
      1: pw.FlexColumnWidth(3), // Keterangan
    },
    cellAlignment: pw.Alignment.centerLeft,
    cellPadding: const pw.EdgeInsets.all(1),
    cellStyle: const pw.TextStyle(fontSize: 8),
    data: <List<String>>[
      ['ID Laporan:', data.idLaporan],
      ['Waktu Generate:', data.waktuGenerate],
      ['Perangkat:', data.perangkat],
      ['Status Sinkronisasi:', data.statusSinkronisasi],
    ],
  );
}


