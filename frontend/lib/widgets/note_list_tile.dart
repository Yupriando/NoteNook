import 'package:flutter/material.dart';

class NoteListTile extends StatelessWidget {
  final Map note;
  final VoidCallback onTap;
  final bool bookmarked;

  const NoteListTile({
    super.key,
    required this.note,
    required this.onTap,
    this.bookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: ListTile(
        onTap: onTap,

        leading: Icon(
          bookmarked ? Icons.star : Icons.description_outlined,

          color: bookmarked ? Colors.amber : const Color(0xFF0077FF),
        ),

        title: Text(
          note["title"] ?? "",

          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Text(note["visibility"] ?? ""),
      ),
    );
  }
}
