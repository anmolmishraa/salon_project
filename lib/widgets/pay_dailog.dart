import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingConfirmationDialog extends StatelessWidget {
  final DateTime appointmentDateTime;

  const BookingConfirmationDialog({super.key, required this.appointmentDateTime});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMM yyyy').format(appointmentDateTime);
    final formattedTime = DateFormat('h:mm a').format(appointmentDateTime);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFB68D4C), Color(0xFFD6B16C)],
                ),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              "Your Service Booking is\nConfirmed!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              "Thank you for choosing Oasis Spa Haven. Your appointment for Swedish Massage and Hot Stone Massage has been successfully booked.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F4F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Your appointment on $formattedDate at $formattedTime",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB68D4C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Done", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
