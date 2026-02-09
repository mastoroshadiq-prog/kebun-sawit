// screens/widgets/w_popup_action.dart
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../../mvc_dao/dao_audit_log.dart';
import 'w_general.dart';
import '../../mvc_dao/dao_kesehatan.dart';
import '../../mvc_models/kesehatan.dart';
import '../../mvc_models/assignment.dart';
import '../../mvc_models/pohon.dart';

/// Tampilkan dialog popup aksi.
void showPopup(BuildContext context, Pohon pohon, Assignment assignment) {
  showDialog(
    context: context,
    builder: (_) => _buildPopupDialog(
      context,
      pohon,
      assignment,
    ), // Ganti nama fungsi di sini
  );
}

/// ⚙️ Widget Dialog Popup Aksi Pohon (Memisahkan dari popupDialog)
AlertDialog _buildPopupDialog(
  BuildContext context,
  Pohon pohon,
  Assignment assignment,
) {
  //int healthTypeSelected = 0;
  int healthTypeSelected = int.parse(pohon.status);
  int treeTypeSelected = 0; // 0: Utama, 1: Sisip
  return AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Column(
      children: [
        _buildPopupTitle(pohon), // Dipisah
        const SizedBox(height: 12),
        // KEMBALIKAN LOGIKA STATEFUL BUILDER DI SINI:
        StatefulBuilder(
          builder: (context, setState) {
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
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade300,
                            width: isSelected ? 3 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: const Offset(1, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 30,
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      resText(
                        TextAlign.left,
                        item['label'],
                        20.0,
                        FontStyle.normal,
                        isSelected,
                        Colors.black,
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        ),

        const SizedBox(height: 12),
        // LOGIKA STATEFUL Pohon Utama / Sisip DI SINI:
        StatefulBuilder(
          builder: (context, setState) {
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
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade300,
                            width: isSelected ? 3 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: const Offset(1, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.black,
                                size: 30,
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      resText(
                        TextAlign.left,
                        item['label'],
                        20.0,
                        FontStyle.normal,
                        isSelected,
                        Colors.black,
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        ),

        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cfgElevatedButton(
              Colors.blueAccent.shade700,
              Colors.black,
              0,
              0,
              5.0,
              cfgPadding(
                24.0,
                8.0,
                resText(
                  TextAlign.left,
                  'Simpan',
                  16,
                  FontStyle.normal,
                  true,
                  Colors.white,
                ),
              ),
              cfgNavigator(
                context: context,
                action: 'pop',
                customFunction: () => _syncPlantHealth(
                  pohon.objectId,
                  pohon.status,
                  healthTypeSelected.toString(),
                  '-',
                  assignment.petugas,
                  treeTypeSelected,
                ),
              ),
            ),
            const SizedBox(width: 20),
            cfgElevatedButton(
              Colors.green.shade800,
              Colors.black,
              0,
              0,
              5.0,
              cfgPadding(
                24.0,
                8.0,
                resText(
                  TextAlign.left,
                  'Batal',
                  16,
                  FontStyle.normal,
                  true,
                  Colors.white,
                ),
              ),
              cfgNavigator(context: context, action: 'pop'),
            ),
          ],
        ),
      ],
    ),
    //content: _buildPopupContent(context, assignment), // Dipisah
  );
}

_syncPlantHealth(
  String idTanaman,
  String statusAwal,
  String statusAkhir,
  String strKet,
  String strPetugas,
  int treeTypeSelected,
) async {
  final uuid = Uuid().v4();
  String jenisPohon = treeTypeSelected == 1 ? 'SISIP' : 'UTAMA';

  final health = Kesehatan(
    idKesehatan: uuid.toUpperCase(), // ID akan di-generate otomatis
    idTanaman: idTanaman, // Isi dengan ID pohon yang sesuai
    statusAwal: statusAwal, // Isi dengan status awal
    statusAkhir: statusAkhir, // Isi dengan status akhir
    kodeStatus: 'G$statusAkhir', // Isi dengan kode status (G0, G1, dll.)
    jenisPohon: jenisPohon, // Isi dengan jenis pohon (UTAMA/SISIP)
    keterangan: strKet, // Isi dengan keterangan jika ada
    petugas: strPetugas, // Isi dengan nama petugas
    fromDate: DateTime.now().toIso8601String(), // Tanggal saat ini
    flag: 0,
  );

  // Simpan data kesehatan ke database
  final hasil = await KesehatanDao().insertKesehatan(health);
  if (hasil > 0) {
    // insert berhasil
    await AuditLogDao().createLog(
      "INSERT_HEALTH",
      "Berhasil Mendata Kesehatan Pohon ID: $idTanaman-G$statusAkhir-$jenisPohon",
    );
    return true;
  } else {
    // insert gagal
    //print("Insert gagal");
    await AuditLogDao().createLog(
      "INSERT_HEALTH",
      "Berhasil Mendata Kesehatan Pohon ID: $idTanaman-G$statusAkhir-$jenisPohon",
    );
    return false;
  }
}

/// 📝 Bagian Judul Popup Dialog
Widget _buildPopupTitle(Pohon pohon) {
  int a = int.parse(pohon.status) - 1;
  return Column(
    children: [
      ResText(
        'Pohon ${pohon.npohon} / Baris ${pohon.nbaris}',
        25.0,
        FontStyle.normal,
        true,
        Colors.green.shade900,
      ),
      ResText(
        'Status: ${a.toString()} / OBJECTID: ${pohon.objectId}',
        15.0,
        FontStyle.normal,
        true,
        Colors.green.shade900,
      ),
    ],
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
