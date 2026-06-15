import 'package:flutter/material.dart';
import 'package:frontend/pages/notes/note_detail_page.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/utils/api.dart';
import 'package:intl/intl.dart';

class UserNotesPage extends StatefulWidget {
  final int userId;
  final String userName;

  const UserNotesPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserNotesPage> createState() => _UserNotesPageState();
}

class _UserNotesPageState extends State<UserNotesPage> {
  List notes = [];
  bool loading = true;

  Future loadNotes() async {
    final result = await UserService.getUserNotes(widget.userId);
    if (result["status"] == 200) {
      setState(() {
        notes = result["data"];
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
    loadNotes();
  }

  String formatDate(String? date) {
    if (date == null) {
      return "";
    }
    try {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(date));
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F6FFF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text("${widget.userName}'s Notes"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 90,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "No Public Notes Yet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${widget.userName} hasn't shared any public notes",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  color: const Color(0xFF0F6FFF),

                  child: Text(
                    "${notes.length} Public Note${notes.length > 1 ? "s" : ""}",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),

                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8EEF7)),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),

                              blurRadius: 12,

                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NoteDetailPage(note: note),
                                ),
                              );
                            },

                            child: Padding(
                              padding: const EdgeInsets.all(18),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),

                                        decoration: BoxDecoration(
                                          color: Colors.green,

                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),

                                        child: const Text(
                                          "Public",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      const Spacer(),

                                      Text(
                                        formatDate(note["created_at"]),

                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  Text(
                                    note["title"] ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    note["description"] ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage:
                                            note["profile_picture"] != null &&
                                                note["profile_picture"]
                                                    .toString()
                                                    .isNotEmpty
                                            ? NetworkImage(
                                                "${Api.baseUrl}/uploads/profile/${note!["profile_picture"]}",
                                              )
                                            : null,
                                        backgroundColor: const Color(
                                          0xFFEAF2FF,
                                        ),

                                        child:
                                            note["profile_picture"] == null ||
                                                note["profile_picture"]
                                                    .toString()
                                                    .isEmpty
                                            ? const Icon(
                                                Icons.person,
                                                size: 16,
                                                color: Color(0xFF0F6FFF),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 8),

                                      Text(
                                        widget.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4B6B9B),
                                        ),
                                      ),

                                      if (note["role"] == "mentor")
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),

                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),

                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0F6FFF),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.verified,
                                                size: 12,
                                                color: Colors.white,
                                              ),

                                              SizedBox(width: 4),

                                              Text(
                                                "Mentor",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const Spacer(),

                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Color(0xFF0F6FFF),
                                      ),
                                    ],
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
              ],
            ),
    );
  }
}
