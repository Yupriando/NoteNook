import 'package:flutter/material.dart';

class FolderCard extends StatelessWidget {
  final String folderName;
  final VoidCallback onTap;

  const FolderCard({
    super.key,
    required this.folderName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.folder,
              color: Color.fromARGB(255, 0, 119, 255),
              size: 45,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                folderName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}