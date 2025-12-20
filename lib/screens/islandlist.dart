import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sailstayapp2/models/island.dart';
import 'package:sailstayapp2/widgets/islandcard.dart';

class IslandListScreen extends StatelessWidget {
  // Made these nullable so they are optional
  final String? selectedState;
  final double? maxPrice;
  final List<String>? selectedActivities;
  final String? searchQuery; 

  const IslandListScreen({
    super.key,
    this.selectedState,      // Removed 'required'
    this.maxPrice,           // Removed 'required'
    this.selectedActivities, // Removed 'required'
    this.searchQuery, 
  });

  Future<List<Island>> fetchFilteredIslands() async {
    try {
      // Fetch all islands from Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('Islands').get();

      if (snapshot.docs.isEmpty) {
        print('Firestore collection is empty');
        return [];
      }

      // Convert documents to Island objects
      final islands = snapshot.docs.map((doc) {
        final data = doc.data();
        return Island.fromMap(data);
      }).toList();

      // --- 1. SEARCH LOGIC ---
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final query = searchQuery!.toLowerCase();
        return islands.where((island) {
          return island.name.toLowerCase().contains(query) || 
                 island.state.toLowerCase().contains(query);
        }).toList();
      }

      // --- 2. VIEW ALL LOGIC (FOR ISLAND HOPPING) ---
      // If we don't have a state, price, or search query, return ALL islands
      if (selectedState == null && maxPrice == null && searchQuery == null) {
        return islands;
      }

      // --- 3. FILTER LOGIC (FOR DIRECTORY) ---
      final filteredIslands = islands.where((island) {
        // State check
        final matchesState = selectedState == null || 
            island.state.toLowerCase() == selectedState!.toLowerCase();

        // Price check
        final matchesPrice = maxPrice == null || 
            (island.priceMin <= maxPrice! && island.priceMax >= maxPrice!);

        // Activities check
        final matchesActivity = selectedActivities == null || 
            selectedActivities!.isEmpty ||
            island.activitytype.any(
              (activity) => selectedActivities!
                  .map((a) => a.toLowerCase())
                  .contains(activity.toLowerCase()),
            );

        return matchesState && matchesPrice && matchesActivity;
      }).toList();

      // Fallback: if filters returned nothing, show at least the state matches
      if (filteredIslands.isEmpty && selectedState != null) {
        return islands.where((island) =>
            island.state.toLowerCase() == selectedState!.toLowerCase()).toList();
      }

      return filteredIslands;
    } catch (e) {
      print('Error fetching islands: $e');
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
              : (selectedState == null ? 'All Island Packages' : 'Popular'),
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