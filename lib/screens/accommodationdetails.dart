import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; 
import 'accommodationsearch.dart';
import 'guestdetails.dart'; // Make sure this import matches your filename

class AccommodationDetailsScreen extends StatefulWidget {
  final Accommodation resort;
  final String stateName;

  const AccommodationDetailsScreen({
    super.key,
    required this.resort,
    required this.stateName,
  });

  @override
  State<AccommodationDetailsScreen> createState() => _AccommodationDetailsScreenState();
}

class _AccommodationDetailsScreenState extends State<AccommodationDetailsScreen> {
  // Selection State
  DateTimeRange? selectedDateRange;
  int? adults; 
  int? children;
  int? rooms;

  // Sail&StayMY Theme Colors
  final Color primaryNavy = const Color(0xFF0C004B);
  final Color turquoiseAccent = const Color(0xFF56E3D8);
  final Color deepPurple = const Color(0xFF673AB7);

  Future<void> _selectDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: deepPurple,
              onPrimary: turquoiseAccent,
              surface: primaryNavy,
              onSurface: Colors.white,
              secondary: turquoiseAccent, 
            ),
            scaffoldBackgroundColor: primaryNavy,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: primaryNavy,
              headerBackgroundColor: deepPurple,
              headerForegroundColor: turquoiseAccent,
              rangeSelectionBackgroundColor: turquoiseAccent,
              dayStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              todayForegroundColor: WidgetStateProperty.all(turquoiseAccent),

            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: turquoiseAccent,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDateRange = picked);
    }
  }

  void _showGuestPicker() {
    adults ??= 2;
    children ??= 0;
    rooms ??= 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGuestCounter("Adults", adults!, (val) => setModalState(() => adults = val)),
                  _buildGuestCounter("Children", children!, (val) => setModalState(() => children = val)),
                  _buildGuestCounter("Rooms", rooms!, (val) => setModalState(() => rooms = val)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryNavy,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Text("Apply Selection", style: TextStyle(color: turquoiseAccent, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGuestCounter(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: deepPurple),
                onPressed: value > (label == "Children" ? 0 : 1) ? () => onChanged(value - 1) : null,
              ),
              Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: turquoiseAccent),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchMaps() async {
    if (widget.resort.location == null) return;
    final double lat = widget.resort.location!.latitude;
    final double lng = widget.resort.location!.longitude;
    final Uri uri = Uri.parse("geo:$lat,$lng?q=$lat,$lng");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateTitle = "Check in/Check out dates";
    String? dateSubtitle;
    if (selectedDateRange != null) {
      int nights = selectedDateRange!.duration.inDays;
      dateTitle = "${DateFormat('dd MMM').format(selectedDateRange!.start)} - ${DateFormat('dd MMM').format(selectedDateRange!.end)}";
      dateSubtitle = "($nights ${nights == 1 ? 'night' : 'nights'})";
    }

    String guestTitle = "Guests and rooms";
    String? guestSubtitle;
    if (adults != null) {
      guestSubtitle = "$adults adults, $rooms room${rooms! > 1 ? 's' : ''}";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: primaryNavy,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(widget.resort.imageUrl, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      widget.resort.name,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: turquoiseAccent),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _launchMaps,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.grey, size: 28),
                          const SizedBox(width: 8),
                          Text(widget.resort.area, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryNavy)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    _buildComplexButton(dateTitle, dateSubtitle, _selectDates),
                    const SizedBox(height: 12),
                    _buildComplexButton(guestTitle, guestSubtitle, _showGuestPicker),
                    
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        "Select your room",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryNavy),
                      ),
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Accommodations')
                          .doc(widget.stateName)
                          .collection('resorts')
                          .doc(widget.resort.id)
                          .collection('rooms')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No rooms available."));
                        }
                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            final roomData = doc.data() as Map<String, dynamic>;
                            return RoomItemWidget(
                              room: roomData, 
                              navy: primaryNavy, 
                              turquoise: turquoiseAccent,
                              resortName: widget.resort.name,
                              selectedDates: selectedDateRange,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplexButton(String title, String? subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: primaryNavy,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white, 
                fontSize: subtitle == null ? 16 : 14, 
                fontWeight: subtitle == null ? FontWeight.bold : FontWeight.w400
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: turquoiseAccent, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RoomItemWidget extends StatefulWidget {
  final Map<String, dynamic> room;
  final Color navy;
  final Color turquoise;
  final String resortName;
  final DateTimeRange? selectedDates;

  const RoomItemWidget({
    super.key,
    required this.room,
    required this.navy,
    required this.turquoise,
    required this.resortName,
    this.selectedDates,
  });

  @override
  State<RoomItemWidget> createState() => _RoomItemWidgetState();
}

class _RoomItemWidgetState extends State<RoomItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.room['roomName'] ?? 'Room',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.navy),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.room['roomImage'] != null
                    ? Image.network(widget.room['roomImage'], width: 160, height: 110, fit: BoxFit.cover)
                    : Container(width: 160, height: 110, color: Colors.grey[200], child: const Icon(Icons.hotel)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      "RM ${widget.room['price'] ?? '0'}.00",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: widget.navy),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.selectedDates == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select your stay dates first!"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuestDetailsScreen(
                              resortName: widget.resortName,
                              room: widget.room,
                              selectedDates: widget.selectedDates!,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.navy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Book", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}