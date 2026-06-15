import 'package:flutter/material.dart';
import 'package:frontend/pages/chat/chat_page.dart';
import 'package:frontend/pages/users/user_notes_page.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/utils/api.dart';
import 'package:frontend/widgets/profile_stat_item.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? user;

  bool loading = true;

  Future loadProfile() async {
    final result = await UserService.getUserProfile(widget.userId);

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
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),

        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0077FF)),
        ),
      );
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
                  height: 240,

                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,

                      colors: [Color(0xFF0077FF), Color(0xFF3395FF)],
                    ),
                  ),
                ),

                Positioned(
                  top: 45,
                  left: 15,

                  child: SafeArea(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: Container(
                        padding: const EdgeInsets.all(10),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -70,
                  left: 0,
                  right: 0,

                  child: Center(
                    child: Container(
                      width: 140,
                      height: 140,

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

            const SizedBox(height: 90),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),

              child: Column(
                children: [
                  Text(
                    user?["name"] ?? "Unknown",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
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

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 25,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFDCEBFF)),
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserNotesPage(
                                  userId: widget.userId,
                                  userName: user?["name"] ?? "",
                                ),
                              ),
                            );
                          },
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

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              userId: user!["id"],
                              userName: user!["name"],
                              profilePicture: "${Api.baseUrl}/uploads/profile/${user!["profile_picture"]}",
                            ),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077FF),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      icon: const Icon(Icons.chat, color: Colors.white),

                      label: const Text(
                        "Message",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
