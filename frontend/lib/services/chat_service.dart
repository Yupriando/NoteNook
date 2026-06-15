import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api.dart';

class ChatService {
  static Future<Map<String, dynamic>> getMessages(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/chat/messages/$userId"),

        headers: {"Authorization": "Bearer $token"},
      );

      return {"status": response.statusCode, "data": jsonDecode(response.body)};
    } catch (e) {
      return {
        "status": 500,

        "data": {"message": e.toString()},
      };
    }
  }

  static Future<Map<String, dynamic>> sendMessage({
    required int receiverId,
    required String message,
    List<File> files = const [],
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("${Api.baseUrl}/chat/send"),
      );

      request.headers["Authorization"] = "Bearer $token";
      request.fields["receiver_id"] = receiverId.toString();
      request.fields["message"] = message;

      for (var file in files) {
        request.files.add(
          await http.MultipartFile.fromPath("files", file.path),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      print(body);

      return {"status": response.statusCode, "data": jsonDecode(body)};
    } catch (e) {
      print(e);

      return {
        "status": 500,
        "data": {"message": e.toString()},
      };
    }
  }

  static Future<Map<String, dynamic>> getConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/chat"),

        headers: {"Authorization": "Bearer $token"},
      );

      return {"status": response.statusCode, "data": jsonDecode(response.body)};
    } catch (e) {
      return {
        "status": 500,
        "data": {"message": e.toString()},
      };
    }
  }

  static Future markRead(int senderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.put(
        Uri.parse("${Api.baseUrl}/chat/read/$senderId"),
        headers: {"Authorization": "Bearer $token"},
      );

      return {"status": response.statusCode};
    } catch (e) {
      return {"status": 500};
    }
  }
}
