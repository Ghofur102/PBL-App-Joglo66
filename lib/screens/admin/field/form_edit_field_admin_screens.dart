import 'package:flutter/material.dart';

import '../../../components/button.dart';

class FormLapanganPage extends StatefulWidget {
  const FormLapanganPage({super.key});

  @override
  State<FormLapanganPage> createState() => _FormLapanganPageState();
}

class _FormLapanganPageState extends State<FormLapanganPage> {
  late TextEditingController _startController;
  late TextEditingController _endController;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(text: '08:00');
    _endController = TextEditingController(text: '22:00');
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final parts = controller.text.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final initialTime = TimeOfDay(hour: hour, minute: minute);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      final String hourStr = picked.hour.toString().padLeft(2, '0');
      final String minuteStr = picked.minute.toString().padLeft(2, '0');
      controller.text = '$hourStr:$minuteStr';
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Widget inputField(
    String? hint, {
    IconData? prefixIcon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF406093),
      appBar: AppBar(
        title: const Text("Form Perubahan Data Lapangan"),
        centerTitle: true,
        backgroundColor: const Color(0xFF406093),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.sports_soccer, size: 50),
                    SizedBox(height: 8),
                    Text(
                      "Data Lapangan",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "Nama Lapangan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              inputField("Masukkan Nama Lapangan"),

              const SizedBox(height: 12),

              const Text(
                "Deskripsi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              inputField("Masukkan Deskripsi Lapangan"),

              const SizedBox(height: 12),

              const Text(
                "Foto Lapangan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.photo_camera, color: Colors.white),
                    label: const Text("Pilih Foto"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF406093),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("-"),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Unggah Foto Lapangan (Opsional)",
                style: TextStyle(fontSize: 12),
              ),

              const SizedBox(height: 12),

              const Text(
                "Jam Operasional",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: inputField(
                      null,
                      controller: _startController,
                      readOnly: true,
                      onTap: () => _selectTime(_startController),
                      prefixIcon: Icons.access_time,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: inputField(
                      null,
                      controller: _endController,
                      readOnly: true,
                      onTap: () => _selectTime(_endController),
                      prefixIcon: Icons.access_time,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                "Kategori",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              inputField("Masukkan kategori lapangan"),

              const SizedBox(height: 20),

              Center(
                child: Button(
                  label: "Simpan Perubahan",
                  onPressed: () {},
                  backgroundColor: const Color(0xFF406093),
                  textColor: Colors.white,
                  padding: 40.0,
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Button(
                  label: "Tutup sementara",
                  onPressed: () {},
                  backgroundColor: Colors.red,
                  textColor: Colors.black,
                  padding: 20.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
