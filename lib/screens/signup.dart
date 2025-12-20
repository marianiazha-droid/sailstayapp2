import 'package:flutter/material.dart';
import 'package:sailstayapp2/screens/login.dart';
import 'package:sailstayapp2/widgets/custom_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  bool obscurePassword = true;

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

              /// TITLE
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

              /// FULL NAME
              _buildInputField(
                hint: "Full Name",
                icon: Icons.person_outline,
                validator: "Please enter full name",
              ),

              const SizedBox(height: 16),

              /// EMAIL
              _buildInputField(
                hint: "Email",
                icon: Icons.email_outlined,
                validator: "Please enter email",
              ),

              const SizedBox(height: 16),

              /// PASSWORD
              _buildInputField(
                hint: "Password",
                icon: Icons.lock_outline,
                validator: "Please enter password",
                isPassword: true,
              ),

              const SizedBox(height: 14),

              /// AGREE PERSONAL DATA
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
                onTap: () {
                  if (_formKey.currentState!.validate() && agreePersonalData) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Processing Data")),
                    );
                  } else if (!agreePersonalData) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please agree to the processing of personal data",
                        ),
                      ),
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

              /// SIGN IN LINK
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
                      "Sign in",
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

  /// INPUT FIELD (SAME STYLE AS LOGIN)
  Widget _buildInputField({
    required String hint,
    required IconData icon,
    required String validator,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        obscureText: isPassword ? obscurePassword : false,
        style: const TextStyle(color: Colors.white),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validator;
          }
          return null;
        },
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
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
