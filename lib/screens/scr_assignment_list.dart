// screens/assignment_list_screen.dart
import 'package:flutter/material.dart';
import 'package:kebun_sawit/mvc_models/laporan.dart';
import '../mvc_dao/dao_petugas.dart';
import '../mvc_libs/pdf_preview.dart';
import '../mvc_models/petugas.dart';
import '../screens/widgets/w_general.dart';
import '../../mvc_dao/dao_assignment.dart';
import '../../mvc_models/assignment.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreen();
}

class _AssignmentListScreen extends State<AssignmentListScreen> {
  late Future<Petugas?> petugas;
  late Future<List<Assignment>> assignmentFuture;
  late InformasiUmum infoUmum;
  late RingkasanAktivitas ringkasan;
  late List<RekapPekerjaan> listRekapPekerjaan;
  late KesehatanTanaman kesehatanTanaman;
  late String catatanLapangan = 'Tidak ada catatan tambahan.';
  late bool fotoTerlampir = false;
  late bool dokumentasiVisualTersedia = false;
  late ValidasiPengesahan validasi;
  late InformasiSistem infoSistem;
  late RekapPekerjaan rekapPekerjaan;

  @override
  void initState() {
    super.initState();
    // Future dibuat sekali di initState
    assignmentFuture = AssignmentDao().getAllAssignment();  // ambil data SQLite
    petugas = PetugasDao().getPetugas();

    infoUmum = InformasiUmum(
        tanggalLaporan: DateTime.now().toIso8601String(),
        namaPetugas: 'namaPetugas',
        idPetugas: 'idPetugas',
        jabatan: 'jabatan',
        estateDivisi: 'estateDivisi'
    );

    ringkasan = RingkasanAktivitas(
        totalSpkDiterima: 10,
        spkSelesai: 8,
        spkDitunda: 2,
        totalPohonDitangani: 150,
        statusUmum: 'Sebagian'
    );

    rekapPekerjaan = RekapPekerjaan(
      noSpk: 'SPK001',
      jenisPekerjaan: 'Pemupukan',
      lokasiBlok: 'Blok A1',
      status: 'Selesai',
    );

    listRekapPekerjaan = [rekapPekerjaan];

    kesehatanTanaman = KesehatanTanaman(
      kesehatanJumlah: 150,
      kesehatanKeterangan: 'Sehat',
      reposisiJumlah: 5,
      reposisiKeterangan: 'Ditemukan',
    );

    validasi = ValidasiPengesahan(
      dibuatNama: '',
      dibuatId: '',
      dibuatTanggal: DateTime.now().toIso8601String(),
      diperiksaNama: '',
      diperiksaJabatan: '',
      diperiksaTanggal: '',
      catatanPemeriksa: '',
    );

    infoSistem = InformasiSistem(
      idLaporan: 'LAP123456',
      waktuGenerate: DateTime.now().toIso8601String(),
      perangkat: 'Android Device',
      statusSinkronisasi: 'Belum'
    );
  }
//class AssignmentListScreen extends StatelessWidget {
  //const AssignmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
        appBar : cfgAppBar('Daftar Tugas', Colors.lightGreen.shade900),
        body: FutureBuilder<List<Assignment>>(
            future: assignmentFuture,  // AssignmentDao().getAllAssignment(),
            //future: AssignmentDao().getAllAssignment(),  // ambil data SQLite
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final assignments = snapshot.data ?? [];

              if (assignments.isEmpty) {
                return const Center(child: Text('Tidak ada data tugas'));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //_resMenu(context),
                    Expanded(
                      child: ListView.builder(
                        itemCount: assignments.length,
                        itemBuilder: (context, index) {
                          final assignment = assignments[index];
                          return _resCardConfig(
                            context, assignment, assignment.spkNumber,
                            assignment.taskName,
                          );
                        }
                      ),
                    )
                  ],
              );
            }
        ),

      );
  }

  Card _resCardConfig(BuildContext context, Object data, String strTitle, String subTitle) {
    return resCardConfigStyle(
      cfglistTile(
          resText(TextAlign.left, strTitle, 16.0, FontStyle.normal, true, Colors.black),
          resText(TextAlign.left, subTitle, 16.0, FontStyle.normal, true, Colors.black),
          Color(0xFFDCEDC8),
          cfgNavigator(
              context: context,
              action: 'push',
              //routeName: '/detail',
              routeName: '/goDetail',
              arguments: data
          ),
      ),
      8.0, 12.0, Color(0xFFDCEDC8)
    );
  }
// ignore: unused_element
  Card _resMenu(BuildContext context) {
    return resCardConfigStyle(
        cfgCenterColumn(
          children: listAction(context),
        ),
        10.0, 12.0,
        Color(0xFFE8F5E9)
    );
  }

  List<Widget> listAction(BuildContext context) {
    return [
      const SizedBox(height: 15),
      rowItems(),
      const SizedBox(height: 15),
      secondRowItems(),
      const SizedBox(height: 15),
    ];
  }

  Widget rowItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // --- Tombol 1: Sync (Icon dalam Lingkaran) ---
        _buildMenuItem(
          context,
          icon: Icons.cloud_upload,
          label: 'Sync',
          iconColor: Colors.white,
          circleColor: Colors.green.shade800, // Warna lingkaran untuk Sync
          onTap: cfgNavigator(
            context: context,
            action: 'push',
            routeName: '/syncPage',
          ),
        ),

        // --- Tombol 2: Report (Icon dalam Lingkaran) ---
        _buildMenuItem(
          context,
          icon: Icons.picture_as_pdf,
          label: 'Report',
          iconColor: Colors.white,
          circleColor: Colors.lightBlue, // Warna lingkaran untuk Report

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PreviewLaporanPdf(
                  infoUmum: infoUmum,
                  ringkasan: ringkasan,
                  rekapPekerjaan: listRekapPekerjaan,
                  kesehatanTanaman: kesehatanTanaman,
                  catatanLapangan: catatanLapangan,
                  fotoTerlampir: fotoTerlampir,
                  dokumentasiVisualTersedia: dokumentasiVisualTersedia,
                  validasi: validasi,
                  infoSistem: infoSistem,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget secondRowItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // --- Tombol 1: Sync (Icon dalam Lingkaran) ---
        _buildMenuItem(
          context,
          icon: Icons.sync_alt,
          label: 'Reposisi',
          iconColor: Colors.white,
          circleColor: Colors.orange.shade800, // Warna lingkaran untuk Sync
          onTap: cfgNavigator(
            context: context,
            action: 'push',
            routeName: '/reposisi',
            //arguments: '',
          ),
        ),

        // --- Tombol 2: Report (Icon dalam Lingkaran) ---
        _buildMenuItem(
          context,
          icon: Icons.assignment,
          label: 'Taks List',
          iconColor: Colors.white,
          circleColor: Colors.blue.shade800, // Warna lingkaran untuk Sync
          onTap: cfgNavigator(
            context: context,
            action: 'push',
            routeName: '/reposisi',
            //arguments: '',
          ),
        ),
      ],
    );
  }

  // Helper Widget untuk membuat setiap item menu (Card)
  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        required Color iconColor,
        required Color circleColor,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          width: 110,
          height: 140,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // *** Bagian Ikon di dalam Lingkaran ***
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle, // Membuat bentuk lingkaran
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: iconColor, // Warna ikon (misalnya, putih)
                ),
              ),
              // **************************************
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

