// main.dart
import 'package:flutter/material.dart';
import 'package:kebun_sawit/screens/scr_menu.dart';
import 'package:kebun_sawit/screens/scr_option_acts.dart';
import 'package:kebun_sawit/screens/sync_download_screen.dart';
import 'plantdb/db_helper.dart';
import 'screens/scr_assignment_content.dart';
import 'screens/scr_assignment_list.dart';
import 'screens/scr_execution_form.dart';
import 'screens/scr_initial_sync.dart';
import 'screens/scr_login.dart';
import 'screens/scr_plant_health.dart';
import 'screens/scr_plant_reposition.dart';
import 'screens/scr_sync_action.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper().inisiasiDB();
  runApp(const SRPlantation());
}

class SRPlantation extends StatelessWidget {
  const SRPlantation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Perkebunan',
      theme: ThemeData(
        primarySwatch: Colors.green, // Tema utama hijau
        fontFamily: 'Roboto',
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), // Halaman awal : Login
        '/initSync': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          final username = args?['username'] as String?;
          final blok = args?['blok'] as String?;
          return InitialSyncPage(username: username.toString(), blok: blok.toString());
        },
        '/assignments': (context) => const AssignmentListScreen(),
        '/kesehatan': (context) => const PlantHealthScreen(),
        '/reposisi': (context) => const PlantRepositionScreen(),
        //'/sqlite': (context) => const SqliteTestScreen(),
        '/syncPage': (context) => const SyncPage(),
        '/goDetail': (context) => const AssignmentContent(),
        '/isiTugas': (context) => const AssignmentExecutionFormScreen(),
        '/menu': (context) => const MenuScreen(),
        '/optAct': (context) => const OptionActScreen(),
        '/downloadPage': (context) => const SyncDownloadScreen(),
      },
    );
  }
}
