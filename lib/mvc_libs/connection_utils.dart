import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionUtils {
  String? tableName;

  static Future<bool> checkConnection() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      return false;
    }

    // Lanjutkan cek apakah internet benar-benar bisa diakses
    try {
      final ping = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      return ping.isNotEmpty && ping[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false; // Ada jaringan tapi tidak bisa akses internet
    }

    //return false;
  }

  String parseSqlError(String message) {
    // 1. Ambil duplicate key value

    //final duplicateKeyRegex = RegExp(r'The duplicate key value is \((.*?)\)');
    //final duplicateMatch = duplicateKeyRegex.firstMatch(message);
    //final duplicateValue = duplicateMatch?.group(1);

    // 2. Ambil error code
    final errorCodeRegex = RegExp(r'Error Code:\s*(\d+)');
    final codeMatch = errorCodeRegex.firstMatch(message);
    final errnoRegex = RegExp(r'errno\s*=\s*(\d+)');
    final errnoMatch = errnoRegex.firstMatch(message);
    final errorCode = codeMatch?.group(1) ?? errnoMatch?.group(1);

    // 3. Ambil nama tabel
    final tableRegex = RegExp(r'INSERT INTO\s+([A-Za-z0-9_.]+)');
    final tableMatch = tableRegex.firstMatch(message);
    //final tableName = tableMatch != null ? tableMatch.group(1) : null;
    final fullTableName = tableMatch?.group(1);

    // Ambil hanya nama tabel setelah titik terakhir


    if (fullTableName != null) {
      final shortTableRegex = RegExp(r'\.([A-Za-z0-9_]+)$');
      final shortTableMatch = shortTableRegex.firstMatch(fullTableName);
      tableName = shortTableMatch?.group(1);
    }


    if(errorCode != null) {
      //return "[$tableName, id:$duplicateValue, error code:$errorCode]";
      String infoPart = ConnectionUtils().handleErrorStatus(
          errorCode.toString());
      return
        "[UPS...ERROR:$errorCode!]\n$infoPart";
    }else {
      return message; // Kembalikan pesan asli jika tidak ada yang ditemukan
    }
  }

  String handleErrorStatus(String errorCode) {
    int statusCode = int.tryParse(errorCode) ?? 0;
    switch (statusCode) {
      case 200:
        return "Berhasil diproses.";
      case 201:
        return "Data berhasil dibuat.";
      case 202:
        return "Permintaan sedang diproses.";
      case 204:
        return "Tidak ada data.";
      case 400:
        return "Permintaan tidak valid.";
      case 401:
        return "Silakan login kembali.";
      case 403:
        return "Akses ditolak.";
      case 404:
        return "Data tidak ditemukan.";
      case 408:
        return "Koneksi timeout.";
      case 110:
        return "Koneksi terputus.";
      case 103:
        return "Koneksi terputus.";
      case 409:
        return "Data bentrok / duplikat.";
      case 413:
        return "Ukuran data terlalu besar.";
      case 415:
        return "Tipe file tidak didukung.";
      case 422:
        return "Validasi gagal.";
      case 429:
        return "Terlalu banyak permintaan. Coba beberapa saat lagi.";
      case 500:
        return "Terjadi kesalahan di server.";
      case 502:
        return "Server bermasalah.";
      case 503:
        return "Server sedang sibuk.";
      case 504:
        return "Gateway timeout.";
      default:
        return "Ada gangguan pada server";
    }
  }
}
