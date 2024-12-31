import 'package:flutter/material.dart';
import 'dart:convert';

class FullscreenImage extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const FullscreenImage(
      {Key? key, required this.images, required this.initialIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text(""),
      ),
      backgroundColor: Colors.black,
      body: PageView.builder(
        itemCount: images.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Resmin üzerine tıklandığında hiçbir şey yapma
            },
            child: _buildImage(images[index]),
          );
        },
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, fit: BoxFit.contain);
    } else {
      try {
        return Image.memory(
          base64Decode(imagePath),
          fit: BoxFit.contain,
        );
      } catch (e) {
        print("Error decoding or loading image: $e");
        return const Center(child: Text("Error loading image"));
      }
    }
  }
}
