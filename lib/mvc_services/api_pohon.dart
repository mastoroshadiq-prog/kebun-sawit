import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiPohon {
  //static const String baseUrlX = "https://aaa.com/auth";
  static const String baseUrl = "http://13.67.47.76/bbn";

  static Future<Map<String, dynamic>> getSpkPohon(String username) async {
    // Bentuk URL
    //final url = Uri.parse("$baseUrl/wfs.jsp?r=spk.pohon&q=$username");
    Uri url;
    if(username=="simulasi") {
      url = Uri.parse("$baseUrl/wfs.jsp?r=sim.pohon&q=$username");
    }else {
      url = Uri.parse("$baseUrl/wfs.jsp?r=blok.pohon&q=$username");
    }

    try {
      final response = await http.get(url);
      //print('pohon:$data');
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          //print('pohon: ${response.body}');
          // Jika berhasil parsing dan berupa list dengan isi → login sukses
          if (data is List && data.isNotEmpty) {
            return {
              "success": true,
              "data": data,
            };
          } else {
            return {
              "success": false,
              "message": "Data Pohon tidak ditemukan",
            };
          }
        } catch (e) {
          // Jika gagal decode JSON → kemungkinan error server seperti "index out of range -1"
          return {
            "success": false,
            "message": "Data Pohon tidak ditemukan",
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
