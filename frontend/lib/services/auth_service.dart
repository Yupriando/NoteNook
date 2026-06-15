import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("${Api.baseUrl}/auth/register"),
            headers: {"Content-Type": "application/json"},

            body: jsonEncode({
              "name": name,
              "email": email,
              "phone": phone,
              "password": password,
              "role": "user",
            }),
          )
          .timeout(const Duration(seconds: 10));

      print(response.body);

      return {"status": response.statusCode, "data": jsonDecode(response.body)};
    } catch (e) {
      print(e);

      return {
        "status": 500,
        "data": {"message": e.toString()},
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("${Api.baseUrl}/auth/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      print(response.body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        await prefs.setInt("user_id", data["user"]["id"]);
      }

      return {"status": response.statusCode, "data": data};
    } catch (e) {
      print(e);

      return {
        "status": 500,
        "data": {"message": e.toString()},
      };
    }
  }

  static Future logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");
    await prefs.remove("user_id");
  }
}
