// screens/widgets/w_popup_action.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kebun_sawit/mvc_dao/dao_pohon.dart';
import '../../mvc_dao/dao_reposisi.dart';
import '../../mvc_models/reposisi.dart';
import 'package:uuid/uuid.dart';
import '../../mvc_dao/dao_audit_log.dart';
import '../scr_models/reposition_result.dart';
import 'w_general.dart';
import '../../mvc_models/pohon.dart';

Future<ReposisiResult?> showPopup(
  BuildContext context,
  Pohon pohon,
  String petugas,
  int pohonIndex, {
  bool? isVirtual,
}) {
  return showDialog<ReposisiResult>(
    context: context,
    builder: (dialogContext) => _buildPopupDialog(
      dialogContext,
      pohon,
      petugas,
      pohonIndex,
      isVirtual: isVirtual,
    ),
  );
}

/// ⚙️ Widget Dialog Popup Aksi Pohon (Memisahkan dari popupDialog)
AlertDialog _buildPopupDialog(
  BuildContext context,
  Pohon pohon,
  String petugas,
  int pohonIndex, {
  bool? isVirtual,
}) {
  return AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    // Atur batas tepi layar :
    insetPadding: const EdgeInsets.symmetric(horizontal: 40),
    title: Column(
      children: [
        _buildPopupTitle(
          pohon.npohon,
          pohon.nbaris,
          pohon.status,
          pohon.objectId,
        ), // Dipisah
        const SizedBox(height: 12),
      ],
    ),
    //content: _buildPopupContent(context, assignment),
    content: SizedBox(
      width: 350, // 🔥 lebar dialog diatur di sini
      child: _buildPopupContent(
        context,
        pohon,
        petugas,
        pohonIndex,
        isVirtual: isVirtual,
      ),
    ),
  );
}

/// 📝 Bagian Judul Popup Dialog
Widget _buildPopupTitle(
  String npohon,
  String nbaris,
  String pStatus,
  String objectId,
) {
  //int a = int.parse(pohon.status) - 1;
  int a = int.parse(pStatus) - 1;
  return Column(
    children: [
      ResText(
        'Pohon $npohon / Baris $nbaris',
        25.0,
        FontStyle.normal,
        true,
        Colors.green.shade900,
      ),
      ResText(
        'Status: ${a.toString()} / OBJECTID: $objectId',
        15.0,
        FontStyle.normal,
        true,
        Colors.green.shade900,
      ),
    ],
  );
}

/// 📃 Bagian Konten Aksi (list prop A, B, C) di Popup Dialog
SingleChildScrollView _buildPopupContent(
  BuildContext context,
  Pohon pohon,
  String petugas,
  int pohonIndex, {
  bool? isVirtual,
}) {
  String? selectedLabel;
  final options = _buildTreeStatusOptions(pohon, petugas, pohonIndex, isVirtual: isVirtual ?? false);

  return SingleChildScrollView(
    child: StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          const SizedBox(height: 10),
          cfgWrap(
            WrapAlignment.center,
            options
                .map(
                  (option) => _buildSelectableTreeStatusButton(
                    label: option.label,
                    iconPath: option.iconPath,
                    borderColor: option.borderColor,
                    isSelected: selectedLabel == option.label,
                    onTap: () => setState(() => selectedLabel = option.label),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          if (selectedLabel != null)
            Text(
              'Pilihan: $selectedLabel',
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 20),
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
                () async {
                  if (selectedLabel == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pilih status koreksi terlebih dahulu.'),
                      ),
                    );
                    return;
                  }

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Konfirmasi Simpan'),
                      content: Text('Yakin simpan perubahan "$selectedLabel"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Tidak'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Ya'),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) {
                    return;
                  }

                  final selected = options.firstWhere(
                    (option) => option.label == selectedLabel,
                  );

                  final result = await _syncPlantReposition(
                    pohon.blok,
                    pohonIndex,
                    selected.label,
                    pohon.objectId,
                    pohon.npohon,
                    pohon.nbaris,
                    petugas,
                    selected.isVirtual,
                  );

                  if (context.mounted) {
                    Navigator.pop(context, result);
                  }
                },
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
                () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

List<_TreeStatusOption> _buildTreeStatusOptions(
  Pohon pohon,
  String petugas,
  int pohonIndex, {
  required bool isVirtual,
}) {
  // parameter tetap dipertahankan untuk kompatibilitas signature pemanggilan
  // ignore: unused_local_variable
  final _ = (pohon, petugas, pohonIndex);

  return [
  _TreeStatusOption(
    label: 'MIRING\nKIRI',
    iconPath: 'assets/icons/miring-kiri.png',
    borderColor: Colors.purple,
    isVirtual: isVirtual,
  ),
  _TreeStatusOption(
    label: 'MIRING\nKANAN',
    iconPath: 'assets/icons/miring-kanan.png',
    borderColor: Colors.blue,
    isVirtual: isVirtual,
  ),
  _TreeStatusOption(
    label: 'TEGAK',
    iconPath: 'assets/icons/normal.png',
    borderColor: Colors.green,
    isVirtual: isVirtual,
  ),
  _TreeStatusOption(
    label: 'KOSONG',
    iconPath: 'assets/icons/ditebang.png',
    borderColor: Colors.brown,
    isVirtual: isVirtual,
  ),
  _TreeStatusOption(
    label: 'KENTHOS',
    iconPath: 'assets/icons/kenthosan.png',
    borderColor: Colors.orange,
    isVirtual: isVirtual,
  ),
  ];
}

Widget _buildSelectableTreeStatusButton({
  required String label,
  required String iconPath,
  required Color borderColor,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      InkWell(
        onTap: onTap,

        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(2),
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.green.shade700 : borderColor,
                  width: isSelected ? 4 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.green.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(child: cfgImageAsset(iconPath, 60, 60)),
            ),
            const SizedBox(height: 10),
            resText(
              TextAlign.center,
              label,
              18.0,
              FontStyle.normal,
              true,
              Colors.black,
            ),
          ],
        ),
      ),
    ],
  );
}

