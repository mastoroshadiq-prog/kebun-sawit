// screens/assignment_list_screen.dart
import 'package:flutter/material.dart';
import 'package:kebun_sawit/mvc_models/laporan.dart';
import '../mvc_libs/pdf_preview.dart';
import '../screens/widgets/w_general.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreen();
}

class _MenuScreen extends State<MenuScreen> {
  //late Future<Petugas?> petugas;
  //late Future<List<Assignment>> assignmentFuture;
  late final InformasiUmum infoUmum;
  late final RingkasanAktivitas ringkasan;
  late final List<RekapPekerjaan> listRekapPekerjaan;
  late final KesehatanTanaman kesehatanTanaman;
  String catatanLapangan = 'Tidak ada catatan tambahan.';
  bool fotoTerlampir = false;
  bool dokumentasiVisualTersedia = false;
  late final ValidasiPengesahan validasi;
  late final InformasiSistem infoSistem;
  late final RekapPekerjaan rekapPekerjaan;

  @override
  void initState() {
    super.initState();
    // Future dibuat sekali di initState
    // assignmentFuture = AssignmentDao().getAllAssignment();  // ambil data SQLite
    // petugas = PetugasDao().getPetugas();

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

  @override
  Widget build(BuildContext context) {
    final menuItems = _menuItems(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Menu Utama'),
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1F6A5A),
                const Color(0xFF2D8A73),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFF1F7F5), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD6E7E2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akses Cepat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF225A4D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih fitur untuk sinkronisasi, laporan, dan operasional lapangan.',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF4D7A6E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: menuItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.92, end: 1),
                      duration: Duration(milliseconds: 260 + (index * 90)),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) => Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Transform.scale(scale: value, child: child),
                      ),
                      child: _buildMenuItem(
                        context,
                        icon: item.icon,
                        label: item.label,
                        iconColor: Colors.white,
                        circleColor: item.color,
                        onTap: item.onTap,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_MenuAction> _menuItems(BuildContext context) {
    return [
      _MenuAction(
        icon: Icons.cloud_upload_rounded,
        label: 'SYNC',
        color: const Color(0xFF3C8D7A),
        onTap: cfgNavigator(
          context: context,
          action: 'push',
          routeName: '/syncPage',
        ),
      ),
      _MenuAction(
        icon: Icons.picture_as_pdf_rounded,
        label: 'REPORT',
        color: const Color(0xFF4E7FA8),
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
      _MenuAction(
        icon: Icons.assignment_rounded,
        label: 'TASK LIST',
        color: const Color(0xFF5B74A8),
        onTap: cfgNavigator(
          context: context,
          action: 'push',
          routeName: '/assignments',
        ),
      ),
      _MenuAction(
        icon: Icons.flash_on_rounded,
        label: 'AKSI',
        color: const Color(0xFF8E6A8F),
        onTap: cfgNavigator(
          context: context,
          action: 'push',
          routeName: '/optAct',
        ),
      ),
    ];
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
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      color: const Color(0xFFFBFCFD),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.0),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE8EDF2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // *** Bagian Ikon di dalam Lingkaran ***
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle, // Membuat bentuk lingkaran
                  boxShadow: [
                    BoxShadow(
                      color: circleColor.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: iconColor, // Warna ikon (misalnya, putih)
                ),
              ),
              // **************************************
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuAction {
  _MenuAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}
