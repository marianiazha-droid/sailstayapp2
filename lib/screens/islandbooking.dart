import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sailstayapp2/models/island.dart';
import 'package:sailstayapp2/screens/participantdetails.dart'; 

class BookingOptionsScreen extends StatefulWidget {
  final Island island;

  const BookingOptionsScreen({super.key, required this.island});

  @override
  State<BookingOptionsScreen> createState() => _BookingOptionsScreenState();
}

class _BookingOptionsScreenState extends State<BookingOptionsScreen> {
  final Color navyBlue = const Color(0xFF0C004B);
  final Color turquoise = const Color(0xFF5CE1E6);
  final Color borderBlue = const Color(0xFF1B0C5A);

  DateTime? selectedDate;
  int adultCount = 2;
  int childCount = 0;

  double get totalAmount {
    return (adultCount * widget.island.priceAdult) +
        (childCount * widget.island.priceChild);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2025, 12, 28),
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: borderBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. Background Image
          Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.island.imageURL),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // 2. Content Layer
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 280), 
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Package type",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: turquoise,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderBlue.withOpacity(0.5)),
                              ),
                              child: Text(widget.island.packageType,
                                  style: const TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(height: 24),
                            const Center(
                              child: Text("Select Options",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 12),
                            _buildOutlineBox(
                              title: "Please select an experience date",
                              child: GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: turquoise,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: borderBlue.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_month_outlined, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        selectedDate == null
                                            ? "28 Dec 2025"
                                            : DateFormat('dd MMM yyyy').format(selectedDate!),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildOutlineBox(
                              title: "Quantity",
                              child: Column(
                                children: [
                                  _buildCounterRow("Adult", widget.island.priceAdult, adultCount,
                                      (v) => setState(() => adultCount = v)),
                                  const SizedBox(height: 16),
                                  _buildCounterRow("Child", widget.island.priceChild, childCount,
                                      (v) => setState(() => childCount = v)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // ================= UPDATED NAVIGATION LOGIC =================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF060031),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Amount", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(
                          "RM ${totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 1. Check if date is selected
                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select a date first")),
                          );
                          return;
                        }

                        // 2. Navigate and Pass Data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParticipantDetailsScreen(
                              islandName: widget.island.name,
                              date: DateFormat('dd MMM yyyy').format(selectedDate!),
                              packageType: widget.island.packageType,
                              adults: adultCount,
                              children: childCount,
                              totalAmount: totalAmount,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: turquoise,
                        foregroundColor: navyBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text("Book Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildOutlineBox({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderBlue, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Divider(thickness: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCounterRow(String label, double price, int count, Function(int) onChanged) {
    return Row(
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: turquoise,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderBlue.withOpacity(0.5)),
          ),
          alignment: Alignment.center,
          child: Text(label),
        ),
        const SizedBox(width: 12),
        Text("RM  ${price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        _counterIcon(Icons.remove, () => count > 0 ? onChanged(count - 1) : null),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text("$count", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        _counterIcon(Icons.add, () => onChanged(count + 1)),
      ],
    );
  }

  Widget _counterIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }
}