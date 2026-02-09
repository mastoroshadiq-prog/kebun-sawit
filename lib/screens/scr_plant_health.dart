// screens/labs/scr_plant_health.dart
import 'package:flutter/material.dart';
import '../../screens/widgets/w_general.dart';
import '../../mvc_dao/dao_pohon.dart';
import '../../mvc_models/pohon.dart';
import '../../mvc_models/assignment.dart';
import '../../screens/widgets/w_plant_health.dart';

class PlantHealthScreen extends StatefulWidget {
  const PlantHealthScreen({super.key});

  @override
  State<PlantHealthScreen> createState() => _PlantHealthScreen();
}

class _PlantHealthScreen extends State<PlantHealthScreen> {
  late Future<List<Pohon>> pohonFuture;

  @override
  void initState() {
    super.initState();
    pohonFuture = PohonDao().getAllPohon(); // Future dibuat sekali di initState
    //AuditLogDao().createLog("PLANT_HEALTH", "Membuka Halaman Kesehatan Pohon");
  }

  /// 🌲 Fungsi pembantu untuk mengelompokkan data pohon berdasarkan baris yang dipilih.
  Map<int, List<Pohon>> groupByBaris(
    List<Pohon> pohonData,
    List<String> barisTerpilih,
  ) {
    final Map<int, List<Pohon>> grouped = {};

    for (var p in pohonData) {
      final baris = int.tryParse(p.nbaris) ?? 0;
      if (barisTerpilih.contains(p.nbaris)) {
        grouped.putIfAbsent(baris, () => []).add(p);
      }
    }

    // Urutkan berdasarkan nomor pohon menurun (dari besar ke kecil)
    for (var k in grouped.keys) {
      grouped[k]!.sort((a, b) {
        final na = int.tryParse(a.npohon.trim()) ?? 0;
        final nb = int.tryParse(b.npohon.trim()) ?? 0;
        return nb.compareTo(na);
      });
    }

    // Urutkan key baris naik (misal 11, 12, 13)
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (var k in sortedKeys) k: grouped[k]!};
  }

  // --- METODE BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    // 1. Ambil data
    final assignment = ModalRoute.of(context)!.settings.arguments as Assignment;
    int a = int.parse(assignment.rowNumber);
    String b1 = (a - 1).toString();
    String b2 = a.toString();
    String b3 = (a + 1).toString();
    List<String> barisTerpilih = [b1, b2, b3];

    return FutureBuilder<List<Pohon>>(
      //future: PohonDao().getAllPohon(),
      future: pohonFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        //List<Pohon> pohonData = dummyPohonList;
        final pohonData = snapshot.data ?? [];
        //print('Ambil Data Pohon : $pohonData');
        final grouped = groupByBaris(pohonData, barisTerpilih);

        // 2. Cek status kosong
        if (grouped.isEmpty) {
          return buildEmptyState();
        }

        // 3. Hitung dimensi
        final barisKeys = grouped.keys.toList();
        final maxLength = grouped.values
            .map((v) => v.length)
            .reduce((a, b) => a > b ? a : b);

        final screenWidth = MediaQuery.of(context).size.width;
        final columnWidth =
            (screenWidth - 24) /
            barisKeys.length; // Sesuaikan dengan jumlah baris yang ada

        // 4. Bangun UI utama
        return Scaffold(
          appBar: cfgAppBar(
            'Kesehatan Tanaman',
            Colors.blue.shade900,
          ), // fungsi global
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info Lokasi (dipisah ke fungsi)
                buildHeaderInfo(assignment.location),
                const SizedBox(height: 12),
                // Header baris (dipisah ke fungsi)
                buildBarisHeader(barisKeys, columnWidth),
                const SizedBox(height: 8),
                // Pola Hexagonal (dipisah ke fungsi)
                buildHexagonalTreeGrid(
                  context,
                  grouped,
                  barisKeys,
                  maxLength,
                  columnWidth,
                  assignment,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
