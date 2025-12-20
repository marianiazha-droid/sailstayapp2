import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sailstayapp2/screens/payment.dart'; // CONNECTED: Import added

class GuestDetailsScreen extends StatefulWidget {
  final String resortName;
  final Map<String, dynamic> room;
  final DateTimeRange selectedDates;

  const GuestDetailsScreen({
    super.key,
    required this.resortName,
    required this.room,
    required this.selectedDates,
  });

  @override
  State<GuestDetailsScreen> createState() => _GuestDetailsScreenState();
}

class _GuestDetailsScreenState extends State<GuestDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  bool _idConsent = false; 

  final Color primaryNavy = const Color(0xFF0C004B);

  @override
  Widget build(BuildContext context) {
    int nights = widget.selectedDates.duration.inDays;
    String dateRange = "${DateFormat('dd MMM').format(widget.selectedDates.start)} - ${DateFormat('dd MMM').format(widget.selectedDates.end)} ($nights night)";

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Image.network(widget.room['roomImage'], fit: BoxFit.cover),
          ),
          
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 120), 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            widget.resortName,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: primaryNavy),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          widget.room['roomName'] ?? "Deluxe Double Room",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryNavy),
                        ),
                        const SizedBox(height: 20),
                        
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildInfoRow(Icons.calendar_month_outlined, dateRange),
                                  const SizedBox(height: 15),
                                  _buildInfoRow(Icons.bed_outlined, widget.room['bed'] ?? "1 king bed"),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(widget.room['roomImage'], width: 140, height: 90, fit: BoxFit.cover),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 35),
                        Text("Guest Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
                        const SizedBox(height: 20),
                        
                        _buildTextField("Name*", _nameController),
                        _buildTextField("Email address*", _emailController),
                        _buildTextField("Phone number*", _phoneController),
                        
                        const SizedBox(height: 20),
                        
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            Checkbox(
                              value: _idConsent, 
                              onChanged: (val) => setState(() => _idConsent = val!),
                              activeColor: primaryNavy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10), 
                                child: Text(
                                  "I understand that any ID information provided will only be used for booking travel and leisure activities that require name registration. I also understand that Sail&StayMY will protect this information using encryption and other security methods, and Sail&StayMY will only authorize its use to relevant third parties for specific transactions.",
                                  style: TextStyle(fontSize: 11, color: Colors.grey[700], height: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),

                        // PAY NOW BUTTON (Logic Updated)
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() && _idConsent) {
                              // CONNECTED: Packaging data for PaymentScreen
                              final bookingData = {
                                'resortName': widget.resortName,
                                'roomName': widget.room['roomName'],
                                'price': widget.room['price'], // Make sure price exists in your room map
                                'roomImage': widget.room['roomImage'],
                                'selectedDates': dateRange,
                                'guestName': _nameController.text,
                                'guestEmail': _emailController.text,
                                'guestPhone': _phoneController.text,
                              };

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentScreen(bookingData: bookingData),
                                ),
                              );
                            } else if (!_idConsent) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please agree to the ID information terms")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryNavy,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Pay Now", 
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 24),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: primaryNavy, fontSize: 13, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold, fontSize: 14)),
          TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Please enter",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              isDense: true,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 0.5)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0C004B))),
            ),
            validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
          ),
        ],
      ),
    );
  }
}