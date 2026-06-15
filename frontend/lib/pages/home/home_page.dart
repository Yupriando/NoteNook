import 'package:flutter/material.dart';
import 'package:frontend/pages/notes/note_detail_page.dart';
import 'package:frontend/services/note_service.dart';
import 'package:frontend/utils/api.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContentPage> {
  bool loading = true;

  List notes = [];
  List filteredNotes = [];

  final searchController = TextEditingController();

  Future loadNotes() async {
    final result = await NoteService.getPublicNotes();

    print("PUBLIC NOTES:");
    print(result);

    if (result["status"] == 200) {
      setState(() {
        notes = result["data"];
        filteredNotes = result["data"];
        loading = false;
      });
    }
  }

  void searchNotes(String query) {
    setState(() {
      filteredNotes = notes.where((note) {
        final title = note["title"].toString().toLowerCase();
        final description = note["description"].toString().toLowerCase();
        final creator = note["name"].toString().toLowerCase();

        return title.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase()) ||
            creator.contains(query.toLowerCase());
      }).toList();
    });
  }

  bool isImage(String? url) {
    if (url == null) {
      return false;
    }
    final lower = url.toLowerCase();

    return lower.endsWith(".png") ||
        lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".webp");
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),

      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: loadNotes,

                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),

                  itemCount: filteredNotes.length + 1,

                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Explore Notes',
                                    style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            TextField(
                              controller: searchController,
                              onChanged: searchNotes,
                              decoration: InputDecoration(
                                hintText: "Search public notes...",
                                hintStyle: const TextStyle(
                                  color: Color(0xFF64748B),
                                ),

                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF64748B),
                                ),

                                filled: true,
                                fillColor: Colors.white,

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

                                  borderSide: const BorderSide(
                                    color: Color(0xFF0077FF),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (filteredNotes.isEmpty && index == 1) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 80),

                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 70,
                                color: Color(0xFFCBD5E1),
                              ),

                              SizedBox(height: 12),

                              Text(
                                "No notes found",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 6),

                              Text(
                                "Try another keyword",
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    print(filteredNotes[index - 1]);

                    final note = filteredNotes[index - 1];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),

                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,

                          colors: [Color(0xFF0077FF), Color(0xFF3395FF)],
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0077FF).withOpacity(0.20),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Material(
                        color: Colors.transparent,

                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteDetailPage(note: note),
                              ),
                            );
                            loadNotes();
                          },

                          child: Padding(
                            padding: const EdgeInsets.all(16),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          note["profile_picture"] != null &&
                                              note["profile_picture"]
                                                  .toString()
                                                  .isNotEmpty
                                          ? NetworkImage(
                                              "${Api.baseUrl}/uploads/profile/${note["profile_picture"]}",
                                            )
                                          : null,

                                      child:
                                          note["profile_picture"] == null ||
                                              note["profile_picture"]
                                                  .toString()
                                                  .isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  note["name"] ?? "Unknown",

                                                  overflow:
                                                      TextOverflow.ellipsis,

                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),

                                              if (note["role"] == "mentor")
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    left: 8,
                                                  ),

                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),

                                                  decoration: BoxDecoration(
                                                    color: Colors.white,

                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),

                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,

                                                    children: [
                                                      Icon(
                                                        Icons.verified,
                                                        color: Colors.blue,
                                                        size: 13,
                                                      ),

                                                      SizedBox(width: 4),

                                                      Text(
                                                        "Mentor",
                                                        style: TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),

                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                            ),

                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),

                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.12,
                                              ),

                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.15,
                                                ),
                                              ),

                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),

                                            child: Text(
                                              note["visibility"] == "public"
                                                  ? "Public"
                                                  : "Private",

                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Icon(
                                      note["bookmarked"] == 1
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                Text(
                                  note["title"] ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  note["description"] ?? "",
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),

                                if (note["files"] != null &&
                                    note["files"].isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),

                                    child: SizedBox(
                                      height: 180,

                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,

                                        itemCount: note["files"].length,

                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 10),

                                        itemBuilder: (context, fileIndex) {
                                          final file = note["files"][fileIndex];

                                          final isImg =
                                              file["file_type"] == "image";

                                          if (isImg) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(
                                                "${Api.baseUrl}/uploads/notes/${file["file_url"]}",
                                                width: 180,
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          }
                                          final fileName = file["file_url"]
                                              .toString();

                                          final extension =
                                              fileName.contains(".")
                                              ? fileName
                                                    .split(".")
                                                    .last
                                                    .toUpperCase()
                                              : "FILE";

                                          return Container(
                                            padding: const EdgeInsets.all(12),

                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.12,
                                              ),

                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.15,
                                                ),
                                              ),

                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),

                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,

                                              children: [
                                                const Icon(
                                                  Icons.description_rounded,
                                                  color: Colors.white,
                                                  size: 42,
                                                ),

                                                const SizedBox(height: 12),

                                                Text(
                                                  extension,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                const SizedBox(height: 10),

                                                const Text(
                                                  "Document",
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),

                                                const SizedBox(height: 6),

                                                Text(
                                                  fileName.length > 20
                                                      ? "${fileName.substring(0, 20)}..."
                                                      : fileName,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
