import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/services/field_service.dart'; // <-- Pastikan import service-nya

class FormCloseFieldAdminScreens extends StatefulWidget {
  final String fieldId;

  const FormCloseFieldAdminScreens({super.key, required this.fieldId});

  @override
  State<FormCloseFieldAdminScreens> createState() => _FormCloseFieldAdminScreensState();
}

class _FormCloseFieldAdminScreensState extends State<FormCloseFieldAdminScreens> {
  // Controllers untuk input
  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _startTimeCtrl = TextEditingController();

  final TextEditingController _endDateCtrl = TextEditingController();
  final TextEditingController _endTimeCtrl = TextEditingController();

  final TextEditingController _reasonCtrl = TextEditingController();

  // State untuk loading tombol
  bool _isSaving = false;

  // Helper memunculkan kalender
  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF406093),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Helper memunculkan jam
  Future<void> _pickTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() {
        controller.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  // Widget pembantu untuk form input agar rapi
  Widget _buildInputField(String hint, IconData icon, TextEditingController controller, VoidCallback onTap) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        suffixIcon: Icon(icon, color: Colors.grey, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF406093)),
        ),
      ),
    );
  }

  // ========================================================
  // FUNGSI SUBMIT KE BACKEND
  // ========================================================
  Future<void> _submitForm() async {
    // 1. Validasi Inputan Wajib
    if (_startDateCtrl.text.isEmpty || _startTimeCtrl.text.isEmpty || _reasonCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal Mulai, Jam Mulai, dan Alasan wajib diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Format Waktu Mulai (YYYY-MM-DD HH:mm:ss)
    String startDateTimeStr = "${_startDateCtrl.text} ${_startTimeCtrl.text}:00";

    // 3. Logika "Smart Default" untuk Waktu Selesai
    String endDateStr = _endDateCtrl.text.isEmpty ? _startDateCtrl.text : _endDateCtrl.text;
    String endTimeStr = _endTimeCtrl.text.isEmpty ? "23:59:00" : "${_endTimeCtrl.text}:00";
    String endDateTimeStr = "$endDateStr $endTimeStr";

    setState(() {
      _isSaving = true;
    });

    try {
      // 4. Panggil API melalui FieldService
      await FieldService.closeField(
        fieldId: int.parse(widget.fieldId),
        startTime: startDateTimeStr,
        endTime: endDateTimeStr,
        reason: _reasonCtrl.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lapangan berhasil ditutup sementara!'), backgroundColor: Colors.green),
        );
        // Kembali ke halaman sebelumnya (Detail Lapangan) setelah sukses
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        // Tampilkan pesan error dari Laravel (misal: "Waktu mundur tidak valid")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF406093),
      appBar: AppBar(
        title: const Text("Tutup Lapangan", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF406093),
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.lock_clock, size: 60, color: Colors.black87),
                    SizedBox(height: 12),
                    Text(
                      "Tutup Sementara Lapangan",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- WAKTU MULAI TUTUP ---
              const Text("Waktu Mulai Tutup", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tanggal", style: TextStyle(fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 4),
                        _buildInputField("YYYY-MM-DD", Icons.calendar_month, _startDateCtrl, () => _pickDate(_startDateCtrl)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Jam", style: TextStyle(fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 4),
                        _buildInputField("00:00", Icons.access_time, _startTimeCtrl, () => _pickTime(_startTimeCtrl)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- WAKTU SELESAI TUTUP ---
              const Text("Waktu Selesai Tutup", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tanggal", style: TextStyle(fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 4),
                        _buildInputField("YYYY-MM-DD", Icons.calendar_month, _endDateCtrl, () => _pickDate(_endDateCtrl)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Jam", style: TextStyle(fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 4),
                        _buildInputField("00:00", Icons.access_time, _endTimeCtrl, () => _pickTime(_endTimeCtrl)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "• Kosongkan Waktu Selesai jika tutup hanya seharian penuh.",
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // --- ALASAN TUTUP ---
              const Text("Alasan Penutupan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _reasonCtrl,
                maxLines: 4,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Contoh: Renovasi rumput lapangan, cuaca buruk, dll.",
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFF406093)),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- TOMBOL SIMPAN ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitForm, // Disable jika sedang loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: _isSaving 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),

              // --- TOMBOL LIHAT LIST ---
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/admin/list-closed-booking');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Lihat Riwayat Tutup",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}