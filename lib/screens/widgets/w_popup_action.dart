// screens/widgets/w_popup_action.dart
import 'package:flutter/material.dart';
import 'w_general.dart';
import '../../mvc_models/assignment.dart';
import '../../mvc_models/pohon.dart';

/// Tampilkan dialog popup aksi.
void showPopup(BuildContext context, Pohon pohon, Assignment assignment) {
  showDialog(
    context: context,
    builder: (_) => _buildPopupDialog(context, pohon, assignment), // Ganti nama fungsi di sini
  );
}

/// ⚙️ Widget Dialog Popup Aksi Pohon (Memisahkan dari popupDialog)
AlertDialog _buildPopupDialog(BuildContext context, Pohon pohon, Assignment assignment) {
  //int healthTypeSelected = 0;
  int healthTypeSelected = int.parse(pohon.status) - 1;
  int treeTypeSelected = 0; // 0: Utama, 1: Sisip
  return AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Column(
      children: [
        _buildPopupTitle(pohon), // Dipisah
        const SizedBox(height: 12),
        // KEMBALIKAN LOGIKA STATEFUL BUILDER DI SINI:
        StatefulBuilder(builder: (context, setState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(colorOptions.length, (index) {
              final item = colorOptions[index];
              final bool isSelected = healthTypeSelected == index;

              return GestureDetector(
                onTap: () => setState(() => healthTypeSelected = index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: item['color'],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                          width: isSelected ? 3 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(1, 2),
                          )
                        ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.black, size: 30)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    resText(TextAlign.left, item['label'], 20.0, FontStyle.normal, isSelected, Colors.black),
                  ],
                ),
              );
            }),
          );
        }),

        const SizedBox(height: 12),
        // LOGIKA STATEFUL Pohon Utama / Sisip DI SINI:
        StatefulBuilder(builder: (context, setState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(primaryTree.length, (index) {
              final item = primaryTree[index];
              final bool isSelected = treeTypeSelected == index;

              return GestureDetector(
                onTap: () => setState(() => treeTypeSelected = index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: item['color'],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                          width: isSelected ? 3 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(1, 2),
                          )
                        ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.black, size: 30)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    resText(TextAlign.left, item['label'], 20.0, FontStyle.normal, isSelected, Colors.black),
                  ],
                ),
              );
            }),
          );
        }),
      ],
    ),
    content: _buildPopupContent(context, assignment), // Dipisah
  );
}

/// 📝 Bagian Judul Popup Dialog
Widget _buildPopupTitle(Pohon pohon) {
  int a = int.parse(pohon.status) - 1;
  return Column(
    children: [
      ResText(
          'Pohon ${pohon.npohon} / Baris ${pohon.nbaris}',
          25.0, FontStyle.normal, true, Colors.green.shade900
      ),
      ResText(
          'Status: ${a.toString()} / OBJECTID: ${pohon.objectId}',
          15.0, FontStyle.normal, true, Colors.green.shade900
      ),
    ],
  );
}

/// 📃 Bagian Konten Aksi (list prop A, B, C) di Popup Dialog
SingleChildScrollView _buildPopupContent(BuildContext context, Assignment assignment) {
  return SingleChildScrollView(
    child: Column(
      children: [
        const SizedBox(height: 10),
        // Asumsi resWrapConfig adalah fungsi global
        cfgWrap(WrapAlignment.center, buildListPropA(context, assignment)),
        const SizedBox(height: 10),
        cfgWrap(WrapAlignment.center, buildListPropC(context, assignment)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cfgElevatedButton(
              Colors.blueAccent.shade700, Colors.black, 0, 0, 5.0,
              cfgPadding(24.0, 8.0, resText(TextAlign.left, 'Simpan', 16, FontStyle.normal, true, Colors.white),),
              cfgNavigator(context: context, action: 'pop'),
            ),
            const SizedBox(width: 20),
            cfgElevatedButton(
              Colors.green.shade800, Colors.black, 0, 0, 5.0,
              cfgPadding(24.0, 8.0, resText(TextAlign.left, 'Batal', 16, FontStyle.normal, true, Colors.white),),
              cfgNavigator(context: context, action: 'pop'),
            ),
          ]
        ),

      ],
    ),
  );
}

// NOTE: colorOptions tetap di luar kelas karena merupakan data statis
List<Map<String, dynamic>> colorOptions = [
  {'label': 'G0', 'color': const Color(0xFF5C8037)},
  {'label': 'G1', 'color': Colors.yellow},
  {'label': 'G2', 'color': Colors.orange},
  {'label': 'G3', 'color': Colors.red.shade500},
  {'label': 'G4', 'color': Colors.red.shade900},
];

// NOTE: Pembeda warna untuk Pohon Utama dan Sisip
List<Map<String, dynamic>> primaryTree = [
  {'label': 'Utama', 'color': Colors.blue.shade500},
  {'label': 'Sisip', 'color': Colors.purple.shade300},
];

final ValueNotifier<String> selectedKesehatan = ValueNotifier('G0');
// final List<Widget> listPropA=[
List<Widget> buildListPropA(BuildContext context, Assignment assignment) => [
  _buildTreeStatusButton(context, 'Tegak', 'assets/icons/normal.png', Colors.green, assignment),
  _buildTreeStatusButton(context, 'Miring Kanan', 'assets/icons/miring-kanan.png', Colors.blue, assignment),
  _buildTreeStatusButton(context, 'Miring Kiri', 'assets/icons/miring-kiri.png', Colors.purple, assignment),
];

//final List<Widget> listPropB=[
List<Widget> buildListPropB(BuildContext context, Assignment assignment) => [
  _buildTreeStatusButton(context, 'Terinfeksi\nGanoderma', 'assets/icons/infek-gano.png', Colors.red, assignment),
  _buildTreeStatusButton(context, 'Infek Gano\nKanan', 'assets/icons/infek-gano-kanan.png', Colors.red, assignment),
  _buildTreeStatusButton(context, 'Infek Gano\nKiri', 'assets/icons/infek-gano-kiri.png', Colors.red, assignment),
];

//final List<Widget> listPropC=[
List<Widget> buildListPropC(BuildContext context, Assignment assignment) => [
  //_buildTreeStatusButton(context, 'Ditebang', 'assets/icons/ditebang.png', Colors.brown, assignment),
  _buildTreeStatusButton(context, 'Kenthosan', 'assets/icons/kenthosan.png', Colors.orange, assignment),
  //_buildTreeStatusButton(context, 'Pohon Mati', 'assets/icons/pohon-mati.png', Colors.black54, assignment),
];

Widget _buildTreeStatusButton(
    BuildContext context, String label, String iconPath,
    Color borderColor, Assignment assignment) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      InkWell(
        onTap: () {
          // TODO: tambahkan aksi jika status dipilih
          Navigator.pop(context, assignment.fullLocation);
          debugPrint('Status pohon dipilih:  ${assignment.treeNumber}');
        },
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(
            child: Image.asset(
              iconPath,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      const SizedBox(height: 6),
      resText(TextAlign.left, label, 15.0, FontStyle.normal, true, Colors.black),
    ],
  );
}