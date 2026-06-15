import 'package:flutter/material.dart';

class ImageViewerPage extends StatelessWidget {
  final String imageUrl;

  const ImageViewerPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,

          child: Hero(
            tag: imageUrl,

            child: Image.network(
              imageUrl,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },

              errorBuilder: (context, error, stackTrace) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white70,
                      size: 80,
                    ),

                    SizedBox(height: 12),

                    Text(
                      "Unable to load image",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
