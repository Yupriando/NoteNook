import 'dart:convert';
import 'dart:io';
import 'package:frontend/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteService {
  static Future<Map<String, dynamic>> createNote({
    required String title,
    required String description,
    required String visibility,
    int? folderId,
    List<File> files = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("${Api.baseUrl}/notes"),
    );

    request.headers["Authorization"] = "Bearer $token";
    request.fields["title"] = title;
    request.fields["description"] = description;
    request.fields["visibility"] = visibility;

    if (folderId != null) {
      request.fields["folder_id"] = folderId.toString();
    }

    for (var file in files) {
      final mimeType = lookupMimeType(file.path);

      request.files.add(
        await http.MultipartFile.fromPath(
          "files",
          file.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    print("STATUS: ${response.statusCode}");
    print("BODY: $body");

    return {"status": response.statusCode, "data": body};
  }

  static Future<Map<String, dynamic>> updateNote({
    required int id,
    required String title,
    required String description,
    required String visibility,
    int? folderId,
    List<File> files = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final request = http.MultipartRequest(
      "PUT",
      Uri.parse("${Api.baseUrl}/notes/$id"),
    );

    request.headers["Authorization"] = "Bearer $token";
    request.fields["title"] = title;
    request.fields["description"] = description;
    request.fields["visibility"] = visibility;

    if (folderId != null) {
      request.fields["folder_id"] = folderId.toString();
    }

    for (var file in files) {
      final mimeType = lookupMimeType(file.path);

      request.files.add(
        await http.MultipartFile.fromPath(
          "files",
          file.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    return {"status": response.statusCode, "data": jsonDecode(body)};
  }

  static Future<Map<String, dynamic>> deleteNote(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final response = await http.delete(
      Uri.parse("${Api.baseUrl}/notes/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> bookmarkNote(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final response = await http.post(
      Uri.parse("${Api.baseUrl}/notes/bookmark/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> removeBookmark(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final response = await http.delete(
      Uri.parse("${Api.baseUrl}/notes/bookmark/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/notes/bookmarks"),
      headers: {"Authorization": "Bearer $token"},
    );
    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> getPublicNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/notes/public"),
      headers: {"Authorization": "Bearer $token"},
    );
    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> searchNotes(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/notes/search?q=$query"),
      headers: {"Authorization": "Bearer $token"},
    );
    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> mySearchNotes(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/notes/my-search?q=$query"),
      headers: {"Authorization": "Bearer $token"},
    );
    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }
}
