import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import 'package:pbl_app_joglo66/components/button.dart';

class FormEditFieldAdminScreens extends StatefulWidget {
  final String fieldId;

  const FormEditFieldAdminScreens({
    super.key,
    required this.fieldId,
  });

  @override
  State<FormEditFieldAdminScreens> createState() => _FormEditFieldAdminScreensState();
}

class _FormEditFieldAdminScreensState extends State<FormEditFieldAdminScreens> {
  // 2. Siapkan semua Controller untuk form
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController; // Tambahan untuk harga
  late TextEditingController _startController;
  late TextEditingController _endController;

  // 3. Simulasi ambil data dari Database/API
  Map<String, dynamic> _fetchDummyData(String id) {
    final db = {
      '1': {
        'fieldName': 'Joglo66 Field 1',
        'description': 'Premium mini soccer field with high-quality synthetic grass.',
        'category': 'Mini Soccer',
        'price': '150000',
        'startTime': '08:00',
        'endTime': '22:00',
      },
      '2': {
        'fieldName': 'Futsal Field A',
        'description': 'Standard indoor futsal court with vinyl flooring.',
        'category': 'Futsal',
        'price': '100000',
        'startTime': '09:00',
        'endTime': '23:00',
      },
    };

    return db[id] ?? {
      'fieldName': '',
      'description': '',
      'category': '',
      'price': '',
      'startTime': '08:00',
      'endTime': '22:00',
    };
  }

  @override
  void initState() {
    super.initState();
    // 4. Tarik data lama dan masukkan ke dalam Controller
    final data = _fetchDummyData(widget.fieldId);

    _nameController = TextEditingController(text: data['fieldName']);
    _descController = TextEditingController(text: data['description']);
    _categoryController = TextEditingController(text: data['category']);
    _priceController = TextEditingController(text: data['price']);
    _startController = TextEditingController(text: data['startTime']);
    _endController = TextEditingController(text: data['endTime']);
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
      setState(() {
        controller.text = '$hourStr:$minuteStr';
      });
    }
  }

  @override
  void dispose() {
    // Bersihkan memory saat layar ditutup
    _nameController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  // Widget Form Input Reusable
  Widget inputField(
    String? hint, {
    IconData? prefixIcon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1, // Tambahan agar bisa untuk deskripsi panjang
    TextInputType keyboardType = TextInputType.text, // Tambahan untuk angka/teks
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none, // Dihilangkan agar lebih clean
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF406093),
      appBar: AppBar(
        title: const Text("Edit Field Data"),
        centerTitle: true,
        backgroundColor: const Color(0xFF406093),
        elevation: 0,
        foregroundColor: Colors.white,
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
                    Icon(Icons.sports_soccer, size: 50, color: Color(0xFF406093)),
                    SizedBox(height: 8),
                    Text(
                      "Field Information",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- FORM NAMA LAPANGAN ---
              const Text(
                "Field Name",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 6),
              inputField("Enter field name", controller: _nameController),
              const SizedBox(height: 16),

              // --- FORM KATEGORI ---
              const Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 6),
              inputField("Enter field category (e.g. Mini Soccer)", controller: _categoryController),
              const SizedBox(height: 16),

              // --- FORM HARGA ---
              const Text(
                "Price Per Hour (Rp)",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 6),
              inputField(
                "Enter price", 
                controller: _priceController,
                keyboardType: TextInputType.number, // Tampilkan keyboard angka
              ),
              const SizedBox(height: 16),

              // --- FORM DESKRIPSI ---
              const Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 6),
              inputField(
                "Enter field description", 
                controller: _descController,
                maxLines: 4, // Textarea
              ),
              const SizedBox(height: 16),

              // --- FORM FOTO ---
              const Text(
                "Field Photo",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logika ambil gambar dari galeri nanti di sini
                    },
                    icon: const Icon(Icons.photo_camera, color: Colors.white),
                    label: const Text("Choose Photo"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF406093),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("current_image.jpg", style: TextStyle(color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Upload a new photo to replace the old one (Optional)",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 16),

              // --- FORM JAM OPERASIONAL ---
              const Text(
                "Operational Hours",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
                  const Text("to", style: TextStyle(fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 32),

              // --- TOMBOL AKSI ---
              Center(
                child: SizedBox(
                  width: double.infinity, // Agar tombol memenuhi lebar
                  child: Button(
                    label: "Save Changes",
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Field data updated successfully!')),
                      );
                      context.pop(); 
                    },
                    backgroundColor: const Color(0xFF406093),
                    textColor: Colors.white,
                    padding: 16.0, 
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Button(
                    label: "Temporarily Close Field",
                    onPressed: () {
                      context.push('/admin/close-field/${widget.fieldId}');
                    },
                    backgroundColor: const Color(0xFFE57373), // Merah pastel
                    textColor: Colors.white,
                    padding: 16.0,
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