// sync_download_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ===========================
/// 1) DEFINISI STEP DATASET
/// ===========================
enum DownloadStep {
  assignments,
  plants,
  plantHealthHistory,
  standPerRow,
}

extension DownloadStepX on DownloadStep {
  String get label {
    switch (this) {
      case DownloadStep.assignments:
        return 'Data Tugas / Assignment';
      case DownloadStep.plants:
        return 'Data Tanaman';
      case DownloadStep.plantHealthHistory:
        return 'Riwayat Kesehatan Tanaman';
      case DownloadStep.standPerRow:
        return 'Data Stand Per Row';
    }
  }

  String get key => name;
}

class StepState {
  StepState({
    required this.step,
    this.count = 0,
    this.done = false,
    this.running = false,
    this.errorMessage,
  });

  final DownloadStep step;
  int count;
  bool done;
  bool running;
  String? errorMessage;
}

/// ===========================
/// 2) CHECKPOINT STORAGE
/// ===========================
class SyncCheckpointStore {
  static const _kLastFailedStep = 'sync_last_failed_step';
  static const _kLastCompletedStep = 'sync_last_completed_step';

  Future<void> saveCompleted(DownloadStep step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastCompletedStep, step.key);
    // kalau sukses, failure step dihapus
    await prefs.remove(_kLastFailedStep);
  }

  Future<void> saveFailed(DownloadStep step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastFailedStep, step.key);
  }

  Future<DownloadStep?> loadLastFailed() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kLastFailedStep);
    if (v == null) return null;
    return DownloadStep.values.firstWhere((e) => e.key == v, orElse: () => DownloadStep.assignments);
  }

  Future<DownloadStep?> loadLastCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kLastCompletedStep);
    if (v == null) return null;
    return DownloadStep.values.firstWhere((e) => e.key == v, orElse: () => DownloadStep.assignments);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastFailedStep);
    await prefs.remove(_kLastCompletedStep);
  }
}

/// ===========================
/// 3) SERVICE PLACEHOLDER
///    Ganti sesuai API kamu
/// ===========================
class ApiClient {
  // Contoh: download assignments
  Future<List<Map<String, dynamic>>> fetchAssignments() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.generate(7, (i) => {'id': i + 1});
  }

  Future<List<Map<String, dynamic>>> fetchPlants() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return List.generate(12, (i) => {'id': i + 100});
  }

  Future<List<Map<String, dynamic>>> fetchPlantHealthHistory() async {
    await Future.delayed(const Duration(milliseconds: 650));
    return List.generate(5, (i) => {'id': i + 200});
  }

  Future<List<Map<String, dynamic>>> fetchStandPerRow() async {
    await Future.delayed(const Duration(milliseconds: 650));
    return List.generate(20, (i) => {'id': i + 300});
  }
}

/// ===========================
/// 4) LOCAL STORE PLACEHOLDER
///    Ganti sesuai DB lokal
/// ===========================
class LocalStore {
  Future<void> resetAll() async {
    // TODO: clear SQLite/Hive/Drift box, dll
    await Future.delayed(const Duration(milliseconds: 250));
  }

  Future<void> upsertAssignments(List<Map<String, dynamic>> rows) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> upsertPlants(List<Map<String, dynamic>> rows) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> upsertPlantHealthHistory(List<Map<String, dynamic>> rows) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> upsertStandPerRow(List<Map<String, dynamic>> rows) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

/// ===========================
/// 5) CONTROLLER (STATEFUL)
/// ===========================
class SyncDownloadController {
  SyncDownloadController({
    required this.api,
    required this.store,
    required this.checkpoint,
  });

  final ApiClient api;
  final LocalStore store;
  final SyncCheckpointStore checkpoint;

  bool isRunning = false;
  double progress = 0.0; // 0..1
  String statusText = '-';

  final List<StepState> steps = DownloadStep.values
      .map((s) => StepState(step: s))
      .toList();

  int _doneCount() => steps.where((e) => e.done).length;

