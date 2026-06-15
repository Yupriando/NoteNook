import 'package:flutter/material.dart';
import 'package:frontend/pages/chat/conversation_page.dart';
import 'package:frontend/pages/users/search_user_page.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,

      child: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 0, 119, 255),

            child: const SafeArea(
              bottom: false,

              child: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,

                tabs: [
                  Tab(text: "Search Users"),
                  Tab(text: "Previous Chats"),
                ],
              ),
            ),
          ),
          const Expanded(
            child: TabBarView(children: [SearchUserPage(), ConversationPage()]),
          ),
        ],
      ),
    );
  }
}
