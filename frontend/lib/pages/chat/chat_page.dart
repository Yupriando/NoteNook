import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/media/image_viewer_page.dart';
import 'package:frontend/services/chat_service.dart';
import 'package:frontend/utils/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:frontend/pages/profile/user_profile_page.dart';

class ChatPage extends StatefulWidget {
  final int userId;
  final String userName;
  final String? profilePicture;
  final String? role;

  const ChatPage({
    super.key,
    required this.userId,
    required this.userName,
    this.profilePicture,
    this.role,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final picker = ImagePicker();

  List messages = [];
  List<File> selectedFiles = [];

  bool loading = true;
  bool isOnline = false;
  bool isTyping = false;

  IO.Socket? socket;

  int? myId;

  String lastSeenText = "";

  Future loadMessages() async {
    final result = await ChatService.getMessages(widget.userId);

    print("MESSAGES:");
    print(result);

    if (result["status"] == 200) {
      setState(() {
        messages = result["data"];

        loading = false;
      });

      scrollToBottom();
    }
  }

  Future markAsRead() async {
    final result = await ChatService.markRead(widget.userId);

    if (result["status"] == 200) {
      socket?.emit("message_read", {"targetUserId": widget.userId});
    }
  }

  Future downloadFile(String url, String filename) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (!kIsWeb) {
        await Permission.manageExternalStorage.request();

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
      }
    } catch (e) {
      print(e);
    }
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

    myId = decoded["id"];

    socket = IO.io(
      Api.baseUrl,

      IO.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .build(),
    );

    socket!.onConnect((_) async {
      socket!.emit("join", myId.toString());
      socket!.emit("get_last_seen", widget.userId);
      await markAsRead();
    });

    socket!.connect();

    socket!.on("last_seen", (data) {
      if (data != null && mounted) {
        final time = DateTime.parse(data).toLocal();

        setState(() {
          lastSeenText = "last seen ${DateFormat("HH:mm").format(time)}";
        });
      }
    });

    socket!.on("receive_message", (data) async {
      if (data["sender_id"] == widget.userId ||
          data["receiver_id"] == widget.userId) {
        await loadMessages();
        await markAsRead();
        scrollToBottom();
      }
    });

    socket!.on("online_users", (users) {
      if (mounted) {
        setState(() {
          final online = users.contains(widget.userId.toString());
          isOnline = online;

          if (online) {
            lastSeenText = "";
          }
        });
      }
    });

    socket!.on("typing", (data) {
      if (data["senderId"] == widget.userId) {
        setState(() {
          isTyping = true;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              isTyping = false;
            });
          }
        });
      }
    });

    socket!.on("message_read", (_) async {
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        await loadMessages();
      }
    });
  }

  Future initChat() async {
    await loadMessages();
    await connectSocket();
  }

  Future sendMessage() async {
    if (messageController.text.trim().isEmpty && selectedFiles.isEmpty) {
      return;
    }

    final result = await ChatService.sendMessage(
      receiverId: widget.userId,
      message: messageController.text,
      files: selectedFiles,
    );

    if (result["status"] == 201) {
      messageController.clear();

      setState(() {
        selectedFiles.clear();
      });
      await loadMessages();
      scrollToBottom();
    }
  }

  Future pickImage() async {
    if (kIsWeb) {
      return;
    }

    final images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedFiles.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  Future pickFile() async {
    if (kIsWeb) {
      return;
    }

    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        selectedFiles.addAll(result.files.map((e) => File(e.path!)));
      });
    }
  }

  String formatChatDate(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Today";
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return "Yesterday";
    }

    return DateFormat("d MMMM yyyy").format(date);
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,

          duration: const Duration(milliseconds: 300),

          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print("ROLE CHAT = ${widget.role}");
    initChat();

    messageController.addListener(() {
      if (socket != null && myId != null) {
        socket!.emit("typing", {"senderId": myId, "receiverId": widget.userId});
      }
    });
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 119, 255),
        iconTheme: const IconThemeData(color: Colors.white),

        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfilePage(userId: widget.userId),
              ),
            );
          },

          child: Row(
            children: [
              CircleAvatar(
                radius: 20,

                backgroundColor: const Color(0xFFEAF2FF),
                backgroundImage: widget.profilePicture != null
                    ? NetworkImage(
                        widget.profilePicture!.startsWith("http")
                            ? widget.profilePicture!
                            : "${Api.baseUrl}/uploads/profile/${widget.profilePicture}",
                      )
                    : null,

                child: widget.profilePicture == null
                    ? const Icon(Icons.person, color: Color(0xFF0077FF))
                    : null,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.userName,

                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        if ((widget.role ?? "").trim().toLowerCase() ==
                            "mentor") ...[
                          const SizedBox(width: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: const Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 12,
                                  color: Color(0xFF0077FF),
                                ),

                                SizedBox(width: 4),

                                Text(
                                  "Mentor",
                                  style: TextStyle(
                                    color: Color(0xFF0077FF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    Text(
                      isTyping
                          ? "typing..."
                          : isOnline
                          ? "online"
                          : (lastSeenText.isEmpty ? "offline" : lastSeenText),
                      style: TextStyle(
                        fontSize: 12,
                        color: isTyping
                            ? Colors.white70
                            : isOnline
                            ? Colors.white
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0077FF)),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(15),

                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message["sender_id"] == myId;

                      if (message["created_at"] == null) {
                        return const SizedBox();
                      }

                      final currentDate = DateTime.parse(
                        message["created_at"],
                      ).toLocal();

                      bool showDateHeader = false;

                      if (index == 0) {
                        showDateHeader = true;
                      } else {
                        final previousDate = DateTime.parse(
                          messages[index - 1]["created_at"],
                        ).toLocal();

                        showDateHeader =
                            currentDate.year != previousDate.year ||
                            currentDate.month != previousDate.month ||
                            currentDate.day != previousDate.day;
                      }

                      print("MESSAGE:");
                      print(message);

                      return Column(
                        children: [
                          if (showDateHeader)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),

                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.white,

                                    border: Border.all(
                                      color: const Color(0xFFDCEBFF),
                                    ),

                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Text(
                                    formatChatDate(currentDate),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0077FF),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,

                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),

                              constraints: const BoxConstraints(maxWidth: 280),

                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFF0077FF)
                                    : const Color(0xFFDCEBFF),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],

                                border: isMe
                                    ? null
                                    : Border.all(
                                        color: const Color(0xFFE8EEF7),
                                      ),

                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: Radius.circular(isMe ? 20 : 6),
                                  bottomRight: Radius.circular(isMe ? 6 : 20),
                                ),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  if (message["files"] != null)
                                    Column(
                                      children: List.generate(message["files"].length, (
                                        fileIndex,
                                      ) {
                                        final file =
                                            message["files"][fileIndex];
                                        final isImage =
                                            file["file_type"] == "image";

                                        if (isImage) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                            ),

                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => ImageViewerPage(
                                                      imageUrl:
                                                          "${Api.baseUrl}/uploads/chat/${file["file_url"]}",
                                                    ),
                                                  ),
                                                );
                                              },

                                              onLongPress: () async {
                                                final filename =
                                                    file["file_url"]
                                                        .split("/")
                                                        .last;

                                                await downloadFile(
                                                  "${Api.baseUrl}/chat/download/${file["file_url"]}",
                                                  file["file_url"],
                                                );
                                              },

                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),

                                                child: Hero(
                                                  tag:
                                                      "${Api.baseUrl}/uploads/chat/${file["file_url"]}",

                                                  child: Image.network(
                                                    "${Api.baseUrl}/uploads/chat/${file["file_url"]}",
                                                    width: 200,
                                                    height: 200,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),

                                          child: GestureDetector(
                                            onTap: () async {
                                              final filename = file["file_url"];

                                              await downloadFile(
                                                "${Api.baseUrl}/chat/download/${file["file_url"]}",
                                                file["file_url"],
                                              );
                                            },

                                            child: Container(
                                              padding: const EdgeInsets.all(10),

                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDCEBFF),

                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),

                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,

                                                children: [
                                                  const Icon(Icons.description),

                                                  const SizedBox(width: 8),

                                                  Flexible(
                                                    child: Text(
                                                      file["file_url"],

                                                      overflow:
                                                          TextOverflow.ellipsis,

                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),

                                  if (message["message"] != null &&
                                      message["message"].toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),

                                      child: Column(
                                        crossAxisAlignment: isMe
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            message["message"],

                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Row(
                                            mainAxisSize: MainAxisSize.min,

                                            children: [
                                              Text(
                                                DateFormat("HH:mm").format(
                                                  DateTime.parse(
                                                    message["created_at"],
                                                  ).toLocal(),
                                                ),

                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isMe
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),

                                              if (isMe) ...[
                                                const SizedBox(width: 4),

                                                Icon(
                                                  message["read_status"] == 1 ||
                                                          message["read_status"] ==
                                                              true
                                                      ? Icons.done_all
                                                      : Icons.done,
                                                  size: 16,
                                                  color: Colors.white70,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          if (selectedFiles.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              color: Color(0xFFF8FAFC),

              child: Wrap(
                spacing: 10,
                runSpacing: 10,

                children: selectedFiles.map((file) {
                  return Container(
                    padding: const EdgeInsets.all(10),

                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        const Icon(Icons.attach_file, color: Color(0xFF0077FF)),
                        const SizedBox(width: 8),

                        SizedBox(
                          width: 100,
                          child: Text(
                            file.path.split("/").last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedFiles.remove(file);
                            });
                          },
                          icon: const Icon(Icons.close, size: 18),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,

            child: Row(
              children: [
                IconButton(onPressed: pickImage, icon: const Icon(Icons.image)),
                IconButton(
                  onPressed: pickFile,
                  icon: const Icon(Icons.attach_file),
                ),

                Expanded(
                  child: TextField(
                    controller: messageController,

                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFFE8EEF7)),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),

                        borderSide: const BorderSide(color: Color(0xFFDCEBFF)),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),

                        borderSide: const BorderSide(
                          color: Color(0xFF0077FF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  width: 52,
                  height: 52,

                  decoration: const BoxDecoration(
                    color: Color(0xFF0077FF),
                    shape: BoxShape.circle,
                  ),

                  child: IconButton(
                    onPressed: sendMessage,

                    icon: const Icon(Icons.send_rounded, color: Colors.white),
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
