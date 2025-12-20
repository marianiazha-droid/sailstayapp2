import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sailstayapp2/screens/islanddirectory.dart';
import 'package:sailstayapp2/screens/accommodationsearch.dart';
import 'package:sailstayapp2/screens/islandlist.dart';
import 'package:sailstayapp2/models/island.dart';
import 'package:sailstayapp2/screens/islanddetails.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController =
      MapController(); // Controller to handle direct movement
  Map<String, dynamic>? _selectedIsland;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // SRS REQ 4: Retrieve data from external APIs (Google Maps Search)
  Future<void> _launchGoogleMaps(String placeName) async {
    final String query = Uri.encodeComponent(placeName);
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$query",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch Google Maps")),
        );
      }
    }
  }

  // Helper to show Jetty Navigation options when the boat pin is tapped
  void _showJettyOptions(String jettyName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 15, right: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Row(
          children: [
            const Icon(Icons.directions_boat, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                jettyName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _launchGoogleMaps(jettyName),
              child: const Text(
                "VIEW ON MAPS",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- INTERACTIVE MAP MODULE ---
  Widget _buildMapView() {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Islands').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return const Center(child: Text("Error loading map"));
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<Marker> mapMarkers = [];
            final List<Polyline> itineraryRoutes = [];

            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final dynamic islandLoc = data['location'];
              final dynamic jettyLoc = data['jettyLocation'];
              final String jettyName = data['departureLocation'] ?? 'Jetty';

              // 1. JETTY PIN (Direct movement on tap)
              if (jettyLoc is GeoPoint) {
                mapMarkers.add(
                  Marker(
                    point: LatLng(jettyLoc.latitude, jettyLoc.longitude),
                    width: 100,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        _showJettyOptions(jettyName);
                        // ACTION: Direct move to Jetty location
                        _mapController.move(
                          LatLng(jettyLoc.latitude, jettyLoc.longitude),
                          12.0,
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[800],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              jettyName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.directions_boat_filled,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // 2. ISLAND PIN (Direct movement + Preview Card on tap)
              if (islandLoc is GeoPoint) {
                mapMarkers.add(
                  Marker(
                    point: LatLng(islandLoc.latitude, islandLoc.longitude),
                    width: 120,
                    height: 80,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedIsland = data);
                        // ACTION: Direct move to Island location with closer zoom
                        _mapController.move(
                          LatLng(islandLoc.latitude, islandLoc.longitude),
                          11.5,
                        );
                      },
                      child: _buildMarkerWidget(
                        data['price']?.toString() ?? '0',
                      ),
                    ),
                  ),
                );

                // 3. DRAW ROUTE
                if (_selectedIsland != null &&
                    _selectedIsland!['name'] == data['name'] &&
                    jettyLoc is GeoPoint) {
                  itineraryRoutes.add(
                    Polyline(
                      points: [
                        LatLng(jettyLoc.latitude, jettyLoc.longitude),
                        LatLng(islandLoc.latitude, islandLoc.longitude),
                      ],
                      color: const Color(0xFF2E1A78).withOpacity(0.7),
                      strokeWidth: 4.0,
                      isDotted: true,
                    ),
                  );
                }
              }
            }

            return FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                // Centered to show both West Malaysia and Borneo initially
                initialCenter: LatLng(3.5, 108.5),
                initialZoom: 4.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.sailstayapp2',
                ),
                PolylineLayer(polylines: itineraryRoutes),
                MarkerLayer(markers: mapMarkers),
              ],
            );
          },
        ),

        if (_selectedIsland != null)
          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: _buildIslandPreviewCard(),
          ),
      ],
    );
  }

  Widget _buildMarkerWidget(String price) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2E1A78),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Text(
            "From RM$price",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Icon(Icons.location_on, color: Colors.red, size: 35),
      ],
    );
  }

  Widget _buildIslandPreviewCard() {
    final String islandName = _selectedIsland!['name'] ?? 'Island';
    final String jettyName =
        _selectedIsland!['departureLocation'] ?? 'Mainland';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _selectedIsland!['imageURL'] ?? '',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      islandName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_boat,
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "From: $jettyName",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _selectedIsland = null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  "From RM${_selectedIsland!['price']}",
                  style: const TextStyle(
                    color: Color(0xFF2E1A78),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _launchGoogleMaps(islandName),
                icon: const Icon(Icons.travel_explore, size: 18),
                label: const Text("Google Maps"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_currentIndex == 1) {
      bodyContent = _buildBookingTabContent();
    } else if (_currentIndex == 2) {
      bodyContent = _buildMapView();
    } else {
      bodyContent = _buildHomeMainContent(context);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: _buildBottomNav(),
      body: bodyContent,
    );
  }

  Widget _buildHomeMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildCategories(context),
          const SizedBox(height: 24),
          _buildRecommended(),
        ],
      ),
    );
  }

  Widget _buildBookingTabContent() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(
            color: Color(0xFF0C004B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Bookings')
            .orderBy('bookingDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error"));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data?.docs ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) => _buildBookingListItem(
              docs[index].data() as Map<String, dynamic>,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingListItem(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              data['imageURL'] ?? '',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const Icon(Icons.image, size: 40),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['islandName'] ?? 'Island',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  data['accommodationName'] ?? 'Accommodation',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  data['price'] ?? 'RM 0',
                  style: const TextStyle(
                    color: Color(0xFF2E1A78),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8E6CFF), Color(0xFF5CE1E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi, Mryn!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Choose island for your next trip',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IslandListScreen(
                  searchQuery: value.trim(),
                  selectedState: "",
                  maxPrice: 10000.0,
                  selectedActivities: const [],
                ),
              ),
            );
        },
        decoration: InputDecoration(
          hintText: 'Search island...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _searchController.clear(),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CategoryItem(
          icon: Icons.beach_access,
          label: 'Island Directory',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IslandDirectoryScreen()),
          ),
        ),
        // UPDATED: Island Hopping now navigates to the list screen showing ALL islands
        _CategoryItem(
          icon: Icons.map,
          label: 'Island Packages',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const IslandListScreen(),
            ),
          ),
        ),
        _CategoryItem(
          icon: Icons.hotel,
          label: 'Accommodation',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AccommodationSearchResultsScreen(),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildRecommended() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Islands')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Text("Error");
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              final recommendedDocs = (snapshot.data?.docs ?? []).where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['isRecommended'] == true ||
                    data['IsRecommended'] == true;
              }).toList();
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.70,
                ),
                itemCount: recommendedDocs.length,
                itemBuilder: (context, index) {
                  final data =
                      recommendedDocs[index].data() as Map<String, dynamic>;

                  // Helper variables for casting
                  final double basePrice = (data['price'] is num)
                      ? (data['price'] as num).toDouble()
                      : 0.0;

                  return _RecommendedCard(
                    image: data['imageURL']?.toString() ?? '',
                    location: data['state']?.toString() ?? '',
                    title: data['name']?.toString() ?? '',
                    price: "RM ${data['price']?.toString() ?? '0'}",
                    rating: data['rating']?.toString() ?? '0.0',
                    onTap: () {
                      // Build Island object and navigate
                      final islandObj = Island(
                        name: data['name'] ?? 'Island',
                        imageURL: data['imageURL'] ?? '',
                        highlights:
                            data['description'] ??
                            data['highlights'] ??
                            'No description available.',
                        packageType: data['packageType'] ?? 'Join In Tour',
                        price: basePrice,
                        state: data['state'] ?? '',
                        priceMin: (data['priceMin'] is num)
                            ? (data['priceMin'] as num).toDouble()
                            : 0.0,
                        priceMax: (data['priceMax'] is num)
                            ? (data['priceMax'] as num).toDouble()
                            : 2000.0,
                        priceAdult: (data['priceAdult'] is num)
                            ? (data['priceAdult'] as num).toDouble()
                            : basePrice,
                        priceChild: (data['priceChild'] is num)
                            ? (data['priceChild'] as num).toDouble()
                            : (basePrice * 0.7),
                        time: data['time'] ?? '08:00am - 17:00pm',
                        departureLocation:
                            data['departureLocation'] ?? 'Main Jetty',
                        activitytype: (data['activities'] is List)
                            ? List<String>.from(data['activities'])
                            : ['General'],
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              IslandDetailsScreen(island: islandObj),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white60,
      backgroundColor: const Color(0xFF2E1A78),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _CategoryItem({required this.icon, required this.label, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final String image;
  final String location;
  final String title;
  final String price;
  final String rating;
  final VoidCallback onTap;
  const _RecommendedCard({
    required this.image,
    required this.location,
    required this.title,
    required this.price,
    required this.rating,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Image.network(
                  image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF2E1A78),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
