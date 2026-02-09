import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../screens/widgets/w_general.dart';
import '../mvc_dao/dao_audit_log.dart';
import '../../screens/widgets/w_assigment_detail.dart';
import '../../mvc_models/assignment.dart';
import '../../mvc_models/execution.dart';
import '../../mvc_dao/dao_task_execution.dart';

class AssignmentExecutionFormScreen extends StatefulWidget {
  const AssignmentExecutionFormScreen({super.key});

  @override
  State<AssignmentExecutionFormScreen> createState() =>
      _AssignmentExecutionFormScreenState();
}

class _AssignmentExecutionFormScreenState
    extends State<AssignmentExecutionFormScreen> {
  final noteController = TextEditingController();
  String? imgPath;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final Assignment assignment = args['assignment'];
    final String taskState = args['taskState'];

    return Scaffold(
      appBar: cfgAppBar(
        "$taskState — ${assignment.taskName}",
        Colors.lightGreen.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerInfo(assignment, taskState),
            const SizedBox(height: 20),
            _stepTitle("1. Berikan catatan pekerjaan"),
            _inputNote(),
            const SizedBox(height: 20),
            _stepTitle("2. Unggah foto bukti"),
            _uploadImageButton(),
            //if (base64Image != null) _previewImage(),
            const SizedBox(height: 30),
            _saveButton(context, assignment, taskState),
          ],
        ),
      ),
    );
  }

  // ---------------- UI COMPONENTS ----------------

  Widget _headerInfo(Assignment a, String state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          resConfigRow("Status", state, Icons.flag),
          const SizedBox(height: 6),
          resConfigRow("Lokasi", a.location, Icons.location_on),
        ],
      ),
    );
  }

  Widget _stepTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
  );

  Widget _inputNote() {
    return TextField(
      controller: noteController,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
      ],
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Tulis keterangan pekerjaan...",
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _uploadImageButton() {
    return cfgElevatedButton(
      Colors.teal.shade700,
      Colors.black,
      0,
      0,
      5,
      cfgPadding(
        18,
        8,
        resText(
          TextAlign.center,
          "Pilih Foto",
          15,
          FontStyle.normal,
          true,
          Colors.white,
        ),
      ),
      null,
      /*
      () async {
        final result = await pickImageFromGallery();

        if (result["success"]) {
          setState(() {
            //imagePath = result["imagePath"];
            imgPath = result["imagePath"];
            //base64Image = result["base64"];
          });
        } else {
          final status = await Permission.photos.request();
          if (!mounted) return;
          if (!status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Izin akses foto ditolak")),
            );
            return;
          }

          //ScaffoldMessenger.of(context).showSnackBar(
            //SnackBar(content: Text(result["message"])),
          //);
        }
      },
      */
    );
  }

  /*
  Widget _previewImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(imgPath!),
          height: 170,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
*/
  Widget _saveButton(
    BuildContext context,
    Assignment assignment,
    String taskState,
  ) {
    //final enabled =
    //noteController.text.isNotEmpty && imagePath != null && !isSaving;

    final enabled = noteController.text.isNotEmpty && !isSaving;

    return cfgElevatedButton(
      enabled ? Colors.green.shade900 : Colors.grey,
      Colors.black,
      0,
      0,
      6,
      cfgPadding(
        26,
        10,
        resText(
          TextAlign.center,
          isSaving ? "Menyimpan…" : "Simpan Status",
          16,
          FontStyle.normal,
          true,
          Colors.white,
        ),
      ),
      () {
        if (!enabled) return;
        _saveExecution(context, assignment, taskState);
      },
    );
  }

  // --------------- PILIH FOTO ---------------
  Future<Map<String, dynamic>> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();

    // Memilih foto dari galeri / folder
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: null, // kompres sedikit agar lebih ringan
    );

    // Jika user batal memilih foto
    if (pickedFile == null) {
      return {
        "success": false,
        "imagePath": "-",
        "base64": "-",
        "message": "Tidak ada foto dipilih",
      };
    }

    File imageFile = File(pickedFile.path);
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    return {
      "success": true,
      "imagePath": pickedFile.path,
      "base64": base64Image,
      "message": "Foto berhasil dipilih",
    };
  }

  // ----------------- IMAGE PICKER -----------------
  Future<Map<String, dynamic>> pickAndEncodeImage() async {
    final ImagePicker picker = ImagePicker();

    // Ambil foto dari kamera
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70, // kompres ukuran tanpa kurangi kualitas terlalu banyak
    );

    // Jika user batal mengambil foto
    if (pickedFile == null) {
      return {
        "success": false,
        "message": "Tidak ada foto dipilih",
        "imagePath": "-",
        "base64": "-",
      };
    }

    File imageFile = File(pickedFile.path);

    // Baca file sebagai bytes
    List<int> imageBytes = await imageFile.readAsBytes();

    // Encode ke Base64
    String base64Image = base64Encode(imageBytes);

    return {
      "success": true,
      "message": "Foto berhasil diambil",
      "imagePath": pickedFile.path,
      "base64": base64Image,
    };
  }

  // ---------------- DATABASE ----------------

  Future<void> _saveExecution(
    BuildContext context,
    Assignment assignment,
    String taskState,
  ) async {
    setState(() => isSaving = true);
    final uuid = Uuid().v4();
    final taskExec = TaskExecution(
      id: uuid.toUpperCase(),
      spkNumber: assignment.spkNumber,
      taskName: assignment.taskName,
      petugas: assignment.petugas,
      taskDate: DateTime.now().toIso8601String(),
      taskState: taskState,
      keterangan: noteController.text,
      imagePath: imgPath ?? "-",
      flag: 0,
    );

    final hasil = await TaskExecutionDao().insertTaskExec(taskExec);

    if (!context.mounted) return;
    setState(() => isSaving = false);

    if (hasil > 0) {
      await AuditLogDao().createLog(
        "INSERT_TASK",
        "Status $taskState berhasil disimpan",
      );
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status $taskState berhasil disimpan")),
      );
    } else {
      await AuditLogDao().createLog(
        "INSERT_TASK",
        "Status $taskState gagal disimpan",
      );
    }
  }
}
