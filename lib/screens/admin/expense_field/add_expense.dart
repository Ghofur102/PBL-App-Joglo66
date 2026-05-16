import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/expense_field.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? selectedImage;

  String? selectedCategory;

  final List<String> categories = [
    "Listrik",
    "Air",
    "Peralatan",
    "Kebersihan",
    "Operasional",
    "Lainnya",
  ];

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  void saveExpense() {
    if (_formKey.currentState!.validate()) {
      if (selectedCategory == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Kategori harus dipilih")));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengeluaran berhasil disimpan")),
      );

      // kasih sinyal ke halaman list agar bisa reload
      Navigator.pop(context, true);

      print("Nama : ${nameController.text}");
      print("Kategori : $selectedCategory");
      print("Nominal : ${nominalController.text}");
      print("Tanggal : ${dateController.text}");
      print("Catatan : ${noteController.text}");
      print("Foto : ${selectedImage?.path}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFFFFF),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: const Text(
          "Input Pengeluaran",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E7FF)),
                ),
                child: Column(
                  children: [
                    buildInputRow(
                      title: "Nama",
                      child: TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Nama pengeluaran wajib diisi";
                          }
                          return null;
                        },
                        decoration: inputDecoration(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    buildInputRow(
                      title: "Kategori",
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: inputDecoration(),
                        items: categories.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    buildInputRow(
                      title: "Nominal",
                      child: TextFormField(
                        controller: nominalController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Nominal wajib diisi";
                          }

                          if (int.tryParse(value) == null) {
                            return "Nominal harus angka";
                          }

                          return null;
                        },
                        decoration: inputDecoration(hint: "Masukkan nominal"),
                      ),
                    ),

                    const SizedBox(height: 18),

                    buildInputRow(
                      title: "Tanggal",
                      child: TextFormField(
                        controller: dateController,
                        readOnly: true,
                        onTap: pickDate,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Tanggal wajib diisi";
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hint: "Pilih tanggal",
                          suffixIcon: const Icon(Icons.calendar_month),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    buildInputRow(
                      title: "Bukti foto",
                      child: ElevatedButton(
                        onPressed: pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade500,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Upload file"),
                      ),
                    ),

                    if (selectedImage != null) ...[
                      const SizedBox(height: 14),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          selectedImage!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E7FF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Catatan Tambahan",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: noteController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: 170,
                height: 48,
                child: ElevatedButton(
                  onPressed: saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text("Simpan Pengeluaran"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputRow({required String title, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(title),
          ),
        ),

        const Padding(padding: EdgeInsets.only(top: 14), child: Text(":")),

        const SizedBox(width: 12),

        Expanded(child: child),
      ],
    );
  }

  InputDecoration inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }
}
