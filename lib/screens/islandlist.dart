import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sailstayapp2/models/island.dart';
import 'package:sailstayapp2/widgets/islandcard.dart';

class IslandListScreen extends StatelessWidget {
  final String? selectedState;
  final double? maxPrice;
  final List<String>? selectedActivities;
  final String? searchQuery;

  const IslandListScreen({
    super.key,
    this.selectedState,
    this.maxPrice,
    this.selectedActivities,
    this.searchQuery,
  });

  Future<List<Island>> fetchFilteredIslands() async {
    try {
      // 1️⃣ Fetch all islands from Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('Islands').get();

      if (snapshot.docs.isEmpty) {
        debugPrint('Firestore collection is empty');
        return [];
      }

      // 2️⃣ Convert Firestore docs to Island objects
      final islands = snapshot.docs
          .map((doc) => Island.fromMap(doc.data()))
          .toList();

      // 3️⃣ SEARCH (highest priority)
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final query = searchQuery!.toLowerCase().trim();
        return islands.where((island) {
          return island.name.toLowerCase().contains(query) ||
              island.state.toLowerCase().contains(query);
        }).toList();
      }

      // 4️⃣ VIEW ALL (no filters selected)
      if (selectedState == null &&
          maxPrice == null &&
          (selectedActivities == null || selectedActivities!.isEmpty)) {
        return islands;
      }

   final filteredIslands = islands.where((island) {
  // ✅ State
  final matchesState = selectedState == null ||
      island.state.toLowerCase().trim() ==
          selectedState!.toLowerCase().trim();

  // ✅ Price
  final matchesPrice = maxPrice == null ||
      (island.priceMin <= maxPrice! &&
          island.priceMax >= maxPrice!);

  // ✅ Activities (OR logic)
  final matchesActivity = selectedActivities == null ||
      selectedActivities!.isEmpty ||
      island.activitytype.any(
        (activity) => selectedActivities!
            .map((a) => a.toLowerCase().trim())
            .contains(activity.toLowerCase().trim()),
      );

  return matchesState && matchesPrice && matchesActivity;
}).toList();


      // 6️⃣ Fallback: show at least same-state islands
      if (filteredIslands.isEmpty && selectedState != null) {
        return islands
            .where((island) =>
                island.state.toLowerCase().trim() ==
                selectedState!.toLowerCase().trim())
            .toList();
      }

      return filteredIslands;
    } catch (e) {
      debugPrint('Error fetching islands: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B0A78),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF2B0A78),
        elevation: 0,
        title: Text(
          searchQuery != null
              ? 'Results for "$searchQuery"'
              : (selectedState == null
                  ? 'All Island Packages'
                  : 'Popular'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Island>>(
          future: fetchFilteredIslands(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final islands = snapshot.data ?? [];

            if (islands.isEmpty) {
              return const Center(
                child: Text(
                  'No islands found',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              itemCount: islands.length,
              itemBuilder: (context, index) {
                return IslandCard(island: islands[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
