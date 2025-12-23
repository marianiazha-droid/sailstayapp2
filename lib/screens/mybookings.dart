import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyBookings extends StatelessWidget {
  const MyBookings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(color: Color(0xFF0C004B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // This fetches EVERYTHING in your Bookings collection
        stream: FirebaseFirestore.instance.collection('Bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading data"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // This checks if there is actually any data in that collection
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bookings found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String docId = doc.id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailScreen(data: data, docId: docId),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.beach_access, size: 40, color: Color(0xFF0C004B)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Using the exact field 'islandName' from your screenshot
                            Text(
                              data['islandName'] ?? 'No Name',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            // Using 'date' from your screenshot
                            Text(
                              data['date'] ?? 'No Date',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 5),
                            // Using 'status' from your screenshot
                            Text(
                              data['status'] ?? 'No Status',
                              style: const TextStyle(
                                color: Color(0xFF00B4D8),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const BookingDetailScreen({super.key, required this.data, required this.docId});

  @override
  Widget build(BuildContext context) {
    // Theme colors
    const Color navyBlue = Color(0xFF2E1A78);
    const Color turquoise = Color(0xFF5CE1E6);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Booking Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: navyBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Status:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      data['status'] ?? 'Pending',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: turquoise,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 1, color: Colors.grey),

                // Customer Info
                Text("Customer Information", style: TextStyle(fontWeight: FontWeight.bold, color: navyBlue, fontSize: 16)),
                const SizedBox(height: 8),
                Text("Name: ${data['customerName'] ?? 'N/A'}"),
                Text("Email: ${data['customerEmail'] ?? 'N/A'}"),
                const SizedBox(height: 20),

                // Booking Info
                Text("Booking Details", style: TextStyle(fontWeight: FontWeight.bold, color: navyBlue, fontSize: 16)),
                const SizedBox(height: 8),
                Text("Island: ${data['islandName'] ?? 'N/A'}"),
                Text("Accommodation: ${data['accommodationName'] ?? 'N/A'}"),
                Text("Date: ${data['date'] ?? 'N/A'}"),
                const SizedBox(height: 8),
                Text(
                  "Total Amount: RM ${data['totalAmount'] ?? '0'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2E1A78), // Navy Blue
                  ),
                ),
                const SizedBox(height: 30),

                // Delete Button with Gradient
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E1A78), Color(0xFF5CE1E6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('Bookings').doc(docId).delete();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Booking deleted successfully")),
                        );
                      },
                      child: const Text(
                        "Delete Booking",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
