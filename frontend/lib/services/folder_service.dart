import 'dart:convert';
import 'package:frontend/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FolderService {
  static Future<Map<String, dynamic>> getRootContents() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/folders/root"),
      headers: {"Authorization": "Bearer $token"},
    );
    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> getFolderContents(int folderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/folders/contents/$folderId"),
      headers: {"Authorization": "Bearer $token"},
    );
    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> createFolder({
    required String name,
    int? parentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final response = await http.post(
      Uri.parse("${Api.baseUrl}/folders"),

      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },

      body: jsonEncode({"name": name, "parent_id": parentId}),
    );
    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> deleteFolder(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.delete(
        Uri.parse("${Api.baseUrl}/folders/$id"),
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

  static Future<Map<String, dynamic>> renameFolder({
    required int id,
    required String name,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.put(
        Uri.parse("${Api.baseUrl}/folders/$id"),

        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },

        body: jsonEncode({"name": name}),
      );

      return {"status": response.statusCode, "data": jsonDecode(response.body)};
    } catch (e) {
      return {
        "status": 500,
        "data": {"message": e.toString()},
      };
    }
  }
}
