import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'accommodationdetails.dart';

/// ------------------------------
/// 1. DATA MODEL (FIXED: Added location)
/// ------------------------------
class Accommodation {
  final String id;
  final String name;
  final String area;
  final String price;
  final String imageUrl;
  final GeoPoint? location; // Added to fix the 'undefined_getter' error

  Accommodation({
    required this.id,
    required this.name,
    required this.area,
    required this.price,
    required this.imageUrl,
    this.location,
  });

  factory Accommodation.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Accommodation(
      id: doc.id,
      name: data?['name']?.toString() ?? 'Name Missing',
      area: data?['area']?.toString() ?? 'Area Missing',
      price: data?['price'] != null ? 'From RM${data!['price']}.00' : 'Price Missing',
      imageUrl: data?['imageURL']?.toString() ?? 'https://via.placeholder.com/300',
      location: data?['location'] as GeoPoint?, // Mapping the GeoPoint
    );
  }
}

/// ------------------------------
/// 2. SEARCH RESULTS SCREEN (Updated with Navigation)
/// ------------------------------
class AccommodationSearchResultsScreen extends StatefulWidget {
  const AccommodationSearchResultsScreen({super.key});

  @override
  State<AccommodationSearchResultsScreen> createState() => _AccommodationSearchResultsScreenState();
}

class _AccommodationSearchResultsScreenState extends State<AccommodationSearchResultsScreen> {
  List<Accommodation> _filteredAccommodations = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  final Color primaryColor = const Color(0xFF4C2A98);
  final TextEditingController _searchController = TextEditingController();

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredAccommodations = [];
      _hasSearched = false;
      _isLoading = false;
    });
  }

  Future<void> _performNestedAreaSearch() async {
    final rawSearchTerm = _searchController.text.trim();
    if (rawSearchTerm.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _filteredAccommodations.clear();
    });

    try {
      final stateSnapshot = await FirebaseFirestore.instance
          .collection('Accommodations')
          .doc(rawSearchTerm)
          .collection('resorts')
          .get();

      List<Accommodation> results = [];
      if (stateSnapshot.docs.isNotEmpty) {
        results = stateSnapshot.docs.map((doc) => Accommodation.fromFirestore(doc)).toList();
      } else {
        final areaSnapshot = await FirebaseFirestore.instance
            .collectionGroup('resorts')
            .where('area', isEqualTo: rawSearchTerm)
            .get();
        results = areaSnapshot.docs.map((doc) => Accommodation.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
      }

      setState(() {
        _filteredAccommodations = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Accommodation Search'), backgroundColor: primaryColor, foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: _buildSearchBar()),
          Expanded(child: _buildResultsState()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black,blurRadius: 5)]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search, size: 20), hintText: 'Search "Sabah"...', border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15), suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch) : null),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _performNestedAreaSearch(),
            ),
          ),
          TextButton(onPressed: _performNestedAreaSearch, child: Text('Search', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildResultsState() {
    if (_isLoading) return Center(child: CircularProgressIndicator(color: primaryColor));
    if (!_hasSearched) return const SizedBox.shrink();
    if (_filteredAccommodations.isEmpty) return const Center(child: Text('No resorts found. Try "Sabah".'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredAccommodations.length,
      itemBuilder: (context, index) {
        final item = _filteredAccommodations[index];
        return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AccommodationDetailsScreen(resort: item, stateName: _searchController.text.trim())));
          },
          child: AccommodationListItem(item: item, primaryColor: primaryColor),
        );
      },
    );
  }
}

class AccommodationListItem extends StatelessWidget {
  final Accommodation item;
  final Color primaryColor;
  const AccommodationListItem({super.key, required this.item, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(item.imageUrl, height: 180, fit: BoxFit.cover, errorBuilder: (_, _, ___) => const Icon(Icons.broken_image))),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(item.area, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const Spacer(),
                    Text(item.price, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



