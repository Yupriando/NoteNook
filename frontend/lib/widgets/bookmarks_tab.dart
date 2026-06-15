import 'package:flutter/material.dart';
import 'package:frontend/widgets/note_list_tile.dart';
import 'package:frontend/widgets/search_box.dart';

class BookmarksTab extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final List bookmarks;
  final Function(Map) onNoteTap;

  const BookmarksTab({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.bookmarks,
    required this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),

      children: [
        const Text(
          "Fav Notes",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        SearchBox(
          controller: searchController,
          onChanged: onSearch,
          hint: "Search notes...",
        ),

        const SizedBox(height: 25),

        ...bookmarks.map(
          (note) => NoteListTile(
            note: note,
            bookmarked: true,
            onTap: () => onNoteTap(note),
          ),
        ),
      ],
    );
  }
}
