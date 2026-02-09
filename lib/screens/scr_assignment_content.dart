// screens/assignment_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../screens/widgets/w_general.dart';
import '../../screens/widgets/w_assigment_detail.dart';
import '../../mvc_dao/dao_task_execution.dart';
import '../../mvc_models/execution.dart';
import '../../mvc_models/assignment.dart';
import '../mvc_dao/dao_petugas.dart';
import '../mvc_models/petugas.dart';

class AssignmentContent extends StatefulWidget {
  const AssignmentContent({super.key});
  @override
  State<AssignmentContent> createState() => _AssignmentContentState();
}

class _AssignmentContentState extends State<AssignmentContent> {
  String? selectedAction; // SELESAI / TERTUNDA / DELEGASI
  final TextEditingController noteController = TextEditingController();
  XFile? pickedImage;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    // Ambil data assignment yang dilewatkan
    final assignment = ModalRoute.of(context)!.settings.arguments as Assignment;
    Future<Petugas?> petugas = PetugasDao().getByAkun(assignment.petugas);
    //final mapPetugas = ModalRoute.of(context)!.settings.arguments as Petugas;
    return Scaffold(
      appBar: cfgAppBar(assignment.taskName, Colors.lightGreen.shade900),
      body: resDetailScreenConfig(
        context,
        listDetail(assignment),
        listLokasi(context, assignment),
        //assignment,
        petugas
      ),
    );
  }

  List<Widget> listDetail(Assignment assignment) {
    return [
      resConfigRow('No :', assignment.spkNumber, Icons.confirmation_number),
      resConfigRow('Tugas', assignment.taskName, Icons.work),
      resConfigRow('Estate', assignment.estate, Icons.forest),
      resConfigRow('Divisi', assignment.division, Icons.groups),
      resConfigRow('Blok', assignment.block, Icons.grid_on),
      resConfigRow(
        'Baris/Pohon',
        '${assignment.rowNumber} / ${assignment.treeNumber}',
        Icons.scatter_plot,
      ),
      const SizedBox(height: 10),
      const Divider(color: Color(0xFF004D40)),
      const SizedBox(height: 10),
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
              20.0,
              8.0,
              resText(
                TextAlign.left,
                'Selesaikan',
                15,
                FontStyle.normal,
                true,
                Colors.white,
              ),
            ),
            () => Navigator.pushNamed(
              context,
              '/isiTugas',
              arguments: {'assignment': assignment, 'taskState': 'SELESAI'},
            ),
          ),
          const SizedBox(width: 8),
          cfgElevatedButton(
            Colors.green.shade800,
            Colors.black,
            0,
            0,
            5.0,
            cfgPadding(
              20.0,
              8.0,
              resText(
                TextAlign.left,
                'Tunda',
                15,
                FontStyle.normal,
                true,
                Colors.white,
              ),
            ),
            () => Navigator.pushNamed(
              context,
              '/isiTugas',
              arguments: {'assignment': assignment, 'taskState': 'TERTUNDA'},
            ),
          ),

          const SizedBox(height: 20),

          // -------- Form Dinamis --------
          if (selectedAction != null) buildFormInput(context, assignment),
        ],
      ),
    ];
  }

  List<Widget> listLokasi(BuildContext context, Assignment assignment) {
    return [];
  }

  Widget buildFormInput(BuildContext context, Assignment assignment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          resText(
            TextAlign.left,
            "Status: $selectedAction",
            15,
            FontStyle.normal,
            true,
            Colors.black,
          ),
          const SizedBox(height: 15),

          resText(
            TextAlign.left,
            "Catatan (wajib)",
            14,
            FontStyle.normal,
            true,
            Colors.black,
          ),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 15),

          resText(
            TextAlign.left,
            "Foto bukti (wajib)",
            14,
            FontStyle.normal,
            true,
            Colors.black,
          ),
          GestureDetector(
            onTap: () async {
              final f = await ImagePicker().pickImage(
                source: ImageSource.camera,
              );
              if (f != null) setState(() => pickedImage = f);
            },
            child: Container(
              height: 140,
              width: double.infinity,
              color: Colors.black12,
              child: pickedImage == null
                  ? const Center(child: Text("Klik untuk ambil foto"))
                  : Image.file(File(pickedImage!.path), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: cfgElevatedButton(
              Colors.green.shade900,
              Colors.black,
              0,
              0,
              5.0,
              cfgPadding(
                10,
                10,
                resText(
                  TextAlign.center,
                  "SIMPAN",
                  15,
                  FontStyle.normal,
                  true,
                  Colors.white,
                ),
              ),
              () {
                if (noteController.text.isNotEmpty &&
                    pickedImage != null &&
                    !isSaving) {
                  saveExecution(context, assignment);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveExecution(
    BuildContext context,
    Assignment assignment,
  ) async {
    final uuid = Uuid().v4();
    setState(() => isSaving = true);
    final taskExec = TaskExecution(
      id: uuid.toUpperCase(), // ID akan di-generate otomatis
      spkNumber: assignment.spkNumber,
      taskName: assignment.taskName,
      petugas: assignment.petugas, // Isi dengan nama petugas
      taskDate: DateTime.now().toIso8601String(), // Tanggal saat ini
      taskState: selectedAction!, // Isi dengan status tugas yang diteruskan
      flag: 0,
      keterangan: noteController.text,
      imagePath: pickedImage!.path,
    );

    final hasil = await TaskExecutionDao().insertTaskExec(taskExec);

    if (!context.mounted) return;

    setState(() => isSaving = false);

    if (hasil > 0) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Status tugas berhasil disimpan")),
      );
    }
  }
}
