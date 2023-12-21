import 'package:flutter/material.dart';

class ConfirmationPage extends StatelessWidget {
  final List<int> newlyBookedSeats;

  ConfirmationPage({required this.newlyBookedSeats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Confirmation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Newly Booked Seats: ${newlyBookedSeats.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
