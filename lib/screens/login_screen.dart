import 'package:flutter/material.dart';
import 'dashboard_admin.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Stack(
          children: [
            // Dekorasi atas kiri
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A6FA5),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Dekorasi bawah kanan
            Positioned(
              bottom: -80,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A6FA5),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Konten
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(Icons.public, size: 40),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Login to your account",
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 24),

                    // Username
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Username"),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Masukkan username anda disini",
                        suffixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Password"),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Masukkan password anda",
                        suffixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Button Login
                    SizedBox(
                      width: 150,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DashboardAdmin(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A6FA5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}