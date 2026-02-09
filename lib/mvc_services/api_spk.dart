import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiSPK {
  //static const String baseUrlX = "https://aaa.com/auth";
  static const String baseUrl = "http://13.67.47.76/bbn";

  static Future<Map<String, dynamic>> getTask(String username) async {
    // Bentuk URL
    final url = Uri.parse("$baseUrl/wfs.jsp?r=apk.task&q=$username");
//print(url);
    try {
      final response = await http.get(url);
//print(response.body);
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
//print(data);
          // Jika berhasil parsing dan berupa list dengan isi → login sukses
          if (data is List && data.isNotEmpty) {
            return {
              "success": true,
              "data": data,
            };
          } else {
            return {
              "success": false,
              "message": "Task tidak ditemukan",
            };
          }
        } catch (e) {
          // Jika gagal decode JSON → kemungkinan error server seperti "index out of range -1"
          return {
            "success": false,
            "message": "Task tidak ditemukan",
          };
        }
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Tidak dapat terhubung ke server",
      };
    }
  }
}
