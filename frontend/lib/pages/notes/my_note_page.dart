import 'package:flutter/material.dart';
import 'package:frontend/pages/notes/create_note_page.dart';
import 'package:frontend/pages/notes/note_detail_page.dart';
import 'package:frontend/services/folder_service.dart';
import 'package:frontend/services/note_service.dart';
import 'package:frontend/widgets/bookmarks_tab.dart';
import 'package:frontend/widgets/my_notes_tab.dart';

class MyNotePage extends StatefulWidget {
  const MyNotePage({super.key});

  @override
  State<MyNotePage> createState() => _MyNotePageState();
}

class _MyNotePageState extends State<MyNotePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  List folders = [];
  List notes = [];
  List bookmarks = [];
  List filteredFolders = [];
  List filteredNotes = [];
  List filteredBookmarks = [];
  bool loading = true;
  int? currentFolderId;
  String title = "My Notes";

  final myNotesSearchController = TextEditingController();
  final bookmarkSearchController = TextEditingController();

  Future loadRoot() async {
    setState(() {
      loading = true;
    });

    final result = await FolderService.getRootContents();

    if (result["status"] == 200) {
      setState(() {
        folders = result["data"]["folders"];
        notes = result["data"]["notes"];
        filteredFolders = result["data"]["folders"];
        filteredNotes = result["data"]["notes"];
        loading = false;
        currentFolderId = null;
        title = "My Notes";
      });
    }
  }

  Future loadBookmarks() async {
    final result = await NoteService.getBookmarks();

    if (result["status"] == 200) {
      setState(() {
        bookmarks = result["data"];
        filteredBookmarks = result["data"];
      });
    }
  }

  Future searchMyNotes(String query) async {
    if (query.trim().isEmpty) {
      await loadRoot();
      return;
    }

    final result = await NoteService.mySearchNotes(query);

    if (result["status"] == 200) {
      setState(() {
        filteredFolders = folders.where((folder) {
          final name = folder["name"].toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
        filteredNotes = result["data"];
      });
    }
  }

  void searchBookmarks(String query) {
    setState(() {
      filteredBookmarks = bookmarks.where((note) {
        final title = note["title"].toString().toLowerCase();
        final description = note["description"].toString().toLowerCase();
        return title.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future openFolder(Map folder) async {
    setState(() {
      loading = true;
    });

    final result = await FolderService.getFolderContents(folder["id"]);

    if (result["status"] == 200) {
      setState(() {
        folders = result["data"]["folders"];
        notes = result["data"]["notes"];
        filteredFolders = result["data"]["folders"];
        filteredNotes = result["data"]["notes"];
        loading = false;
        currentFolderId = folder["id"];
        title = folder["name"];
      });
    }
  }

  Future createFolderDialog() async {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),

          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 119, 255),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(Icons.folder, color: Colors.white),
              ),

              const SizedBox(width: 15),

              const Text(
                "Create Folder",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ],
          ),

          content: TextField(
            controller: controller,

            decoration: InputDecoration(
              hintText: "Folder name",

              prefixIcon: const Icon(Icons.drive_file_rename_outline),
              filled: true,
              fillColor: Colors.grey.shade100,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 0, 119, 255),
                  width: 2,
                ),
              ),
            ),
          ),

          actionsPadding: const EdgeInsets.only(right: 15, bottom: 15),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 119, 255),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  return;
                }

                final result = await FolderService.createFolder(
                  name: controller.text,
                  parentId: currentFolderId,
                );

                if (result["status"] == 201) {
                  Navigator.pop(context);

                  if (currentFolderId == null) {
                    await loadRoot();
                  } else {
                    await openFolder({"id": currentFolderId, "name": title});
                  }
                }
              },

              child: const Text(
                "Create",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    loadRoot();
    loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentFolderId != null
          ? AppBar(
              title: Text(title),
              titleTextStyle: TextStyle(fontSize: 18, color: Colors.white),
              iconTheme: const IconThemeData(color: Colors.white),

              leading: IconButton(
                onPressed: loadRoot,

                icon: const Icon(Icons.arrow_back),
              ),
              backgroundColor: const Color.fromARGB(255, 0, 119, 255),
            )
          : null,

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,

        children: [
          FloatingActionButton(
            heroTag: "folder",
            backgroundColor: const Color(0xFF0077FF),
            foregroundColor: Colors.white,
            onPressed: createFolderDialog,
            child: const Icon(Icons.folder),
          ),

          const SizedBox(height: 15),

          FloatingActionButton(
            heroTag: "note",
            backgroundColor: const Color(0xFF0077FF),
            foregroundColor: Colors.white,
            onPressed: () async {
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateNotePage(folderId: currentFolderId),
                ),
              );

              if (refresh == true) {
                if (currentFolderId == null) {
                  await loadRoot();
                } else {
                  await openFolder({"id": currentFolderId, "name": title});
                }
                await loadBookmarks();
              }
            },
            child: const Icon(Icons.note_add),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF8FAFC),

      body: currentFolderId != null
          ? MyNotesTab(
              loading: loading,
              currentFolderId: currentFolderId,
              searchController: myNotesSearchController,
              onSearch: searchMyNotes,
              filteredFolders: filteredFolders,
              filteredNotes: filteredNotes,
              onFolderTap: (folder) {
                openFolder(folder);
              },
              onFolderMenu: (folder) {},

              onNoteTap: (note) async {
                final refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NoteDetailPage(note: note)),
                );

                if (refresh == true || refresh == "bookmark_changed") {
                  if (currentFolderId == null) {
                    await loadRoot();
                  } else {
                    await openFolder({"id": currentFolderId, "name": title});
                  }
                  await loadBookmarks();
                }
              },
            )
          : Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,

                      colors: [Color(0xFF0077FF), Color(0xFF3395FF)],
                    ),
                  ),

                  child: SafeArea(
                    bottom: false,

                    child: TabBar(
                      controller: tabController,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      dividerColor: Colors.transparent,

                      tabs: const [
                        Tab(text: "My Notes"),
                        Tab(text: "Fav Notes"),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: tabController,

                    children: [
                      MyNotesTab(
                        loading: loading,
                        currentFolderId: currentFolderId,
                        searchController: myNotesSearchController,
                        onSearch: searchMyNotes,
                        filteredFolders: filteredFolders,
                        filteredNotes: filteredNotes,
                        onFolderTap: (folder) {
                          openFolder(folder);
                        },

                        onFolderMenu: (folder) {},
                        onNoteTap: (note) async {
                          final refresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteDetailPage(note: note),
                            ),
                          );

                          if (refresh == true ||
                              refresh == "bookmark_changed") {
                            if (currentFolderId == null) {
                              await loadRoot();
                            } else {
                              await openFolder({
                                "id": currentFolderId,
                                "name": title,
                              });
                            }
                            await loadBookmarks();
                          }
                        },
                      ),
                      BookmarksTab(
                        searchController: bookmarkSearchController,
                        onSearch: searchBookmarks,
                        bookmarks: filteredBookmarks,
                        onNoteTap: (note) async {
                          final refresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteDetailPage(note: note),
                            ),
                          );

                          if (refresh == true ||
                              refresh == "bookmark_changed") {
                            await loadBookmarks();
                            await loadRoot();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
