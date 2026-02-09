import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiSync {

  static const String baseUrl = "http://13.67.47.76/bbn/kebun";

  Future<dynamic> postJson({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        //print('Error: ${response.statusCode}');
        //print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      //print('Exception: $e');
      return null;
    }
  }

  Future<dynamic> postBatchJson({
    required List<Map<String, dynamic>> dataList,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(dataList), // <== kirim list JSON
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        //print("❌ Server error: ${response.statusCode}");
        //print("Message: ${response.body}");
        return null;
      }
    } catch (e) {
      //print("❌ Error sending request: $e");
      return null;
    }
  }

  Future<dynamic> postJsonViaUrl({
    required List<Map<String, dynamic>> jsonArray,
  }) async {
    try {
      // 1) Encode JSON array
      final encodedJson = jsonEncode(jsonArray);

      // 2) Encode ke URL
      final String fullUrl = "$baseUrl/wfs.jsp?j=${Uri.encodeComponent(encodedJson)}";

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        //print("❌ Server error: ${response.statusCode}");
        //print("Response: ${response.body}");
        return null;
      }
    } catch (e) {
      //print("❌ Exception: $e");
      return null;
    }
  }

}
