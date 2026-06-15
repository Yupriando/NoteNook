import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/notes/create_note_page.dart';
import 'package:frontend/pages/media/image_viewer_page.dart';
import 'package:frontend/services/comment_service.dart';
import 'package:frontend/services/note_service.dart';
import 'package:frontend/utils/api.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:frontend/pages/profile/user_profile_page.dart';

class NoteDetailPage extends StatefulWidget {
  final Map note;

  const NoteDetailPage({super.key, required this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late IO.Socket socket;

  bool bookmarked = false;
  int? currentUserId;
  List comments = [];
  bool loadingComments = true;
  int? replyingTo;
  String? replyingUser;
  Map<String, dynamic>? currentUser;

  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bookmarked = widget.note["bookmarked"] == 1;
    loadUser();
    loadComments();
    connectSocket();
  }

  void connectSocket() {
    socket = IO.io(
      Api.baseUrl,
      IO.OptionBuilder().setTransports(["websocket"]).build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print("comment socket connected");
    });

    socket.on("receive_comment", (data) {
      if (data["note_id"] == widget.note["id"]) {
        setState(() {
          comments.add(data);
        });
      }
    });

    socket.on("delete_comment", (data) {
      setState(() {
        comments.removeWhere(
          (comment) => comment["id"].toString() == data["id"].toString(),
        );
      });
    });
  }

