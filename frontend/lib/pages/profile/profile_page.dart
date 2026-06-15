import 'package:flutter/material.dart';
import 'package:frontend/pages/profile/change_password.dart';
import 'package:frontend/pages/profile/edit_profile.dart';
import 'package:frontend/pages/auth/welcome_page.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/widgets/profile_menu_tile.dart';
import 'package:frontend/widgets/profile_stat_item.dart';
import 'package:frontend/utils/api.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  bool loading = true;

  Future loadProfile() async {
    final result = await UserService.getProfile();

    if (result["status"] == 200) {
      setState(() {
        user = result["data"];

        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,

              children: [
                Container(
                  width: double.infinity,
                  height: 260,

                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,

                      colors: [Color(0xFF0077FF), Color(0xFF3395FF)],
                    ),
                  ),
                ),

                Positioned(
                  bottom: -75,
                  left: 0,
                  right: 0,

                  child: Center(
                    child: Container(
                      width: 150,
                      height: 150,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),

                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0077FF).withOpacity(0.20),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],

                        image: DecorationImage(
                          image: user?["profile_picture"] != null
                              ? NetworkImage(
                                  "${Api.baseUrl}/uploads/profile/${user!["profile_picture"]}",
                                )
                              : const AssetImage("assets/images/profile.jpg")
                                    as ImageProvider,

                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 95),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),

              child: Column(
                children: [
                  Text(
                    user?["name"] ?? "Unknown",

                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFDCEBFF),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        if (user?["role"] == "mentor")
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Color(0xFF0077FF),
                          ),
                        if (user?["role"] == "mentor") const SizedBox(width: 5),

                        Text(
                          user?["role"] == "mentor" ? "Mentor" : "User",
                          style: const TextStyle(
                            color: Color(0xFF0077FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: 280,

                    child: Text(
                      user?["bio"]?.toString().isNotEmpty == true
                          ? user!["bio"]
                          : "No bio yet",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF4B6B9B),
                        height: 1.7,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 25,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFDCEBFF),
                      border: Border.all(color: const Color(0xFFD6E7FF)),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,

                      children: [
                        ProfileStatItem(
                          value: user?["total_notes"]?.toString() ?? "0",
                          label: "Notes",
                        ),

                        ProfileStatItem(
                          value: user?["total_comments"]?.toString() ?? "0",
                          label: "Comments",
                        ),

                        ProfileStatItem(
                          value: user?["total_bookmarks"]?.toString() ?? "0",
                          label: "Bookmarks",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  ProfileMenuTile(
                    icon: Icons.edit_rounded,
                    title: "Edit Profile",
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,

                        MaterialPageRoute(builder: (_) => const EditProfile()),
                      );
                      if (updated == true) {
                        loadProfile();
                      }
                    },
                  ),

                  ProfileMenuTile(
                    icon: Icons.lock_rounded,
                    title: "Change Password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePassword(),
                        ),
                      );
                    },
                  ),

                  if (user?["role"] == "user")
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),

                      child: SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await UserService.becomeMentor();

                            if (result["status"] == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("You are now a mentor"),
                                ),
                              );
                              loadProfile();
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0077FF),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Become Mentor",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),

                  ProfileMenuTile(
                    icon: Icons.logout_rounded,
                    title: "Log Out",
                    color: Colors.red,
                    onTap: () {
                      showDialog(
                        context: context,

                        builder: (context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,

                            child: Container(
                              padding: const EdgeInsets.all(25),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Column(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  const Icon(
                                    Icons.logout_rounded,
                                    size: 90,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 20),

                                  const Text(
                                    "Log Out?",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  const Text(
                                    "Are you sure you want to leave?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,

                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0077FF,
                                        ),

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),

                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,

                                    child: OutlinedButton(
                                      onPressed: () async {
                                        await AuthService.logout();

                                        if (mounted) {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const WelcomePage(),
                                            ),
                                            (route) => false,
                                          );
                                        }
                                      },

                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),

                                      child: const Text(
                                        "Yes, Log Me Out",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
