import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/auth/login_page.dart';
import 'package:frontend/widgets/custom_textfield.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'package:frontend/widgets/field_label.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool loading = false;

  Future register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));

      return;
    }

    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

    if (!emailRegex.hasMatch(emailController.text.trim())) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid email address")));

      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number must contain only digits")),
      );

      return;
    }

    if (phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number is too short")),
      );

      return;
    }

    if (passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 8 characters")),
      );

      return;
    }

    final password = passwordController.text;

    if (!RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[a-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password must contain uppercase, lowercase and number",
          ),
        ),
      );
      return;
    }

    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password mismatch")));
      return;
    }

    setState(() {
      loading = true;
    });

    final result = await AuthService.register(
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      password: passwordController.text,
    );

    setState(() {
      loading = false;
    });

    if (result["status"] == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Register success")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["data"]["message"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
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
                    Icons.person_add_alt_1_rounded,
                    size: 42,
                    color: Color(0xFF0077FF),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Center(
                child: Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Join the community and start sharing notes, learning together, and connecting with mentors.",
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
                    const FieldLabel(text: "Full Name"),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: nameController,
                      hintText: "Your Name",
                    ),

                    const SizedBox(height: 20),
                    const FieldLabel(text: "Email"),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: emailController,
                      hintText: "hello@example.com",
                    ),

                    const SizedBox(height: 20),
                    const FieldLabel(text: "Phone"),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: phoneController,
                      hintText: "08123456789",
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

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: const Color(0xFFDCEBFF),
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "• Must be at least 8 characters long",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4B6B9B),
                            ),
                          ),
                          SizedBox(height: 4),

                          Text(
                            "• Must contain uppercase, lowercase and number",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4B6B9B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const FieldLabel(text: "Confirm Password"),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: confirmController,
                      hintText: "Input Confirm Password",
                      obscureText: isConfirmPasswordHidden,

                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,

                          color: const Color(0xFF64748B),
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordHidden = !isConfirmPasswordHidden;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              CustomButton(
                text: loading ? "Loading..." : "Create Account",

                onPressed: loading
                    ? null
                    : () async {
                        await register();
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
                    ),

                    children: [
                      const TextSpan(text: "Already have an account? "),

                      TextSpan(
                        text: "Log In",
                        style: const TextStyle(
                          color: Color(0xFF0077FF),
                          fontWeight: FontWeight.bold,
                        ),

                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
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
