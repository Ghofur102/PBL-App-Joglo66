import 'dart:io'; // Untuk menggunakan File()
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import 'package:image_picker/image_picker.dart'; // Package baru kita
import 'package:pbl_app_joglo66/services/field_service.dart';

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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  // --- STATE UNTUK GAMBAR FISIK ---
  File? _selectedImage;
  String? _existingImageUrl;

  List<Map<String, dynamic>> _pricingRules = [];

  final List<String> _daysOfWeek = [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await FieldService.fetchFieldDetail(widget.fieldId);
      
      if (mounted) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _descController.text = data['description'] ?? '';
          _categoryController.text = data['category'] ?? '';
          
          // Simpan URL gambar yang sudah ada dari database
          _existingImageUrl = data['image_url'];

          if (data['field_prices'] != null) {
            _pricingRules = List<Map<String, dynamic>>.from(data['field_prices'].map((item) {
              String st = item['start_time'] ?? '08:00';
              String et = item['end_time'] ?? '22:00';
              if (st.length > 5) st = st.substring(0, 5);
              if (et.length > 5) et = et.substring(0, 5);

              return {
                'day_type': item['day_type'],
                'start_time': st,
                'end_time': et,
                'price': item['price'],
              };
            }));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.red),
        );
        context.pop();
      }
    }
  }

  // --- FUNGSI MEMBUKA GALERI ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompres sedikit agar tidak terlalu berat
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka galeri.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _saveData() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lapangan wajib diisi!')),
      );
      return;
    }

    if (_pricingRules.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal harus ada 1 jadwal harga!')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FieldService.updateField(
        id: int.parse(widget.fieldId),
        name: _nameController.text,
        description: _descController.text,
        category: _categoryController.text,
        pricingRules: _pricingRules, 
        // --- KIRIM PATH FILE FISIK JIKA ADA ---
        imagePath: _selectedImage?.path, 
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Field data updated successfully!'), backgroundColor: Colors.green),
        );
        context.pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ... (Dialog Add dan Edit Rule tetap sama seperti sebelumnya, saya potong agar rapi, silakan gunakan yang sudah ada)
  void _showAddRuleDialog() {
    String selectedDay = 'monday';
    TextEditingController priceCtrl = TextEditingController();
    TextEditingController startCtrl = TextEditingController(text: '08:00');
    TextEditingController endCtrl = TextEditingController(text: '12:00');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Pricing Schedule'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      decoration: const InputDecoration(labelText: 'Day'),
                      items: _daysOfWeek.map((day) {
                        return DropdownMenuItem(value: day, child: Text(day.toUpperCase()));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedDay = val!),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startCtrl, readOnly: true,
                            decoration: const InputDecoration(labelText: 'Start Time'),
                            onTap: () async {
                              final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
                              if (picked != null) {
                                setDialogState(() => startCtrl.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}");
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: endCtrl, readOnly: true,
                            decoration: const InputDecoration(labelText: 'End Time'),
                            onTap: () async {
                              final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 12, minute: 0));
                              if (picked != null) {
                                setDialogState(() => endCtrl.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price (Rp)', prefixText: 'Rp '),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (priceCtrl.text.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Harga wajib diisi!'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    String newStart = startCtrl.text;
                    String newEnd = endCtrl.text;

                    if (newStart.compareTo(newEnd) >= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jam mulai harus lebih awal dari jam selesai!'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    bool hasOverlap = false;
                    for (var rule in _pricingRules) {
                      if (rule['day_type'] == selectedDay) {
                        String existStart = rule['start_time'];
                        String existEnd = rule['end_time'];

                        if (newStart.compareTo(existEnd) < 0 && newEnd.compareTo(existStart) > 0) {
                          hasOverlap = true;
                          break;
                        }
                      }
                    }

                    if (hasOverlap) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal! Jadwal jam tersebut bentrok dengan jadwal hari ${selectedDay.toUpperCase()} yang sudah ada.'), 
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _pricingRules.add({
                        'day_type': selectedDay,
                        'start_time': newStart,
                        'end_time': newEnd,
                        'price': int.parse(priceCtrl.text),
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                )
              ],
            );
          }
        );
      }
    );
  }

  void _showEditRuleDialog(int index) {
    final existingRule = _pricingRules[index];
    String selectedDay = existingRule['day_type'];
    TextEditingController priceCtrl = TextEditingController(text: existingRule['price'].toString());
    TextEditingController startCtrl = TextEditingController(text: existingRule['start_time']);
    TextEditingController endCtrl = TextEditingController(text: existingRule['end_time']);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Pricing Schedule'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      decoration: const InputDecoration(labelText: 'Day'),
                      items: _daysOfWeek.map((day) {
                        return DropdownMenuItem(value: day, child: Text(day.toUpperCase()));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedDay = val!),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startCtrl, readOnly: true,
                            decoration: const InputDecoration(labelText: 'Start Time'),
                            onTap: () async {
                              final currentStart = TimeOfDay(
                                hour: int.parse(startCtrl.text.split(':')[0]), 
                                minute: int.parse(startCtrl.text.split(':')[1])
                              );
                              final picked = await showTimePicker(context: context, initialTime: currentStart);
                              if (picked != null) {
                                setDialogState(() => startCtrl.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}");
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: endCtrl, readOnly: true,
                            decoration: const InputDecoration(labelText: 'End Time'),
                            onTap: () async {
                              final currentEnd = TimeOfDay(
                                hour: int.parse(endCtrl.text.split(':')[0]), 
                                minute: int.parse(endCtrl.text.split(':')[1])
                              );
                              final picked = await showTimePicker(context: context, initialTime: currentEnd);
                              if (picked != null) {
                                setDialogState(() => endCtrl.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price (Rp)', prefixText: 'Rp '),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (priceCtrl.text.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Harga wajib diisi!'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    String newStart = startCtrl.text;
                    String newEnd = endCtrl.text;

                    if (newStart.compareTo(newEnd) >= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jam mulai harus lebih awal dari jam selesai!'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    bool hasOverlap = false;
                    for (int i = 0; i < _pricingRules.length; i++) {
                      if (i == index) continue; 

                      var rule = _pricingRules[i];
                      if (rule['day_type'] == selectedDay) {
                        String existStart = rule['start_time'];
                        String existEnd = rule['end_time'];

                        if (newStart.compareTo(existEnd) < 0 && newEnd.compareTo(existStart) > 0) {
                          hasOverlap = true;
                          break;
                        }
                      }
                    }

                    if (hasOverlap) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal! Jadwal jam tersebut bentrok dengan jadwal hari ${selectedDay.toUpperCase()} yang sudah ada.'), 
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _pricingRules[index] = {
                        'day_type': selectedDay,
                        'start_time': newStart,
                        'end_time': newEnd,
                        'price': int.parse(priceCtrl.text),
                      };
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                )
              ],
            );
          }
        );
      }
    );
  }

  void _removeRule(int index) {
    setState(() {
      _pricingRules.removeAt(index);
    });
  }

  Widget inputField(
    String? hint, {
    IconData? prefixIcon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1, 
    TextInputType keyboardType = TextInputType.text, 
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
          borderSide: BorderSide.none, 
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
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : SingleChildScrollView(
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

              // ==========================================
              // TOMBOL MENUJU FORM TUTUP SEMENTARA LAPANGAN
              // ==========================================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigasi ke rute tutup lapangan membawa ID
                    context.push('/admin/close-field/${widget.fieldId}');
                  },
                  icon: const Icon(Icons.lock_clock, color: Colors.white, size: 20),
                  label: const Text(
                    "Tutup Sementara Lapangan",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400, // Warna merah agar mencolok
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // KOMPONEN UNGGAH GAMBAR GALERI
              // ==========================================
              const Text("Foto Lapangan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _selectedImage != null 
                        // Jika admin baru saja memilih gambar dari galeri
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                            // Jika belum pilih gambar baru, tapi ada gambar lama di database
                            ? Image.network(
                                _existingImageUrl!, 
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                ),
                              )
                            // Jika tidak ada gambar sama sekali
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text("Tap untuk unggah gambar dari Galeri", style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Field Name", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 6),
              inputField("Enter field name", controller: _nameController),
              const SizedBox(height: 16),

              const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 6),
              inputField("Enter field category (e.g. Mini Soccer)", controller: _categoryController),
              const SizedBox(height: 16),

              const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 6),
              inputField("Enter field description", controller: _descController, maxLines: 4),
              const SizedBox(height: 24),

              // --- DYNAMIC PRICING SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pricing & Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green, size: 28),
                    onPressed: _showAddRuleDialog,
                  )
                ],
              ),
              const SizedBox(height: 8),
              
              if (_pricingRules.isEmpty)
                 const Padding(
                   padding: EdgeInsets.all(8.0),
                   child: Text("No pricing rules added yet. Please add at least one.", style: TextStyle(color: Colors.red)),
                 ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pricingRules.length,
                itemBuilder: (context, index) {
                  final rule = _pricingRules[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(rule['day_type'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${rule['start_time']} - ${rule['end_time']} | Rp ${rule['price']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min, 
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditRuleDialog(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeRule(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              Center(
                child: SizedBox(
                  width: double.infinity, 
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF406093),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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