import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/utils/api.dart';

class ConversationCard extends StatelessWidget {
  final Map chat;
  final VoidCallback onTap;

  const ConversationCard({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = chat["unread"] ?? 0;

    print(chat);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCEBFF), width: 1),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 30,

              backgroundImage:
                  chat["profile_picture"] != null &&
                      chat["profile_picture"].toString().isNotEmpty
                  ? NetworkImage(
                      "${Api.baseUrl}/uploads/profile/${chat["profile_picture"]}",
                    )
                  : null,

              child: chat["profile_picture"] == null
                  ? const Icon(Icons.person)
                  : null,
            ),

            Positioned(
              bottom: 0,
              right: 0,

              child: Container(
                width: 14,
                height: 14,

                decoration: BoxDecoration(
                  color: Colors.green,
                  border: Border.all(color: Colors.white, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),

        title: Row(
          children: [
            Expanded(
              child: Text(
                chat["name"] ?? "Unknown User",

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            if (chat["role"] == "mentor")
              Container(
                margin: const EdgeInsets.only(left: 8),

                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FF),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(Icons.verified, color: Color(0xFF0F6FFF), size: 12),

                    SizedBox(width: 4),

                    Text(
                      "Mentor",
                      style: TextStyle(
                        color: Color(0xFF0F6FFF),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),

          child: Text(
            chat["message"] ?? "📎 Attachment",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              chat["created_at"] != null
                  ? DateFormat("HH:mm").format(
                      DateTime.parse(chat["created_at"].toString()).toLocal(),
                    )
                  : "--:--",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),

            const SizedBox(height: 6),

            if (unread > 0)
              Container(
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                alignment: Alignment.center,

                decoration: const BoxDecoration(
                  color: Color(0xFF0F6FFF),
                  shape: BoxShape.circle,
                ),

                child: Text(
                  unread.toString(),

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
