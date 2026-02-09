// screens/widgets/w_plant_health.dart
import 'package:flutter/material.dart';
import 'w_general.dart';
import 'w_popup_health.dart';
import '../../mvc_models/pohon.dart';
import '../../mvc_models/assignment.dart';

// --- WIDGET PEMBANTU UNTUK UI UTAMA (Dipisah dari build) ---
/// Widget utama untuk header lokasi (menggunakan fungsi dari config).
Container buildHeaderInfo(String teks) {
  return cfgContainer(
    double.infinity, 0, 15.0, 20,
    cfgBoxDecoration(Colors.blue.shade100, 8.0, Colors.blue.shade800),
    Alignment.center,
    resText(TextAlign.left, teks, 16.0, FontStyle.normal, true, Colors.black),
  );
}

/// 🗺️ Widget untuk menampilkan pesan jika data kosong.
Widget buildEmptyState() {
  return Scaffold(
    appBar: AppBar(title: const Text('Peta Pohon')),
    body: const Center(child: Text('Tidak ada baris yang cocok.')),
  );
}

/// 🌳 Widget untuk menampilkan header baris (label Baris X).
Widget buildBarisHeader(List<int> barisKeys, double columnWidth) {
  return Row(
    children: barisKeys.map((b) {
      return Container(
        width: columnWidth - 8,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
        child: resText(TextAlign.left, 'Baris $b', 20.0, FontStyle.normal, true, Colors.white),
      );
    }).toList(),
  );
}

/// 🌿 Widget untuk menampilkan pola pohon heksagonal dalam ScrollView.
Widget buildHexagonalTreeGrid(
    BuildContext context, Map<int, List<Pohon>> grouped, List<int> barisKeys,
    int maxLength, double columnWidth, Assignment assignment
) {
  return Expanded(
    child: Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(barisKeys.length, (index) {
            final baris = barisKeys[index];
            final pohonList = grouped[baris]!;
            // baris ganjil (1, 3, 5) mulai dengan pohon
            final bool startWithTree = baris.isOdd;

            return SizedBox(
              width: columnWidth,
              child: Column(
                children: List.generate(maxLength * 2, (i) {
                  final isTreeSlot = startWithTree ? i.isEven : i.isOdd;
                  final pohonIndex = i ~/ 2;

                  if (isTreeSlot && pohonIndex < pohonList.length) {
                    return _buildTreeButton(context, pohonList[pohonIndex], assignment);
                  } else {
                    return _buildEmptyTree();
                  }
                }),
              ),
            );
          }),
        ),
      ),
    ),
  );
}

/// POHON AKTIF: ikon di dalam lingkaran, label nomor di bawah
Widget _buildTreeButton(BuildContext context, Pohon pohon, Assignment assignment) {
  int a = int.parse(pohon.status);
  String labelPohon = "${pohon.npohon}/G$a";
  String iconPath = 'assets/icons/normal.png';
  Color color = Colors.green.shade50; // default

  switch (a.toString()) {
    case '0':
      color = Colors.green.shade50;
      break;
    case '1':
      color = Colors.yellow;
      iconPath = 'assets/icons/green_i.png';
      break;
    case '2':
      color = Colors.orange.shade800;
      iconPath = 'assets/icons/yellow_i.png';
      break;
    case '3':
      color = Colors.red.shade50;
      iconPath = 'assets/icons/palm-red.png';
      break;
    case '4':
      color = Colors.red.shade500;
      iconPath = 'assets/icons/palm-white.png';
      break;
    default:
      color = Colors.grey.shade200; // opsional
  }


  if (pohon.nflag == '1') {
    iconPath = 'assets/icons/normal.png';
  }

  const double buttonSize = 90;
  final double iconSize = buttonSize * 0.8;

  return GestureDetector(
    onTap: () => showPopup(context, pohon, assignment),
    child: Column(
      children: [
        Container(
          margin: const EdgeInsets.all(4),
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.green.shade400, width: 3),
          ),
          child: Center(child: cfgImageAsset(iconPath, iconSize, iconSize),),
        ),
        const SizedBox(height: 4),
        resText(TextAlign.left, labelPohon, 18, FontStyle.normal, true, Colors.black),
      ],
    ),
  );
}

/// POHON KOSONG: X di tengah, label "-" di bawah
Widget _buildEmptyTree() {
  return Column(
    children: [
      Container(
        margin: const EdgeInsets.all(4),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 3),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: ResText('X', 40, FontStyle.normal, false, Colors.grey),
      ),
      const SizedBox(height: 4),
      ResText('-', 18, FontStyle.normal, true, Colors.black)
    ],
  );
}