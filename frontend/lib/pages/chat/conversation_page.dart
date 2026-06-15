import 'package:flutter/material.dart';
import 'package:frontend/pages/chat/chat_page.dart';
import 'package:frontend/services/chat_service.dart';
import 'package:frontend/utils/api.dart';
import 'package:frontend/widgets/conversation_card.dart';
import 'package:frontend/widgets/section_header.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  List conversations = [];
  List filteredConversations = [];

  bool loading = true;
  bool showMentors = true;
  bool showUsers = true;

  IO.Socket? socket;

  final searchController = TextEditingController();

  Future loadConversations() async {
    try {
      final result = await ChatService.getConversations();

      print("CONVERSATIONS:");
      print(result);

      if (result["status"] == 200) {
        setState(() {
          conversations = result["data"];

          filteredConversations = result["data"];

          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e, s) {
      print("ERROR CONVERSATION PAGE:");
      print(e);
      print(s);
    }
  }

  void searchConversation(String value) {
    final results = conversations.where((chat) {
      final name = chat["name"].toString().toLowerCase();

      return name.contains(value.toLowerCase());
    }).toList();

    setState(() {
      filteredConversations = results;
    });
  }

  Future connectSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      return;
    }

    final payload = token.split(".")[1];
    final normalized = base64.normalize(payload);
    final decoded = jsonDecode(utf8.decode(base64.decode(normalized)));
    final userId = decoded["id"];

    socket = IO.io(
      Api.baseUrl,

      IO.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      socket!.emit("join", userId.toString());
    });

    socket!.on("receive_message", (data) async {
      if (mounted) {
        await loadConversations();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadConversations();
    connectSocket();
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mentorChats = filteredConversations
        .where((e) => e["role"] == "mentor")
        .toList();

    final userChats = filteredConversations
        .where((e) => e["role"] != "mentor")
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),

                  child: TextField(
                    controller: searchController,
                    onChanged: searchConversation,

                    decoration: InputDecoration(
                      hintText: "Search conversations",
                      prefixIcon: const Icon(Icons.search),

                      filled: true,
                      fillColor: Colors.white,

                      contentPadding: const EdgeInsets.symmetric(vertical: 16),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFF0F6FFF)),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: filteredConversations.isEmpty
                      ? const Center(child: Text("No conversation"))
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 15),

                          children: [
                            SectionHeader(
                              title: "Mentors",
                              isOpen: showMentors,
                              onTap: () {
                                showMentors = !showMentors;
                              },
                            ),

                            ...mentorChats.map(
                              (chat) => ConversationCard(
                                chat: chat,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatPage(
                                        userId: chat["user_id"],
                                        userName: chat["name"],
                                        profilePicture: chat["profile_picture"],
                                        role: chat["role"],
                                      ),
                                    ),
                                  );
                                  loadConversations();
                                },
                              ),
                            ),

                            const SizedBox(height: 10),

                            SectionHeader(
                              title: "Users",
                              isOpen: showUsers,
                              onTap: () {
                                setState(() {
                                  showUsers = !showUsers;
                                });
                              },
                            ),

                            ...userChats.map(
                              (chat) => ConversationCard(
                                chat: chat,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatPage(
                                        userId: chat["user_id"],
                                        userName: chat["name"],
                                        profilePicture: chat["profile_picture"],
                                        role: chat["role"],
                                      ),
                                    ),
                                  );
                                  loadConversations();
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}
