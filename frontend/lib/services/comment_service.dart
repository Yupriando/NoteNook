import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api.dart';

class CommentService {
  static Future<Map<String, dynamic>> getComments(int noteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/comments/$noteId"),
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

  static Future<Map<String, dynamic>> createComment({
    required int noteId,
    required String comment,

    int? parentId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/comments"),

        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },

        body: jsonEncode({
          "note_id": noteId,
          "comment": comment,
          "parent_id": parentId,
        }),
      );

      return {"status": response.statusCode, "data": jsonDecode(response.body)};
    } catch (e) {
      return {
        "status": 500,
        "data": {"message": e.toString()},
      };
    }
  }

  static Future<Map<String, dynamic>> deleteComment(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.delete(
        Uri.parse("${Api.baseUrl}/comments/$id"),

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
}
