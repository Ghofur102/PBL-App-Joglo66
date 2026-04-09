import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/components/input_field.dart';
import 'package:pbl_app_joglo66/components/tab_button.dart';

class ChangeBookingAdminScreens extends StatefulWidget {
  // 1. Parameter yang diterima dari halaman sebelumnya
  final String bookingId;
  final String oldDate;
  final String oldTime;

  const ChangeBookingAdminScreens({
    super.key,
    required this.bookingId,
    required this.oldDate,
    required this.oldTime,
  });

  @override
  State<ChangeBookingAdminScreens> createState() => _ChangeBookingAdminScreenState();
}

class _ChangeBookingAdminScreenState extends State<ChangeBookingAdminScreens> {
  // 2. Variabel State untuk menyimpan tab mana yang sedang aktif
  // Secara default kita set ke 'Reschedule'
  String _activeTab = 'Reschedule';

  // Controller untuk input (opsional, tapi baik disiapkan)
  final TextEditingController _alasanController = TextEditingController();
  final TextEditingController _newDateController = TextEditingController();
  final TextEditingController _newTimeController = TextEditingController();

  @override
  void dispose() {
    _alasanController.dispose();
    _newDateController.dispose();
    _newTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ubah / Batalkan',
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
                      'foto',
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
                        const Text(
                          'Nama Pemesan (Nama Tim)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Nama Lapangan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Menggunakan parameter yang dikirim
                        Text(
                          'Jadwal: ${widget.oldDate} | ${widget.oldTime}',
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
                    'Ubah / Batalkan Pesanan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 20),

                  // 3. Tab Pilihan (Reschedule vs Dibatalkan)
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
                      const SizedBox(width: 3),

                      TabButton(
                        title: 'Dibatalkan',
                        icon: Icons.cancel_outlined,
                        isActive: _activeTab == 'Dibatalkan',
                        activeColor: const Color(0xFFE57373),
                        onTap: () {
                          setState(() {
                            _activeTab = 'Dibatalkan';
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 4. Area Form Dinamis (Berubah sesuai tab yang dipilih)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 215, 222, 228), 
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _activeTab == 'Reschedule'
                        ? _buildRescheduleForm()
                        : _buildCancelForm(),
                  ),

                  const SizedBox(height: 12),

                  // Tombol Simpan Perubahan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logika simpan berdasarkan tab yang aktif
                        if (_activeTab == 'Reschedule') {
                          //
                        } else {
                          //
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFFCC80,
                        ), // Oranye pastel
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER FORM ---

  // Form Khusus Reschedule
  Widget _buildRescheduleForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Jadwal Lama (Disabled)
        InputField(
          label: 'Jadwal Saat Ini (Tidak bisa diedit)',
          initialValue: '${widget.oldDate} | ${widget.oldTime}',
          isEnabled: false, // Membuatnya disabled
        ),
        const SizedBox(height: 16),
        // Input Tanggal Baru
        InputField(
          label: 'Tanggal Main Baru',
          hint: 'Pilih Tanggal Baru',
          controller: _newDateController,
          icon: Icons.calendar_today,
          readOnly: true, // Cegah keyboard muncul
          onTap: () async {
            // Memunculkan dialog kalender bawaan Flutter
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), // Tanggal default
              firstDate: DateTime.now(), // Minimal pilih hari ini
              lastDate: DateTime(2030), // Maksimal tahun 2030
            );

            // Jika user memilih tanggal (tidak cancel)
            if (pickedDate != null) {
              // Ubah format tanggal (contoh sederhana) dan masukkan ke controller
              String formattedDate =
                  "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
              setState(() {
                _newDateController.text = formattedDate;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        // Input Jam Baru
        InputField(
          label: 'Jam Awal Main Baru',
          hint: 'Pilih Jam Baru',
          controller: _newTimeController,
          icon: Icons.access_time,
          readOnly: true, // Cegah keyboard muncul
          onTap: () async {
            // Memunculkan dialog jam bawaan Flutter
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            // Jika user memilih jam
            if (pickedTime != null) {
              // Masukkan ke controller (format bawaan jam:menit)
              setState(() {
                _newTimeController.text = pickedTime.format(context);
              });
            }
          },
        ),
        const SizedBox(height: 16),
        // Input Jam Baru
        InputField(
          label: 'Jam Akhir Main Baru',
          hint: 'Pilih Jam Baru',
          controller: _newTimeController,
          icon: Icons.access_time,
          readOnly: true, // Cegah keyboard muncul
          onTap: () async {
            // Memunculkan dialog jam bawaan Flutter
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            // Jika user memilih jam
            if (pickedTime != null) {
              // Masukkan ke controller (format bawaan jam:menit)
              setState(() {
                _newTimeController.text = pickedTime.format(context);
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
          'Alasan Pembatalan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _alasanController,
          maxLines: 5, // Membuatnya menjadi Textarea (tinggi 5 baris)
          decoration: InputDecoration(
            hintText: 'Tuliskan alasan membatalkan pesanan...',
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
