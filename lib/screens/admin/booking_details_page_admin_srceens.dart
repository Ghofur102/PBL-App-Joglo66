import 'package:flutter/material.dart';
import '../../components/buble_card.dart';
import '../../components/button.dart';
import '../../components/list_card.dart';
import '../../components/foot_navigation.dart';

class BookingDetailsPageAdminScreens extends StatefulWidget {
  const BookingDetailsPageAdminScreens({super.key});

  @override
  State<BookingDetailsPageAdminScreens> createState() => _BookingDetailsPageAdminScreensState();
}

class _BookingDetailsPageAdminScreensState extends State<BookingDetailsPageAdminScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details - Admin'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Info Card
            BubleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Information',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  // Add booking details here
                  ListCard(
                    title: 'Booking ID',
                    subtitle: 'BK-001',
                  ),
                  ListCard(
                    title: 'Customer Name',
                    subtitle: 'John Doe',
                  ),
                  ListCard(
                    title: 'Date',
                    subtitle: '2024-01-15',
                  ),
                  ListCard(
                    title: 'Status',
                    subtitle: 'Confirmed',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Button(
                    text: 'Approve',
                    onPressed: () {
                      // Handle approve
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Button(
                    text: 'Reject',
                    onPressed: () {
                      // Handle reject
                    },
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FootNavigation(),
    );
  }
}
