import 'package:flutter/material.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/utils/api.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'package:frontend/widgets/custom_textfield.dart';
import 'package:frontend/widgets/field_label.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool loading = false;

  File? selectedImage;

  Map<String, dynamic>? user;

  final ImagePicker picker = ImagePicker();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();

  Future loadProfile() async {
    final result = await UserService.getProfile();

    if (result["status"] == 200) {
      user = result["data"];
      nameController.text = user!["name"];
      emailController.text = user!["email"];
      phoneController.text = user!["phone"];
      bioController.text = user!["bio"] ?? "";
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future saveProfile() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all required fields")));

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

    if (bioController.text.length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bio cannot exceed 200 characters")),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    final result = await UserService.updateProfile(
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      bio: bioController.text,
      image: selectedImage,
    );

    setState(() {
      loading = false;
    });

    if (result["status"] == 200) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Profile updated")));

        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["data"]["message"])));
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
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
          "Edit Profile",
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
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        border: Border.all(
                          color: const Color(0xFF0077FF),
                          width: 3,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0077FF).withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        image: DecorationImage(
                          fit: BoxFit.cover,

                          image: selectedImage != null
                              ? FileImage(selectedImage!)
                              : user?["profile_picture"] != null
                              ? NetworkImage(
                                  '${Api.baseUrl}/uploads/profile/${user!["profile_picture"]}',
                                )
                              : const AssetImage("assets/images/profile.png")
                                    as ImageProvider,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,

                      child: GestureDetector(
                        onTap: pickImage,

                        child: Container(
                          padding: const EdgeInsets.all(10),

                          decoration: const BoxDecoration(
                            color: Color(0xFF0077FF),
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Update your profile information",
                textAlign: TextAlign.center,
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
                    const FieldLabel(text: "Name"),

                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: nameController,
                      hintText: "Your Name",
                    ),

                    const SizedBox(height: 20),

                    const FieldLabel(text: "Bio"),

                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: bioController,
                      hintText: "Your Bio",
                      maxLiens: 3,
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
                  ],
                ),
              ),

              const SizedBox(height: 30),

              CustomButton(
                text: loading ? "Saving..." : "Save Changes",

                onPressed: loading
                    ? null
                    : () async {
                        await saveProfile();
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
