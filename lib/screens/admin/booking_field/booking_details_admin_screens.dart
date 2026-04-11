import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/header_one.dart';
import 'package:pbl_app_joglo66/components/header_two.dart';

class BookingDetailsAdminScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailsAdminScreen({
    super.key,
    required this.bookingId,
  });

  Map<String, dynamic> _fetchDummyData(String id) {
    final db = {
      '1': {
        'fieldName': 'Joglo66 Field 1',
        'fieldType': 'Mini Soccer',
        'status': 'Booking Successful',
        'notes': 'No additional notes.',
        'playDate': 'Tuesday, April 14, 2026',
        'playTime': '14:00 - 16:00',
        'orderTime': 'Monday, April 13, 2026 09:30',
        'duration': 2,
        'pricePerHour': 150000,
        'downPayment': 150000,
        'paymentMethod': 'Cash'
      },
      '2': {
        'fieldName': 'Futsal Field A',
        'fieldType': 'Futsal',
        'status': 'Waiting for Payment',
        'notes': 'Please provide a spare ball.',
        'playDate': 'Wednesday, April 15, 2026',
        'playTime': '19:00 - 20:00',
        'orderTime': 'Tuesday, April 14, 2026 15:00',
        'duration': 1,
        'pricePerHour': 100000,
        'downPayment': 0,
        'paymentMethod': 'Transfer'
      },
    };

    return db[id] ?? {
      'fieldName': 'Data Not Found',
      'fieldType': '-',
      'status': 'Error',
      'notes': '-',
      'playDate': '-',
      'playTime': '-',
      'orderTime': '-',
      'duration': 0,
      'pricePerHour': 0,
      'downPayment': 0,
      'paymentMethod': '-'
    };
  }

  @override
  Widget build(BuildContext context) {
    final data = _fetchDummyData(bookingId);
    final int totalPrice = data['duration'] * data['pricePerHour'];
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
          },
        ),
        title: Text(
          'Booking Details ($bookingId)', 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Card Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: data['status'] == 'Booking Successful' 
                    ? const Color(0xFFE8F5E9) 
                    : const Color(0xFFFFF3E0), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: data['status'] == 'Booking Successful' 
                          ? const Color(0xFF4CAF50) 
                          : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      data['status'] == 'Booking Successful' ? Icons.check : Icons.access_time,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderTwo(title: 'Status: ${data['status']}'),
                        const SizedBox(height: 8),
                        Text(
                          data['notes'],
                        ), 
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeaderOne(title: 'Field Booking Details'),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        color: const Color(0xFF64B5F6),
                        alignment: Alignment.center,
                        child: const Icon(Icons.sports_soccer, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['fieldName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(data['fieldType'], style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  const HeaderTwo(title: 'Time'),
                  DetailRow(
                    label: 'Play Date',
                    value: '${data['playDate']} (${data['playTime']})',
                  ),
                  DetailRow(
                    label: 'Order Time',
                    value: data['orderTime'],
                  ),

                  const Divider(height: 32),

                  const HeaderTwo(title: 'Service'),
                  DetailRow(label: 'Duration', value: '${data['duration']} Hour(s)'),
                  DetailRow(label: 'Price Per Hour', value: formatRp.format(data['pricePerHour'])),
                  DetailRow(label: 'Total Price', value: formatRp.format(totalPrice)),
                  DetailRow(label: 'Total Down Payment', value: formatRp.format(data['downPayment'])),

                  const Divider(height: 32),

                  const HeaderTwo(title: 'Payment Details'),
                  DetailRow(label: 'Total Price', value: formatRp.format(totalPrice)),
                  DetailRow(label: 'Payment Method', value: data['paymentMethod']),
                ],
              ),
            ),

            const SizedBox(height: 24),

            InkWell(
              onTap: () {
                context.push('/admin/change-booking/$bookingId');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC80), 
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Modify / Cancel Booking',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}