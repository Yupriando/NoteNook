import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/home/bottomNavBar.dart';
import 'package:frontend/pages/auth/register_page.dart';
import 'package:frontend/widgets/custom_textfield.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'package:frontend/widgets/field_label.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isPasswordHidden = true;
  bool loading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    setState(() {
      loading = true;
    });

    Map<String, dynamic>? result;

    try {
      result = await AuthService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      print(result);
    } catch (e) {
      print(e);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));

      return;
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }

    if (result["status"] == 200) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", result["data"]["token"]);
      await prefs.setString("role", result["data"]["user"]["role"]);
      await prefs.setInt("user_id", result["data"]["user"]["id"]);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavBar()),
      );

      return;
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?["data"]?["message"] ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 10),

              Center(
                child: Container(
                  width: 90,
                  height: 90,

                  decoration: const BoxDecoration(
                    color: Color(0xFFDCEBFF),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 45,
                    color: Color(0xFF0077FF),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Login to continue learning, sharing notes, and connecting with mentors.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const FieldLabel(text: "Email"),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: emailController,
                      hintText: "hello@example.com",
                    ),

                    const SizedBox(height: 20),

                    const FieldLabel(text: "Password"),

                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: passwordController,
                      hintText: "Input Password",
                      obscureText: isPasswordHidden,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF64748B),
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordHidden = !isPasswordHidden;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              CustomButton(
                text: loading ? "Loading..." : "Login",
                onPressed: () async {
                  if (!loading) {
                    await login();
                  }
                },
                backgroundColor: const Color(0xFF0077FF),
                textColor: Colors.white,
                shadowColor: const Color(0xFF0077FF),
              ),

              const SizedBox(height: 30),

              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),

                    children: [
                      const TextSpan(text: "Don't have an account? "),

                      TextSpan(
                        text: "Create Account",
                        style: const TextStyle(
                          color: Color(0xFF0077FF),
                          fontWeight: FontWeight.bold,
                        ),

                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
