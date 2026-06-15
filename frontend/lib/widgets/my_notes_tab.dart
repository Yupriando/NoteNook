import 'package:flutter/material.dart';
import 'package:frontend/widgets/folder_card.dart';
import 'package:frontend/widgets/note_list_tile.dart';
import 'package:frontend/widgets/search_box.dart';

class MyNotesTab extends StatelessWidget {
  final bool loading;
  final int? currentFolderId;
  final TextEditingController searchController;
  final Function(String) onSearch;
  final List filteredFolders;
  final List filteredNotes;
  final Function(Map) onFolderTap;
  final Function(Map) onFolderMenu;
  final Function(Map) onNoteTap;

  const MyNotesTab({
    super.key,
    required this.loading,
    required this.currentFolderId,
    required this.searchController,
    required this.onSearch,
    required this.filteredFolders,
    required this.filteredNotes,
    required this.onFolderTap,
    required this.onFolderMenu,
    required this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredFolders.isEmpty && filteredNotes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.menu_book_rounded, size: 70, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text(
              "No notes yet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),

      children: [
        if (currentFolderId == null)
          const Text(
            "My Notes",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),

        if (currentFolderId == null) const SizedBox(height: 20),

        if (currentFolderId == null)
          SearchBox(
            controller: searchController,
            onChanged: onSearch,
            hint: "Search notes...",
          ),

        if (currentFolderId == null) const SizedBox(height: 25),

        ...filteredFolders.map(
          (folder) => FolderCard(
            folderName: folder["name"],
            onTap: () => onFolderTap(folder),
          ),
        ),

        ...filteredNotes.map(
          (note) => NoteListTile(note: note, onTap: () => onNoteTap(note)),
        ),
      ],
    );
  }
}