  void _resetStepVisuals() {
    for (final s in steps) {
      s.running = false;
      s.errorMessage = null;
      s.count = 0;
      s.done = false;
    }
    progress = 0;
    statusText = '-';
  }

  Future<DownloadStep?> getLastFailedStep() => checkpoint.loadLastFailed();

  /// Reset data lokal + checkpoint
  Future<void> resetAll() async {
    await store.resetAll();
    await checkpoint.clear();
    _resetStepVisuals();
  }

  /// Mulai download dari awal (atau dari step tertentu)
  Future<void> run({
    DownloadStep? startFrom,
    required void Function() onTick,
  }) async {
    if (isRunning) return;
    isRunning = true;
    statusText = 'Mengumpulkan data...';
    onTick();

    try {
      final startIndex = startFrom == null
          ? 0
          : DownloadStep.values.indexOf(startFrom);

      // Kalau startFrom ditentukan, step sebelumnya dianggap "tidak disentuh".
      for (int i = 0; i < steps.length; i++) {
        if (i < startIndex) continue;
        steps[i].done = false;
        steps[i].count = 0;
        steps[i].errorMessage = null;
      }

      final total = steps.length - startIndex;
      int completedInThisRun = 0;

      for (int i = startIndex; i < steps.length; i++) {
        final st = steps[i];
        st.running = true;
        st.errorMessage = null;
        statusText = st.step.label;
        onTick();

        try {
          final count = await _downloadOne(st.step);
          st.count = count;
          st.done = true;

          await checkpoint.saveCompleted(st.step);

          st.running = false;
          completedInThisRun++;
          progress = total == 0 ? 1 : (completedInThisRun / total);
          statusText = 'Selesai: ${st.step.label}';
          onTick();
        } catch (e) {
          st.running = false;
          st.done = false;
          st.errorMessage = e.toString();

          await checkpoint.saveFailed(st.step);

          statusText = 'Gagal pada: ${st.step.label}';
          onTick();
          rethrow;
        }
      }

      statusText = 'Selesai. Total step sukses: ${_doneCount()}/${steps.length}';
      progress = 1.0;
      onTick();
    } finally {
      isRunning = false;
      onTick();
    }
  }

  Future<int> _downloadOne(DownloadStep step) async {
    switch (step) {
      case DownloadStep.assignments:
        final rows = await api.fetchAssignments();
        await store.upsertAssignments(rows);
        return rows.length;

      case DownloadStep.plants:
        final rows = await api.fetchPlants();
        await store.upsertPlants(rows);
        return rows.length;

      case DownloadStep.plantHealthHistory:
        final rows = await api.fetchPlantHealthHistory();
        await store.upsertPlantHealthHistory(rows);
        return rows.length;

      case DownloadStep.standPerRow:
        final rows = await api.fetchStandPerRow();
        await store.upsertStandPerRow(rows);
        return rows.length;
    }
  }
}

/// ===========================
/// 6) UI SCREEN
/// ===========================
class SyncDownloadScreen extends StatefulWidget {
  const SyncDownloadScreen({super.key});

  @override
  State<SyncDownloadScreen> createState() => _SyncDownloadScreenState();
}

class _SyncDownloadScreenState extends State<SyncDownloadScreen> {
  late final SyncDownloadController c;

  @override
  void initState() {
    super.initState();
    c = SyncDownloadController(
      api: ApiClient(),
      store: LocalStore(),
      checkpoint: SyncCheckpointStore(),
    );
  }

  Future<void> _startFromBeginning() async {
    try {
      await c.run(
        startFrom: DownloadStep.assignments,
        onTick: () => setState(() {}),
      );
    } catch (_) {
      // error sudah dipresentasikan di UI
    }
  }

  Future<void> _resumeFromFailure() async {
    final failed = await c.getLastFailedStep();
    if (!mounted) return;

    if (failed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada checkpoint kegagalan.')),
      );
      return;
    }

