import 'package:flutter/material.dart';
import 'package:sailstayapp2/screens/signup.dart';
import 'package:sailstayapp2/screens/homescreen.dart';
import 'package:sailstayapp2/widgets/custom_scaffold.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool rememberPassword = true;
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
              const SizedBox(height: 100),

              /// TITLE
              const Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Back!",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4EE3C1),
                ),
              ),

              const SizedBox(height: 40),

              /// USERNAME
              _buildInputField(
                hint: "Username",
                icon: Icons.person_outline,
                validator: "Please enter username",
              ),

              const SizedBox(height: 16),

              /// PASSWORD
              _buildInputField(
                hint: "Password",
                icon: Icons.lock_outline,
                validator: "Please enter password",
                isPassword: true,
              ),

              const SizedBox(height: 12),

              /// REMEMBER ME
              Row(
                children: [
                  Checkbox(
                    value: rememberPassword,
                    onChanged: (value) {
                      setState(() {
                        rememberPassword = value!;
                      });
                    },
                    activeColor: const Color(0xFF4EE3C1),
                    checkColor: Colors.black,
                  ),
                  const Text(
                    "Remember for 30 days",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// LOGIN BUTTON
              GestureDetector(
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    await Future.delayed(const Duration(seconds: 2));
                    Navigator.pop(context);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
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
                      colors: [
                        Color(0xFF8F6CFF),
                        Color(0xFF4EE3C1),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "LOG IN",
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

              /// SIGN UP LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.white70),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign up",
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

  /// INPUT FIELD
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
                    obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
