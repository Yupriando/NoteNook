import 'package:flutter/material.dart';
import 'package:frontend/utils/api.dart';

class UserCard extends StatelessWidget {
  final Map user;
  final VoidCallback onTap;
  final String? subtitle;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),

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

        child: Row(
          children: [
            CircleAvatar(
              radius: 28,

              backgroundImage: user["profile_picture"] != null
                  ? NetworkImage(
                      "${Api.baseUrl}/uploads/profile/${user["profile_picture"]}",
                    )
                  : null,

              child: user["profile_picture"] == null
                  ? const Icon(Icons.person)
                  : null,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user["name"],
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (user["role"] == "mentor")
                        Container(
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
                              Icon(
                                Icons.verified,
                                color: Color(0xFF0F6FFF),
                                size: 12,
                              ),

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

                  if (subtitle != null) ...[
                    const SizedBox(height: 4),

                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
