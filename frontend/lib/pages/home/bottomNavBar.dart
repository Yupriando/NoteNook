import 'package:flutter/material.dart';
import 'package:frontend/pages/users/user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/pages/home/home_page.dart';
import 'package:frontend/pages/notes/my_note_page.dart';
import 'package:frontend/pages/profile/profile_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 1;

  List<Widget> pages = [];

  Future<void> loadPages() async {
    await SharedPreferences.getInstance();

    setState(() {
      pages = const [
        MyNotePage(),
        HomeContentPage(),
        UserPage(),
        ProfilePage(),
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    loadPages();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (pages.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0077FF)),
        ),
      );
    }

    return Scaffold(
      body: pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        backgroundColor: const Color(0xFF0077FF),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        selectedFontSize: 12,
        unselectedFontSize: 11,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note_outlined),
            label: "My Note",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.messenger_outline_rounded),
            label: "Chat",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
