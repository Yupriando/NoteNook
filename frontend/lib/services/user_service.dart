import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/user/profile"),
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

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String bio,
    dynamic image,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final request = http.MultipartRequest(
        "PUT",
        Uri.parse("${Api.baseUrl}/user/profile"),
      );

      request.headers["Authorization"] = "Bearer $token";
      request.fields["name"] = name;
      request.fields["email"] = email;
      request.fields["phone"] = phone;
      request.fields["bio"] = bio;

      if (image != null) {
        print(image.path);

        request.files.add(
          await http.MultipartFile.fromPath(
            "profile_picture",
            image.path,
            filename: image.path.split("/").last,
          ),
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

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.put(
        Uri.parse("${Api.baseUrl}/user/change-password"),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },

        body: jsonEncode({
          "oldPassword": oldPassword,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
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

  static Future<Map<String, dynamic>> getMentors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/user/mentors"),
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

  static Future<Map<String, dynamic>> getUserProfile(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/user/profile/$id"),
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

  static Future<Map<String, dynamic>> becomeMentor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.put(
        Uri.parse("${Api.baseUrl}/user/become-mentor"),
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

  static Future<Map<String, dynamic>> getUserNotes(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/user/$userId/notes"),
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