class _TreeStatusOption {
  const _TreeStatusOption({
    required this.label,
    required this.iconPath,
    required this.borderColor,
    required this.isVirtual,
  });

  final String label;
  final String iconPath;
  final Color borderColor;
  final bool isVirtual;
}

Future<ReposisiResult> _syncPlantReposition(
  String blok,
  int pohonIndex,
  String label,
  String idTanaman,
  String pohonAwal,
  String barisAwal,
  String strPetugas,
  bool isVirtual,
) async {
  String pohonTujuan =
      pohonAwal; // Untuk reposisi, pohon tujuan sama dengan pohon awal
  String barisTujuan = barisAwal; // Untuk reposisi, baris
  String strKet = 'Normal';
  String tipeRiwayat = 'N';
  String nFlag = '0';
  switch (label) {
    case 'TEGAK':
      //barisTujuan = (int.parse(barisAwal) - 1).toString();
      strKet = 'TEGAK';
      tipeRiwayat = 'N';
      nFlag = '0';
      break;
    case 'MIRING\nKANAN':
      barisTujuan = (int.parse(barisAwal) + 1).toString();
      strKet = 'MIRING KANAN';
      tipeRiwayat = 'R';
      nFlag = '1';
      break;
    case 'MIRING\nKIRI':
      barisTujuan = (int.parse(barisAwal) - 1).toString();
      strKet = 'MIRING KIRI';
      tipeRiwayat = 'L';
      nFlag = '2';
      break;
    case 'KENTHOS':
      strKet = 'KENTHOS';
      tipeRiwayat = 'K';
      nFlag = '3';
      break;
    case 'KOSONG':
      strKet = 'KOSONG';
      tipeRiwayat = 'C';
      nFlag = '4';
      break;
  }

  bool isHasil;
  final uuid = Uuid().v4();
  final reposisi = Reposisi(
    idReposisi: '${uuid.toUpperCase()}-$blok', // ID akan di-generate otomatis
    idTanaman: idTanaman, // Isi dengan ID pohon yang sesuai
    pohonAwal: pohonAwal, // Isi dengan pohon awal
    barisAwal: barisTujuan, // Isi dengan baris awal
    pohonTujuan: pohonTujuan, // Isi dengan pohon tujuan
    barisTujuan: barisAwal, // Isi dengan baris tujuan
    keterangan: strKet, // Isi dengan keterangan jika ada
    petugas: strPetugas, // Isi dengan nama petugas
    tipeRiwayat: tipeRiwayat,
    flag: 0,
    blok: blok,
  );

  // Simpan data kesehatan ke database
  final hasil = await ReposisiDao().insertReposisi(reposisi);
  if (hasil > 0) {
    // insert berhasil
    await AuditLogDao().createLog(
      "INSERT_REPOSISI",
      "Berhasil Melakukan Reposisi Pohon ID: $idTanaman-$strKet",
    );

    if (isVirtual) {
      if (['0', '3', '4'].contains(nFlag)) {
        final pohon = Pohon(
          blok: blok,
          nbaris: barisTujuan,
          npohon: pohonAwal,
          objectId: idTanaman,
          status: "1",
          nflag: nFlag,
        );
        await PohonDao().insertPohon(pohon);
      } else {
        await PohonDao().updateStatusPohon(
          barisTujuan,
          nFlag,
          pohonAwal,
          barisAwal,
        );
      }
    } else if (!isVirtual) {
      await PohonDao().updateStatusPohon(
        barisTujuan,
        nFlag,
        pohonAwal,
        barisAwal,
      );
    }
    //print("Berhasil : Tutup Pop UP");
    isHasil = true;
  } else {
    // insert gagal
    //print("Insert gagal");
    await AuditLogDao().createLog(
      "INSERT_REPOSISI",
      "Gagal Melakukan Reposisi Pohon ID: $idTanaman-$strKet",
    );
    //print("Gagal : Tutup Pop UP");
    isHasil = false;
  }
  return ReposisiResult(
    idTanaman: idTanaman,
    message: '',
    flag: nFlag,
    barisAwal: barisAwal,
    pohonAwal: pohonAwal,
    success: isHasil,
    pohonIndex: pohonIndex,
  );
}
