import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ListClosedBookingAdminScreens extends StatefulWidget {
  // Tidak ada parameter yang dibutuhkan
  const ListClosedBookingAdminScreens({super.key});

  @override
  State<ListClosedBookingAdminScreens> createState() => _ListClosedBookingAdminScreensState();
}

class _ListClosedBookingAdminScreensState extends State<ListClosedBookingAdminScreens> {
  String _activeTab = 'needs_action';

  final List<Map<String, dynamic>> _dummyBookings = [
    {
      'id': '1',
      'date': '06 Mar 2026',
      'name': 'Putra Zeus (Danil)',
      'time': '13:00 - 15:00',
      'status': 'needs_action',
    },
    {
      'id': '2',
      'date': '06 Mar 2026',
      'name': 'Garuda FC (Andi)',
      'time': '15:00 - 17:00',
      'status': 'needs_action',
    },
    {
      'id': '3',
      'date': '05 Mar 2026',
      'name': 'Elang Timur (Budi)',
      'time': '09:00 - 11:00',
      'status': 'history',
    },
    {
      'id': '4',
      'date': '04 Mar 2026',
      'name': 'Spartan (Riko)',
      'status': 'history', // Contoh full day (tanpa jam)
    },
  ];

  // Fungsi untuk membuat item list
  Widget bookingItem({
    required String id,
    required String date,
    required String name,
    String? time,
  }) {
    return InkWell(
      onTap: () {
        context.push('/admin/change-booking/$id');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (time != null)
                    Text(
                      time,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _dummyBookings.where((booking) {
      return booking['status'] == _activeTab;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF406093),
      appBar: AppBar(
        title: const Text(
          "Closed Bookings", // Translasi ke bahasa Inggris
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF406093),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.list_alt, size: 50, color: Color(0xFF406093)),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeTab = 'needs_action';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          // Warna berubah dinamis jika sedang aktif
                          color: _activeTab == 'needs_action'
                              ? Colors.grey[400]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "Needs Action",
                            style: TextStyle(
                              color: _activeTab == 'needs_action'
                                  ? Colors.black
                                  : Colors.black54,
                              fontWeight: _activeTab == 'needs_action'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeTab = 'history';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _activeTab == 'history'
                              ? Colors.grey[400]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "History",
                            style: TextStyle(
                              color: _activeTab == 'history'
                                  ? Colors.black
                                  : Colors.black54,
                              fontWeight: _activeTab == 'history'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: filteredBookings.isEmpty
                    ? const Center(
                        child: Text(
                          "No bookings found.",
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          return bookingItem(
                            id: booking['id'],
                            date: booking['date'],
                            name: booking['name'],
                            time: booking['time'],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
