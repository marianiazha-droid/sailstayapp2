import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sailstayapp2/screens/homescreen.dart'; 

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const PaymentScreen({
    super.key,
    required this.bookingData,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Theme Colors
  final Color navyBlue = const Color(0xFF0C004B);
  final Color turquoise = const Color(0xFF5CE1E6);
  final Color lightPurple = const Color(0xFFF9F6FF);

  int _selectedMethod = 0; // 0: Card, 1: TNG, 2: Online Banking

  @override
  Widget build(BuildContext context) {
    // Parsing price from the bookingData map passed from previous screen
    double totalAmount =
        double.tryParse(widget.bookingData['price'].toString()) ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Payment",
          style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SUMMARY CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: navyBlue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: navyBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    "Total Amount",
                    "RM ${totalAmount.toStringAsFixed(2)}",
                    Colors.white,
                    isBold: true,
                    fontSize: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Colors.white24),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Status",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        "Pending Payment",
                        style: TextStyle(
                          color: turquoise,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text(
              "Select Payment Method",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: navyBlue,
              ),
            ),
            const SizedBox(height: 16),

            _buildMethodOption(0, icon: Icons.credit_card, title: "Credit / Debit Card"),
            _buildMethodOption(
              1,
              customLogo: const Icon(Icons.account_balance_wallet, color: Color(0xFF0C004B), size: 20), 
              title: "Touch 'n Go eWallet",
            ),
            _buildMethodOption(2, icon: Icons.account_balance, title: "Online Banking (FPX)"),

            const SizedBox(height: 24),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedMethod == 0
                  ? _buildCardForm()
                  : _selectedMethod == 1
                      ? _buildEWalletPrompt("TNG eWallet")
                      : _buildBankDropdown(),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () => _handlePaymentProcess(totalAmount),
              style: ElevatedButton.styleFrom(
                backgroundColor: navyBlue,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                "Confirm & Pay",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIC: THE FIX FOR CHOICE B ---
  Future<void> _handlePaymentProcess(double finalTotal) async {
    // 1. Get the current logged-in user
    final User? user = FirebaseAuth.instance.currentUser;

    // 2. If no user, stop and show error
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication Error: Please login again.")),
      );
      return;
    }

    // 3. Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 4. SAVE TO FIRESTORE
      await FirebaseFirestore.instance.collection('Bookings').add({
        // This spreads all data from previous screens (islandName, price, roomImage, etc.)
        ...widget.bookingData, 
        
        // --- CRITICAL FIELDS FOR FILTERING ---
        'userId': user.uid,        // The UID from your Authentication screenshot
        'userEmail': user.email,    
        'totalAmount': finalTotal, 
        'paymentMethod': _selectedMethod == 0 ? "Card" : _selectedMethod == 1 ? "TNG" : "FPX",
        'status': 'Paid & Confirmed',
        'createdAt': FieldValue.serverTimestamp(), // Used to sort your My Bookings list
      });

      if (!mounted) return;
      Navigator.pop(context); // Close loading spinner

      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading spinner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Database Error: $e")),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: turquoise, size: 70),
            const SizedBox(height: 20),
            const Text(
              "Payment Successful!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your booking is confirmed. Check the 'Booking' tab to see it.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate back to Home and clear navigation history
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: navyBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text(
                "Back to Home",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildMethodOption(int index, {IconData? icon, Widget? customLogo, required String title}) {
    bool isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? lightPurple : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? turquoise : Colors.grey[200]!, width: 2),
        ),
        child: Row(
          children: [
            if (customLogo != null) customLogo else Icon(icon, color: isSelected ? navyBlue : Colors.grey),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: navyBlue)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: turquoise),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      key: const ValueKey(0),
      children: [
        _buildTextField("Card Number", "xxxx xxxx xxxx xxxx"),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField("Expiry", "MM/YY")),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField("CVV", "***")),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: lightPurple,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: turquoise)),
      ),
    );
  }

  Widget _buildEWalletPrompt(String name) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: turquoise.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.qr_code_scanner, color: navyBlue),
          const SizedBox(width: 12),
          Expanded(child: Text("You will be redirected to the $name app to authorize.", style: TextStyle(color: navyBlue, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildBankDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(filled: true, fillColor: lightPurple, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      hint: const Text("Choose your FPX Bank"),
      items: ["Maybank2u", "CIMB Clicks", "Public Bank", "RHB Now"].map((bank) => DropdownMenuItem(value: bank, child: Text(bank))).toList(),
      onChanged: (val) {},
    );
  }

  Widget _buildSummaryRow(String label, String value, Color textColor, {bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textColor, fontSize: fontSize)),
          Text(value, style: TextStyle(color: turquoise, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize)),
        ],
      ),
    );
  }
}