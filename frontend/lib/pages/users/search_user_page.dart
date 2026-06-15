import 'package:flutter/material.dart';
import 'package:frontend/pages/chat/chat_page.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/utils/api.dart';
import 'package:frontend/widgets/search_box.dart';
import 'package:frontend/widgets/section_header.dart';
import 'package:frontend/widgets/user_card.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  State<SearchUserPage> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUserPage> {
  List mentors = [];
  List filteredMentors = [];
  bool loading = true;
  bool showMentors = true;
  bool showUsers = true;

  final searchController = TextEditingController();

  Future loadMentors() async {
    final result = await UserService.getMentors();

    if (result["status"] == 200) {
      setState(() {
        mentors = result["data"];
        filteredMentors = result["data"];
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  void searchMentor(String value) {
    final results = mentors.where((mentor) {
      final name = mentor["name"].toString().toLowerCase();

      return name.contains(value.toLowerCase());
    }).toList();

    setState(() {
      filteredMentors = results;
    });
  }

  @override
  void initState() {
    super.initState();
    loadMentors();
  }

  @override
  Widget build(BuildContext context) {
    final mentorList = filteredMentors
        .where((e) => e["role"] == "mentor")
        .toList();

    final userList = filteredMentors
        .where((e) => e["role"] != "mentor")
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 10),

              const Text(
                "Find People",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "${filteredMentors.length} users available",
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),

              const SizedBox(height: 20),

              SearchBox(
                controller: searchController,
                onChanged: searchMentor,
                hint: "Search Users",
              ),

              const SizedBox(height: 20),

              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0077FF),
                        ),
                      )
                    : filteredMentors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 70,
                              color: Color(0xFFB0BFCF),
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              "No users found",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Try another keyword",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        children: [
                          SectionHeader(
                            title: "Mentors (${mentorList.length})",
                            isOpen: showMentors,
                            onTap: () {
                              setState(() {
                                showMentors = !showMentors;
                              });
                            },
                          ),

                          if (showMentors)
                            ...mentorList.map(
                              (mentor) => UserCard(
                                user: mentor,
                                subtitle: "Learning Mentor",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatPage(
                                        userId: mentor["id"],
                                        userName: mentor["name"],
                                        profilePicture:
                                            mentor["profile_picture"],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          SectionHeader(
                            title: "Users (${userList.length})",
                            isOpen: showUsers,
                            onTap: () {
                              setState(() {
                                showUsers = !showUsers;
                              });
                            },
                          ),

                          if (showUsers)
                            ...userList.map(
                              (user) => UserCard(
                                user: user,
                                subtitle: "Study Partner",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatPage(
                                        userId: user["id"],
                                        userName: user["name"],
                                        profilePicture:
                                            "${Api.baseUrl}/uploads/profile/${user!["profile_picture"]}",
                                        role: user["role"],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
