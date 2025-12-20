import 'package:flutter/material.dart';
import 'package:sailstayapp2/models/island.dart';
import 'package:sailstayapp2/screens/islanddetails.dart';

class IslandCard extends StatelessWidget {
  final Island island;

  const IslandCard({
    super.key,
    required this.island,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          // Optional: tap whole card
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IslandDetailsScreen(island: island),
            ),
          );
        },
        child: Stack(
          children: [
            // Island Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                island.imageURL,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Island Name
            Positioned(
              left: 16,
              bottom: 16,
              child: Text(
                island.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 6),
                  ],
                ),
              ),
            ),

            // Arrow Button (CLICKABLE)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  // Tap only the arrow navigates too
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IslandDetailsScreen(island: island),
                    ),
                  );
                },
                child: Container(
                  width: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4FD1C5),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




