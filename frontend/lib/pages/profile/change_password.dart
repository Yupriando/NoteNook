import 'package:flutter/material.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'package:frontend/widgets/custom_textfield.dart';
import 'package:frontend/widgets/field_label.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePassWordState();
}

class _ChangePassWordState extends State<ChangePassword> {
  bool isCurrentPasswordHidden = true;
  bool isNewPasswordHidden = true;
  bool isConfirmNewPassowrdHidden = true;

  bool loading = false;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future savePassword() async {
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));

      return;
    }

    if (newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 8 characters")),
      );

      return;
    }

    final password = newPasswordController.text;

    if (currentPasswordController.text == newPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("New password must be different from current password"),
        ),
      );

      return;
    }

    if (newPasswordController.text.length > 50) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password is too long")));

      return;
    }

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

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password mismatch")));

      return;
    }

    setState(() {
      loading = true;
    });

    final result = await UserService.changePassword(
      oldPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    setState(() {
      loading = false;
    });

    if (result["status"] == 200) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Password updated")));

        Navigator.pop(context);
      }
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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),

        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Column(
            children: [
              const SizedBox(height: 20),

              Center(
                child: Container(
                  width: 90,
                  height: 90,

                  decoration: const BoxDecoration(
                    color: Color(0xFFDCEBFF),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size: 42,
                    color: Color(0xFF0077FF),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Update your password",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(24),

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
                    const FieldLabel(text: "Current Password"),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: currentPasswordController,
                      hintText: "Input Current Password",
                      obscureText: isCurrentPasswordHidden,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isCurrentPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,

                          color: const Color(0xFF64748B),
                        ),

                        onPressed: () {
                          setState(() {
                            isCurrentPasswordHidden = !isCurrentPasswordHidden;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                    const FieldLabel(text: "New Password"),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: newPasswordController,
                      hintText: "Input New Password",
                      obscureText: isNewPasswordHidden,

                      suffixIcon: IconButton(
                        icon: Icon(
                          isNewPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,

                          color: const Color(0xFF64748B),
                        ),

                        onPressed: () {
                          setState(() {
                            isNewPasswordHidden = !isNewPasswordHidden;
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

                    const FieldLabel(text: "Confirm New Password"),

                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: confirmPasswordController,
                      hintText: "Input Confirm New Password",
                      obscureText: isConfirmNewPassowrdHidden,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmNewPassowrdHidden
                              ? Icons.visibility_off
                              : Icons.visibility,

                          color: const Color(0xFF64748B),
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmNewPassowrdHidden =
                                !isConfirmNewPassowrdHidden;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              CustomButton(
                text: loading ? "Saving..." : "Save Password",
                onPressed: loading
                    ? null
                    : () async {
                        await savePassword();
                      },
                backgroundColor: const Color(0xFF0077FF),
                textColor: Colors.white,
                shadowColor: const Color(0xFF0077FF),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
