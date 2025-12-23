import 'package:flutter/material.dart';
import 'package:sailstayapp2/widgets/custom_scaffold.dart';
import 'package:sailstayapp2/services/authentication.dart'; 
import 'package:sailstayapp2/screens/login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. TEXT CONTROLLERS
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. AUTH SERVICE INSTANCE
  final AuthService _auth = AuthService();

  bool agreePersonalData = true;
  bool obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),

              const Text(
                "Create",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Account",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4EE3C1),
                ),
              ),

              const SizedBox(height: 40),

              /// USERNAME FIELD
              _buildInputField(
                hint: "Username", 
                icon: Icons.person_outline,
                validator: "Please enter username",
                controller: _nameController,
              ),

              const SizedBox(height: 16),

              /// EMAIL FIELD
              _buildInputField(
                hint: "Email",
                icon: Icons.email_outlined,
                validator: "Please enter email",
                controller: _emailController,
              ),

              const SizedBox(height: 16),

              /// PASSWORD FIELD
              _buildInputField(
                hint: "Password",
                icon: Icons.lock_outline,
                validator: "Please enter password",
                isPassword: true,
                controller: _passwordController,
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Checkbox(
                    value: agreePersonalData,
                    onChanged: (value) {
                      setState(() {
                        agreePersonalData = value!;
                      });
                    },
                    activeColor: const Color(0xFF4EE3C1),
                    checkColor: Colors.black,
                  ),
                  const Expanded(
                    child: Text(
                      "I agree to the processing of personal data",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// SIGN UP BUTTON
              GestureDetector(
                onTap: () async {
                  if (_formKey.currentState!.validate() && agreePersonalData) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    // 3. CALL FIREBASE SIGNUP
                    String? result = await _auth.signUp(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                      username: _nameController.text.trim(), 
                    );

                    if (mounted) Navigator.pop(context); // Remove Loading

                    if (result == "Success") {
                      // 4. SIGN OUT IMMEDIATELY
                      // Firebase signs the user in automatically on creation. 
                      // We sign out so they are forced to log in manually.
                      await _auth.signOut(); 

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Account created! Please log in."),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // 5. NAVIGATE TO SIGN IN SCREEN
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignInScreen()),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text(result ?? "Sign up failed"),
                        ),
                      );
                    }
                  } else if (!agreePersonalData) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please agree to the processing of personal data")),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8F6CFF), Color(0xFF4EE3C1)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "SIGN UP",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.white70),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                      );
                    },
                    child: const Text(
                      "Log in",
                      style: TextStyle(
                        color: Color(0xFF4EE3C1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    required IconData icon,
    required String validator,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscurePassword : false,
        style: const TextStyle(color: Colors.white),
        validator: (value) => (value == null || value.isEmpty) ? validator : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}