import 'package:flutter/material.dart';
import 'payment.dart';

class ParticipantDetailsScreen extends StatefulWidget {
  final String islandName;
  final String date;
  final String packageType;
  final int adults;
  final int children;
  final double totalAmount;

  const ParticipantDetailsScreen({
    super.key,
    required this.islandName,
    required this.date,
    required this.packageType,
    required this.adults,
    required this.children,
    required this.totalAmount,
  });

  @override
  State<ParticipantDetailsScreen> createState() =>
      _ParticipantDetailsScreenState();
}

class _ParticipantDetailsScreenState extends State<ParticipantDetailsScreen> {
  // Theme Colors
  final Color navyBlue = const Color(0xFF0C004B);
  final Color turquoise = const Color(0xFF5CE1E6);
  final Color borderBlue = const Color(0xFF1B0C5A);
  final Color darkBar = const Color(0xFF060031);

  final _formKey = GlobalKey<FormState>();

  // Controllers to capture user input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // State for validation
  bool _isAgreed = false;
  bool _validateCheckbox = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Participant Details",
          style: TextStyle(
            color: navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- BOOKING SUMMARY BOX ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: borderBlue.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.islandName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: navyBlue,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(thickness: 1),
                          ),
                          _buildInfoRow(
                            Icons.calendar_month,
                            "Date",
                            widget.date,
                          ),
                          _buildInfoRow(
                            Icons.confirmation_number_outlined,
                            "Package",
                            widget.packageType,
                          ),
                          _buildInfoRow(
                            Icons.group_outlined,
                            "Participants",
                            "${widget.adults} Adults, ${widget.children} Children",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- CONTACT INPUT SECTION ---
                    const Text(
                      "Contact Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    _buildInputField(
                      "Full Name",
                      "As per IC / Passport",
                      controller: _nameController,
                      validator: (v) => v!.isEmpty ? "Enter your name" : null,
                    ),

                    _buildInputField(
                      "Passport or MyKad Number",
                      "Enter ID number",
                      controller: _idController,
                      validator: (v) =>
                          v!.isEmpty ? "Enter your ID number" : null,
                    ),

                    _buildInputField(
                      "Email Address",
                      "example@gmail.com",
                      controller: _emailController,
                      validator: (v) =>
                          !v!.contains("@") ? "Invalid email" : null,
                    ),

                    // --- PRIVACY POLICY CHECKBOX ---
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _isAgreed,
                            activeColor: navyBlue,
                            side: BorderSide(
                              color: (_validateCheckbox && !_isAgreed)
                                  ? Colors.red
                                  : Colors.grey,
                              width: 1.5,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _isAgreed = val!;
                                if (_isAgreed) _validateCheckbox = false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "I understand that any ID information provided will only be used for booking travel and leisure activities that require name registration. I also understand that Sail&StayMY will protect this information using encryption and other security methods, and Sail&StayMY will only authorize its use to relevant third parties for specific transactions.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_validateCheckbox && !_isAgreed)
                      const Padding(
                        padding: EdgeInsets.only(top: 8, left: 36),
                        child: Text(
                          "You must agree to the terms to continue",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),

          // --- FIXED BOTTOM BAR ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: darkBar,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Final Total",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      "RM ${widget.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _validateCheckbox = true);
                    if (_formKey.currentState!.validate() && _isAgreed) {
                      // 1. Prepare the booking data map for the Payment Screen
                      final Map<String, dynamic> bookingData = {
                        'islandName': widget.islandName,
                        'date': widget.date,
                        'packageType': widget.packageType,
                        'adults': widget.adults,
                        'children': widget.children,
                        'price': widget
                            .totalAmount, // PaymentScreen uses 'price' key
                        'customerName': _nameController.text.trim(),
                        'customerID': _idController.text.trim(),
                        'customerEmail': _emailController.text.trim(),
                      };

                      // 2. Navigate to PaymentScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentScreen(bookingData: bookingData),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: turquoise,
                    foregroundColor: navyBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: navyBlue),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: navyBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            style: TextStyle(color: navyBlue),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: turquoise, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