    try {
      await c.run(
        startFrom: failed,
        onTick: () => setState(() {}),
      );
    } catch (_) {}
  }

// ignore: unused_element
  Future<void> _chooseResumePoint() async {
    final failed = await c.getLastFailedStep();
    if (!mounted) return;

    final selected = await showDialog<DownloadStep>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Mulai ulang dari step mana?'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: DownloadStep.values.map((s) {
                final subtitle = (failed == s)
                    ? 'Checkpoint gagal terakhir'
                    : null;
                return ListTile(
                  title: Text(s.label),
                  subtitle: subtitle == null ? null : Text(subtitle),
                  onTap: () => Navigator.pop(ctx, s),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selected == null) return;

    try {
      await c.run(startFrom: selected, onTick: () => setState(() {}));
    } catch (_) {}
  }

  Future<void> _resetAll() async {
    if (c.isRunning) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Data Lokal'),
        content: const Text(
          'Ini akan menghapus seluruh data lokal dan checkpoint sinkronisasi. Lanjut?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
        ],
      ),
    );

    if (ok != true) return;

    await c.resetAll();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data lokal dan checkpoint sudah di-reset.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema Hijau Gelap
    const forestGreen = Color(0xFF1B4332); // Warna background hijau gelap
    const limeGreen = Color(0xFFB7E219);  // Warna progress lime/neon
    const glassOverlay = Color(0xFF2D4F3F); // Warna card (hijau gelap sedikit terang)

    return Scaffold(
      backgroundColor: forestGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Inisiasi Data'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            // Kontainer Utama (Card Transparan seperti di Gambar)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: glassOverlay.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  /*
                  const Text(
                    'Sinkronisasi Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  */
                  Text(
                    'Menyiapkan data awal untuk aktivitas lapangan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Progress Bar Lime
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: c.progress,
                      minHeight: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(limeGreen),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Teks Status (Merah jika gagal, Putih jika proses)
                  Text(
                    c.statusText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: c.statusText.contains('Gagal')
                          ? Colors.redAccent
                          : Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    'Jangan tutup aplikasi selama proses berlangsung',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Daftar Batch (Tetap ada namun disesuaikan warnanya)
            ...c.steps.map((s) => _StepRow(s),),

            const SizedBox(height: 30),

            // Action Buttons
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: limeGreen,
                foregroundColor: forestGreen,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: c.isRunning ? null : _startFromBeginning,
              child: Text(c.isRunning ? 'MEMPROSES...' : 'AMBIL DATA BARU',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: c.isRunning ? null : _resetAll,
                    child: const Text('RESET'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: limeGreen,
                      side: const BorderSide(color: limeGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: c.isRunning ? null : _resumeFromFailure,
                    child: const Text('LANJUTKAN'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({
    required this.text,
    required this.isDone,
    required this.isRunning,
    required this.primaryColor,
  });

  final String text;
  final bool isDone;
  final bool isRunning;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    Color iconColor = isDone ? const Color(0xFF2E7D32) : (isRunning ? primaryColor : const Color(0xFF546E7A));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : (isRunning ? Icons.sync : Icons.info), color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow(this.state);
  final StepState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            state.done ? Icons.check_circle : (state.errorMessage != null ? Icons.error : Icons.circle_outlined),
            color: state.done ? const Color(0xFFB7E219) : (state.errorMessage != null ? Colors.redAccent : Colors.white24),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.step.label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
            ),
          ),
          if (state.running)
            const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB7E219))),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _HintBox extends StatelessWidget {
  const _HintBox({required this.controller, required this.textColor});
  final SyncDownloadController controller;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Catatan:\n'
            '- Tombol LANJUTKAN akan melanjutkan dari step terakhir yang gagal.\n'
            '- Tombol "Mulai ulang" memungkinkan memilih titik awal spesifik.\n'
            '- RESET DATA menghapus seluruh cache dan checkpoint.',
        style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.8), height: 1.4),
      ),
    );
  }
}
