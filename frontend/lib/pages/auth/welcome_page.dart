import 'package:flutter/material.dart';
import 'package:frontend/pages/auth/login_page.dart';
import 'package:frontend/pages/auth/register_page.dart';
import 'package:frontend/widgets/custom_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDCEBFF),
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDCEBFF).withOpacity(0.6),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),

              child: Column(
                children: [
                  const Spacer(),

                  Container(
                    width: 130,
                    height: 130,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Center(
                      child: Container(
                        width: 82,
                        height: 82,

                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0077FF),
                        ),

                        child: const Icon(
                          Icons.book_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  const Text(
                    "NoteNook",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),

                    child: Text(
                      "A Cozy Space for Collaborative Learning",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.7,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 55),

                  CustomButton(
                    text: "Create Account",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },

                    backgroundColor: const Color(0xFF0077FF),
                    textColor: Colors.white,
                    shadowColor: const Color(0xFF0077FF),
                  ),

                  const SizedBox(height: 18),

                  CustomButton(
                    text: "Login",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },

                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    shadowColor: Colors.black.withOpacity(0.05),

                    borderSide: const BorderSide(
                      color: Color(0xFFDCEBFF),
                      width: 2,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Learn • Connect • Grow",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
