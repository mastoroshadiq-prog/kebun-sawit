
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:kebun_sawit/mvc_models/laporan.dart';


/// Helper untuk membuat tabel PDF yang reusable
pw.Widget buildPdfTable({
  required List<String> headers,        // Judul kolom
  required List<List<String>> data,      // Isi baris tabel
  pw.TableBorder? border,                // Border tabel (opsional)
  pw.TextStyle? headerStyle,             // Style teks header
  pw.TextStyle? cellStyle,               // Style teks cell
  pw.Alignment cellAlignment = pw.Alignment.centerLeft, // Alignment cell
  Map<int, pw.TableColumnWidth>? columnWidths, // Lebar kolom
  pw.EdgeInsets cellPadding = const pw.EdgeInsets.all(4), // Padding cell
}) {
  return pw.Table(
    // Border tabel (misal: semua garis abu-abu)
    border: border,

    // Mengatur lebar tiap kolom jika dibutuhkan
    columnWidths: columnWidths,

    // Semua baris (header + data)
    children: [
      // ================= HEADER =================
      pw.TableRow(
        children: headers.map((headerText) {
          return pw.Padding(
            padding: cellPadding, // Spasi di dalam cell
            child: pw.Text(
              headerText,
              style: headerStyle ??
                  pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                  ),
            ),
          );
        }).toList(),
      ),

      // ================= DATA ROWS =================
      ...data.map(
            (row) => pw.TableRow(
          children: row.map((cellText) {
            return pw.Padding(
              padding: cellPadding, // Spasi di dalam cell
              child: pw.Align(
                alignment: cellAlignment, // Alignment teks
                child: pw.Text(
                  cellText,
                  style: cellStyle ?? const pw.TextStyle(fontSize: 9),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

pw.Widget buildGeneralInfoTable(InformasiUmum data) {
  return buildPdfTable(
    // ================= HEADER =================
    headers: const [
      'Item',
      'Keterangan',
    ],

    // ================= DATA =================
    data: [
      ['Tanggal Laporan', data.tanggalLaporan],
      ['Nama Petugas', data.namaPetugas],
      ['ID Petugas', data.idPetugas],
      ['Jabatan', data.jabatan],
      ['Estate / Divisi', data.estateDivisi],
      ['Aplikasi', 'Aplikasi Manajemen Kebun Sawit'],
    ],

    // ================= BORDER =================
    // border: null → tabel tanpa garis (sama seperti kode lama)
    border: null,

    // ================= COLUMN WIDTH =================
    // Menentukan lebar kolom persis seperti versi deprecated
    columnWidths: const {
      0: pw.FixedColumnWidth(100), // Kolom Item (lebar tetap)
      1: pw.FlexColumnWidth(3),    // Kolom Keterangan (fleksibel)
    },

    // ================= STYLE =================
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 10,
    ),
    cellStyle: const pw.TextStyle(
      fontSize: 10,
    ),

    // ================= LAYOUT =================
    cellAlignment: pw.Alignment.centerLeft,
    cellPadding: const pw.EdgeInsets.all(2),
  );
}

pw.Widget buildSummaryTable(RingkasanAktivitas data) {
  return buildPdfTable(
    // ================= HEADER =================
    headers: const [
      'Uraian',
      'Jumlah',
    ],

    // ================= DATA =================
    data: [
      ['Total SPK Diterima', '${data.totalSpkDiterima} SPK'],
      ['SPK Selesai', '${data.spkSelesai} SPK'],
      ['SPK Ditunda', '${data.spkDitunda} SPK'],
      ['Total Pohon Ditangani', '${data.totalPohonDitangani} Pohon'],
    ],

    // ================= BORDER =================
    border: pw.TableBorder.all(color: PdfColors.grey),

    // ================= STYLE =================
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 10,
    ),
    cellStyle: const pw.TextStyle(
      fontSize: 10,
    ),

    // ================= LAYOUT =================
    cellAlignment: pw.Alignment.centerLeft,
  );
}

pw.Widget buildRekapPekerjaanTable(List<RekapPekerjaan> data) {
  // ================= HEADER =================
  final headers = [
    'No',
    'No. SPK',
    'Jenis Pekerjaan',
    'Lokasi (Blok)',
    'Status',
  ];

  // ================= DATA =================
  // Mengubah List<RekapPekerjaan> menjadi List<List<String>>
  // sekaligus menambahkan nomor urut (index + 1)
  final tableData = data.asMap().entries.map((entry) {
    final index = entry.key + 1;
    final item = entry.value;

    return [
      index.toString(),        // No
      item.noSpk,              // No. SPK
      item.jenisPekerjaan,     // Jenis Pekerjaan
      item.lokasiBlok,         // Lokasi (Blok)
      item.status,             // Status
    ];
  }).toList();

  // ================= TABLE =================
  return buildPdfTable(
    headers: headers,
    data: tableData,

    // Border tabel (garis abu-abu)
    border: pw.TableBorder.all(color: PdfColors.grey),

    // Style header
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 9,
    ),

    // Style isi tabel
    cellStyle: const pw.TextStyle(
      fontSize: 9,
    ),

    // Alignment teks dalam cell
    cellAlignment: pw.Alignment.centerLeft,
  );
}


pw.Widget buildKesehatanTable(KesehatanTanaman data) {
  return buildPdfTable(
    // Header tabel
    headers: ['Jenis', 'Jumlah Pohon', 'Keterangan Singkat',],

    // Data tabel
    data: [
      ['Kesehatan', data.kesehatanJumlah.toString(), data.kesehatanKeterangan,],
      ['Reposisi', data.reposisiJumlah.toString(), data.reposisiKeterangan,],
    ],

    // Border tabel
    border: pw.TableBorder.all(color: PdfColors.grey),

    // Style header
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 9,
    ),

    // Style cell
    cellStyle: const pw.TextStyle(
      fontSize: 9,
    ),

    // Alignment teks di dalam cell
    cellAlignment: pw.Alignment.centerLeft,

    // Lebar kolom (opsional tapi disarankan)
    columnWidths: const {
      0: pw.FlexColumnWidth(2), // Jenis
      1: pw.FlexColumnWidth(2), // Jumlah
      2: pw.FlexColumnWidth(4), // Keterangan
    },
  );
}

pw.Widget buildInformasiSistem(InformasiSistem data) {
  return buildPdfTable(
    // ================= HEADER =================
    // Header dibuat kosong agar tabel tampil seperti versi lama
    headers: const ['', ''],

    // ================= DATA =================
    data: [
      ['ID Laporan:', data.idLaporan],
      ['Waktu Generate:', data.waktuGenerate],
      ['Perangkat:', data.perangkat],
      ['Status Sinkronisasi:', data.statusSinkronisasi],
    ],

    // ================= BORDER =================
    // border: null → tanpa garis
    border: null,

    // ================= COLUMN WIDTH =================
    columnWidths: const {
      0: pw.FixedColumnWidth(100), // Item
      1: pw.FlexColumnWidth(3),    // Keterangan
    },

    // ================= STYLE =================
    cellStyle: const pw.TextStyle(
      fontSize: 8,
    ),

    // ================= LAYOUT =================
    cellAlignment: pw.Alignment.centerLeft,
    cellPadding: const pw.EdgeInsets.all(1),
  );
}
