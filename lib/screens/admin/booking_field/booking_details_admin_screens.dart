import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/header_one.dart';
import 'package:pbl_app_joglo66/components/header_two.dart';

class BookingDetailsAdminScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsAdminScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailsAdminScreen> createState() =>
      _BookingDetailsAdminScreenState();
}

class _BookingDetailsAdminScreenState extends State<BookingDetailsAdminScreen> {
  // Variabel State
  Map<String, dynamic>? bookingData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBookingDetail();
  }

  // Fungsi memanggil API
  Future<void> _fetchBookingDetail() async {
    try {
      String baseUrl = dotenv.env['API_BASE_URL']!;
      final String apiUrl = '$baseUrl/api/admin/detail-booking/${widget.bookingId}';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          bookingData = jsonResponse['data']; 
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat data (Error Code: ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Tidak dapat terhubung ke server.\nDetail: $e';
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status) {
      case 'finish':
      case 'active':
        return {
          'text': status == 'finish' ? 'Booking Finished' : 'Booking Active',
          'bgColor': const Color(0xFFE8F5E9), // Hijau muda
          'iconColor': const Color(0xFF4CAF50), // Hijau
          'icon': Icons.check_circle,
        };
      case 'cancelled':
        return {
          'text': 'Booking Cancelled',
          'bgColor': const Color(0xFFFFEBEE), // Merah muda
          'iconColor': Colors.red,
          'icon': Icons.cancel,
        };
      case 'reschedule':
        return {
          'text': 'Rescheduled',
          'bgColor': const Color(0xFFFFF3E0), // Orange muda
          'iconColor': Colors.orange,
          'icon': Icons.update,
        };
      case 'waiting':
      default:
        return {
          'text': 'Waiting for Payment',
          'bgColor': const Color(0xFFFFF3E0), // Orange muda
          'iconColor': Colors.orange,
          'icon': Icons.access_time,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatRp = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
          'Booking Details (${widget.bookingId})',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : _buildContent(formatRp), // Panggil fungsi pembuat konten jika sukses
    );
  }

  Widget _buildContent(NumberFormat formatRp) {
    final statusStyle = _getStatusStyle(bookingData!['status']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusStyle['bgColor'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusStyle['iconColor'],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    statusStyle['icon'],
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeaderTwo(title: 'Status: ${statusStyle['text']}'),
                      const SizedBox(height: 8),
                      // Catatan tidak ada di API controller Anda, jadi kita beri teks default
                      Text(
                        bookingData!['status'] == 'cancelled' 
                            ? 'Pesanan ini telah dibatalkan.' 
                            : 'Silakan cek pembayaran dengan teliti.',
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
                          bookingData!['field_info']['name'], // Ambil dari API
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bookingData!['field_info']['category'], // Ambil dari API
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(height: 32),

                const HeaderTwo(title: 'Time'),
                DetailRow(
                  label: 'Play Date',
                  value: '${bookingData!['time_info']['play_date']} (${bookingData!['time_info']['play_time']})',
                ),
                DetailRow(
                  label: 'Order Time',
                  value: bookingData!['time_info']['order_time'],
                ),

                const Divider(height: 32),

                const HeaderTwo(title: 'Service'),
                DetailRow(
                  label: 'Duration', 
                  value: '${bookingData!['service_info']['duration']} Hour(s)'
                ),
                DetailRow(
                  label: 'Price Per Hour', 
                  value: formatRp.format(bookingData!['service_info']['price_per_hour'])
                ),
                DetailRow(
                  label: 'Total Price', 
                  value: formatRp.format(bookingData!['service_info']['total_price'])
                ),
                DetailRow(
                  label: 'Total Down Payment', 
                  value: formatRp.format(bookingData!['service_info']['total_down_payment'])
                ),

                const Divider(height: 32),

                const HeaderTwo(title: 'Payment Details'),
                DetailRow(
                  label: 'Total Price', 
                  value: formatRp.format(bookingData!['payment_details']['total_price'])
                ),
                DetailRow(
                  label: 'Payment Method', 
                  // Uppercase huruf pertama (transfer -> Transfer)
                  value: toBeginningOfSentenceCase(bookingData!['payment_details']['payment_method']) ?? '-',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          InkWell(
            onTap: () {
              context.push('/admin/change-booking/${widget.bookingId}');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFCC80),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Modify / Cancel Booking',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}