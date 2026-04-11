import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import 'package:pbl_app_joglo66/components/input_field.dart';
import 'package:pbl_app_joglo66/components/tab_button.dart';

class ChangeBookingAdminScreens extends StatefulWidget {
  // 1. Hanya menerima bookingId dari parameter
  final String bookingId;

  const ChangeBookingAdminScreens({
    super.key,
    required this.bookingId,
  });

  @override
  State<ChangeBookingAdminScreens> createState() => _ChangeBookingAdminScreenState();
}

class _ChangeBookingAdminScreenState extends State<ChangeBookingAdminScreens> {
  // Variabel State untuk menyimpan tab aktif
  String _activeTab = 'Reschedule';

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _newDateController = TextEditingController();
  final TextEditingController _newStartTimeController = TextEditingController();
  final TextEditingController _newEndTimeController = TextEditingController();

  // 2. SIMULASI DATABASE (API)
  // Fungsi ini bertindak sebagai API backend yang mengambil data berdasarkan ID
  Map<String, dynamic> _fetchDummyData(String id) {
    final db = {
      'BK-001': {
        'tenantName': 'Budi (Sportify FC)',
        'fieldName': 'Joglo66 Field 1',
        'oldDate': 'April 14, 2026',
        'oldTime': '14:00 - 16:00',
      },
      'BK-002': {
        'tenantName': 'Andi (Garuda FC)',
        'fieldName': 'Futsal Field A',
        'oldDate': 'April 15, 2026',
        'oldTime': '19:00 - 20:00',
      },
    };

    // Kembalikan data jika ketemu, atau data kosong jika ID tidak valid
    return db[id] ?? {
      'tenantName': 'Unknown Tenant',
      'fieldName': 'Unknown Field',
      'oldDate': '-',
      'oldTime': '-',
    };
  }

  @override
  void dispose() {
    // Jangan lupa hapus semua controller dari memori saat layar ditutup
    _reasonController.dispose();
    _newDateController.dispose();
    _newStartTimeController.dispose();
    _newEndTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 3. Ambil data dari simulasi API berdasarkan bookingId
    final bookingData = _fetchDummyData(widget.bookingId);

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
        title: const Text(
          'Modify / Cancel',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Card Identitas Pemesan (Atas) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Hijau muda cerah
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookingData['tenantName'], // Data dari API simulasi
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bookingData['fieldName'], // Data dari API simulasi
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Schedule: ${bookingData['oldDate']} | ${bookingData['oldTime']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          'ID: ${widget.bookingId}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Card Form Ubah / Batalkan (Bawah) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Biru muda lembut
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Modify / Cancel Order',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 20),

                  // Tab Pilihan (Reschedule vs Cancel)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TabButton(
                        title: 'Reschedule',
                        icon: Icons.edit_calendar,
                        isActive: _activeTab == 'Reschedule',
                        activeColor: const Color(0xFF64B5F6),
                        onTap: () {
                          setState(() {
                            _activeTab = 'Reschedule';
                          });
                        },
                      ),
                      const SizedBox(width: 8), // Sedikit diperlebar agar rapi
                      TabButton(
                        title: 'Cancel',
                        icon: Icons.cancel_outlined,
                        isActive: _activeTab == 'Cancel',
                        activeColor: const Color(0xFFE57373),
                        onTap: () {
                          setState(() {
                            _activeTab = 'Cancel';
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Area Form Dinamis (Berubah sesuai tab yang dipilih)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 215, 222, 228), 
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Lempar data ke dalam fungsi form agar bisa ditampilkan
                    child: _activeTab == 'Reschedule'
                        ? _buildRescheduleForm(bookingData)
                        : _buildCancelForm(),
                  ),

                  const SizedBox(height: 16),

                  // Tombol Simpan Perubahan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logika simpan berdasarkan tab yang aktif
                        if (_activeTab == 'Reschedule') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reschedule request saved!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Order has been cancelled!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC80), // Oranye pastel
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER FORM ---

  // Form Khusus Reschedule (Menerima parameter data agar bisa menampilkan jadwal lama)
  Widget _buildRescheduleForm(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Jadwal Lama (Disabled)
        InputField(
          label: 'Current Schedule (Cannot be edited)',
          initialValue: '${data['oldDate']} | ${data['oldTime']}',
          isEnabled: false, 
        ),
        const SizedBox(height: 16),
        
        // Input Tanggal Baru
        InputField(
          label: 'New Play Date',
          hint: 'Select New Date',
          controller: _newDateController,
          icon: Icons.calendar_today,
          readOnly: true, 
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030), 
            );

            if (pickedDate != null) {
              String formattedDate = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
              setState(() {
                _newDateController.text = formattedDate;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        
        // Input Jam Awal Baru (Menggunakan controller StartTime)
        InputField(
          label: 'New Start Time',
          hint: 'Select Start Time',
          controller: _newStartTimeController,
          icon: Icons.access_time,
          readOnly: true, 
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (pickedTime != null && context.mounted) {
              setState(() {
                _newStartTimeController.text = pickedTime.format(context);
              });
            }
          },
        ),
        const SizedBox(height: 16),
        
        // Input Jam Akhir Baru (Menggunakan controller EndTime)
        InputField(
          label: 'New End Time',
          hint: 'Select End Time',
          controller: _newEndTimeController,
          icon: Icons.access_time,
          readOnly: true, 
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (pickedTime != null && context.mounted) {
              setState(() {
                _newEndTimeController.text = pickedTime.format(context);
              });
            }
          },
        ),
      ],
    );
  }

  // Form Khusus Dibatalkan (Textarea)
  Widget _buildCancelForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reason for Cancellation',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonController,
          maxLines: 5, 
          decoration: InputDecoration(
            hintText: 'Write the reason for cancelling the order...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}