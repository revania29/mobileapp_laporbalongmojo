import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = '/about';
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang Aplikasi"),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Icon(Icons.verified_user, size: 60, color: Colors.indigo),
              ),
              const SizedBox(height: 20),
              
              const Text(
                "LAPOR BALONGMOJO",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.indigo
                ),
              ),
              const SizedBox(height: 10),
              
              const Text(
                "Versi 1.0.0",
                style: TextStyle(color: Colors.grey),
              ),
              
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),
              
              const Text(
                "Dikembangkan oleh:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text("Tim IT Desa Balongmojo"), 
              const SizedBox(height: 5),
              const Text("Copyright © 2025"),
            ],
          ),
        ),
      ),
    );
  }
}