  Future loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt("user_id");
    setState(() {});
  }

  Future loadComments() async {
    final result = await CommentService.getComments(widget.note["id"]);
    setState(() {
      loadingComments = false;
      if (result["status"] == 200) {
        comments = result["data"];
      }
    });
  }

  Future sendComment() async {
    if (commentController.text.trim().isEmpty) {
      return;
    }

    final result = await CommentService.createComment(
      noteId: widget.note["id"],
      comment: commentController.text,
      parentId: replyingTo,
    );

    if (result["status"] == 201) {
      commentController.clear();

      setState(() {
        replyingTo = null;
        replyingUser = null;
      });
      await loadComments();
    }
  }

  Future downloadFile(String url, String filename) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final dir = Directory("/storage/emulated/0/Download");
      final savePath = p.join(dir.path, filename);

      await Dio().download(
        url,
        savePath,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Downloaded: $filename")));
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    socket.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 119, 255),
        foregroundColor: Colors.white,
        title: Text(widget.note["title"] ?? ""),

        actions: [
          IconButton(
            onPressed: () async {
              if (!bookmarked) {
                final result = await NoteService.bookmarkNote(
                  widget.note["id"],
                );

                if (result["status"] == 200 || result["status"] == 201) {
                  setState(() {
                    bookmarked = true;
                  });

                  if (context.mounted) {
                    Navigator.pop(context, "bookmark_changed");
                  }
                }
              } else {
                final result = await NoteService.removeBookmark(
                  widget.note["id"],
                );

                if (result["status"] == 200) {
                  setState(() {
                    bookmarked = false;
                  });

                  if (context.mounted) {
                    Navigator.pop(context, "bookmark_changed");
                  }
                }
              }
            },

            icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_outline),
          ),

          if (currentUserId == widget.note["user_id"])
            PopupMenuButton(
              color: Colors.white,
              onSelected: (value) async {
                if (value == "edit") {
                  final refresh = await Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => CreateNotePage(
                        folderId: widget.note["folder_id"],
                        note: widget.note,
                      ),
                    ),
                  );

                  if (refresh == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                }

                if (value == "delete") {
                  final result = await NoteService.deleteNote(
                    widget.note["id"],
                  );

                  if (result["status"] == 200 && context.mounted) {
                    Navigator.pop(context, true);
                  }
                }
              },

              itemBuilder: (_) => [
                const PopupMenuItem(value: "edit", child: Text("Edit")),
                const PopupMenuItem(value: "delete", child: Text("Delete")),
              ],
            ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

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
                    color: widget.note["visibility"] == "public"
                        ? Colors.green
                        : Colors.red,

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    widget.note["visibility"],

                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                const Spacer(),

                Text(
                  widget.note["created_at"] != null
                      ? DateFormat("dd MMM yyyy HH:mm").format(
                          DateTime.parse(widget.note["created_at"]).toLocal(),
                        )
                      : "",
                ),
              ],
            ),

            const SizedBox(height: 25),

            Text(
              widget.note["title"],
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                CircleAvatar(
                  radius: 14,

                  backgroundImage: widget.note["profile_picture"] != null
                      ? NetworkImage(
                          "${Api.baseUrl}/uploads/profile/${widget.note!["profile_picture"]}",
                        )
                      : null,

                  child: widget.note["profile_picture"] == null
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: currentUserId == widget.note["user_id"]
                            ? Text(
                                "By ${widget.note["name"]}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B6B9B),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UserProfilePage(
                                        userId: widget.note["user_id"],
                                      ),
                                    ),
                                  );
                                },

                                child: Text(
                                  "By ${widget.note["name"]}",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4B6B9B),
                                  ),
                                ),
                              ),
                      ),

                      if (widget.note["role"] == "mentor")
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: const Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 14,
                              ),

                              SizedBox(width: 4),

                              Text(
                                "Mentor",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              widget.note["description"] ?? "",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            if (widget.note["files"] != null && widget.note["files"].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Attachment",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  Column(
                    children: List.generate(widget.note["files"].length, (
                      index,
                    ) {
                      final file = widget.note["files"][index];
                      final isImg = file["file_type"] == "image";

                      if (isImg) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),

                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImageViewerPage(
                                    imageUrl:
                                        "${Api.baseUrl}/uploads/notes/${file["file_url"]}",
                                  ),
                                ),
                              );
                            },

                            onLongPress: () async {
                              await downloadFile(
                                "${Api.baseUrl}/notes/download/${file["file_url"]}",
                                file["file_url"],
                              );
                            },

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),

                              child: Image.network(
                                "${Api.baseUrl}/uploads/notes/${file["file_url"]}",
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),

                        child: InkWell(
                          onTap: () async {
                            await downloadFile(
                              "${Api.baseUrl}/notes/download/${file["file_url"]}",
                              file["file_url"],
                            );
                          },

                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(15),
                            ),

                            child: Row(
                              children: [
                                const Icon(Icons.download, color: Colors.white),
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    file["file_url"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            const Text(
              "Comments",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            if (replyingTo != null)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    Expanded(child: Text("Replying to $replyingUser")),

                    IconButton(
                      onPressed: () {
                        setState(() {
                          replyingTo = null;

                          replyingUser = null;
                        });
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,

                    decoration: InputDecoration(
                      hintText: "Write comment...",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  onPressed: sendComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (loadingComments)
              const Center(child: CircularProgressIndicator()),

            ...comments.map((comment) {
              final isReply = comment["parent_id"] != null;

              return Container(
                margin: EdgeInsets.only(bottom: 15, left: isReply ? 40 : 0),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,

                  borderRadius: BorderRadius.circular(15),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,

                          backgroundImage: comment["profile_picture"] != null
                              ? NetworkImage(
                                  "${Api.baseUrl}/uploads/profile/${comment!["profile_picture"]}",
                                )
                              : null,

                          child: comment["profile_picture"] == null
                              ? const Icon(Icons.person, size: 18)
                              : null,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          comment["name"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        if (comment["user_id"] == widget.note["user_id"])
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),

                            child: const Text(
                              "Author",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(comment["comment"]),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              replyingTo = comment["id"];
                              replyingUser = comment["name"];
                            });
                          },

                          child: const Text(
                            "Reply",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        if (currentUserId == comment["user_id"])
                          GestureDetector(
                            onTap: () async {
                              final result = await CommentService.deleteComment(
                                comment["id"],
                              );

                              if (result["status"] == 200) {
                                await loadComments();
                              }
                            },

                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
