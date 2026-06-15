import 'package:flutter/material.dart';

class ProfileStatItem extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;

  const ProfileStatItem({
    super.key,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0077FF),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            label,
            style: TextStyle(
              color: onTap != null
                  ? const Color(0xFF0077FF)
                  : const Color(0xFF4B6B9B),

              fontSize: 14,

              fontWeight: onTap != null ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
