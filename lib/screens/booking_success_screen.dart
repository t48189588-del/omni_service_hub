import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String humanReadableId;

  const BookingSuccessScreen({
    super.key,
    required this.humanReadableId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50], // Glassmorphism-style background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                "Booking Confirmed!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 16),
              const Text("Your Appointment ID:"),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: Text(
                  humanReadableId,
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),
              ),
              const Text(
                "Please show this ID to the provider upon arrival.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // Day 3 Requirement: Add to Calendar
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Calendar integration coming soon...")));
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text("Add to Calendar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text("Return to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
