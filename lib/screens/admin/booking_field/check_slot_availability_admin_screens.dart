import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 

class CheckSlotAvailabilityAdminScreens extends StatefulWidget {
  const CheckSlotAvailabilityAdminScreens({super.key});

  @override
  State<CheckSlotAvailabilityAdminScreens> createState() =>
      _CheckSlotAvailabilityPageState();
}

class _CheckSlotAvailabilityPageState
    extends State<CheckSlotAvailabilityAdminScreens> {
  String selectedField = 'Mini Soccer';
  DateTime selectedDate = DateTime.now();
  String selectedTimeFilter = 'Pagi';

  // --- TAMBAHAN: Variabel untuk menyimpan slot waktu yang diklik ---
  Set<String> selectedTimeSlots = {};

  final List<String> fields = ['Mini Soccer', 'Futsal'];

  // Mapping field names to IDs
  final Map<String, int> fieldNameToId = {
    'Mini Soccer': 1,
    'Futsal': 2,
  };

  final List<Map<String, dynamic>> slots = [
    {'time': '08.00 - 09.00', 'status': true, 'type': 'Pagi'},
    {'time': '09.00 - 10.00', 'status': false, 'type': 'Pagi'},
    {'time': '10.00 - 11.00', 'status': false, 'type': 'Pagi'},
    {'time': '11.00 - 12.00', 'status': true, 'type': 'Siang'},
    {'time': '12.00 - 13.00', 'status': true, 'type': 'Siang'},
    {'time': '13.00 - 14.00', 'status': true, 'type': 'Siang'},
    {'time': '14.00 - 15.00', 'status': false, 'type': 'Sore'},
    {'time': '15.00 - 16.00', 'status': false, 'type': 'Sore'},
    {'time': '16.00 - 17.00', 'status': true, 'type': 'Sore'},
    {'time': '18.00 - 19.00', 'status': false, 'type': 'Malam'},
    {'time': '19.00 - 20.00', 'status': true, 'type': 'Malam'},
    {'time': '21.00 - 22.00', 'status': true, 'type': 'Malam'},
    {'time': '22.00 - 23.00', 'status': true, 'type': 'Malam'},
  ];

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
        selectedDate = picked;
        selectedTimeSlots.clear();
      });
    }
  }

  String formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var filteredSlots = slots
        .where((e) => e['type'] == selectedTimeFilter)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF406093),
      appBar: AppBar(
        title: const Text(
          'Cek Ketersediaan Slot',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 20,
          ),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(), // Fixed withOpacity
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Pilih Ketersediaan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Pilih Lapangan ---
                const Text(
                  'Pilih Lapangan',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4, // Sedikit diubah agar dropdown pas
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: DropdownButton<String>(
                    value: selectedField,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: fields
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedField = value!;
                      });
                    },
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2C3E50),
                    ),
                    dropdownColor: Colors.white,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF406093),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Pilih Tanggal ---
                const Text(
                  'Pilih Tanggal',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDate(selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF406093),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Filter Waktu ---
                const Text(
                  'Filter Waktu',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['Pagi', 'Siang', 'Sore', 'Malam']
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(e),
                              selected: selectedTimeFilter == e,
                              selectedColor: const Color(0xFF406093),
                              labelStyle: TextStyle(
                                color: selectedTimeFilter == e
                                    ? Colors.white
                                    : const Color(0xFF2C3E50),
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  selectedTimeFilter = e;
                                });
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Ketersediaan Slot ---
                const Text(
                  'Ketersediaan Slot',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),

                ...filteredSlots.map((slot) {
                  bool isAvailable = slot['status'];
                  bool isSelected = selectedTimeSlots.contains(slot['time']);

                  // Tentukan warna dan icon berdasarkan 3 kemungkinan state
                  Color bgColor;
                  Color borderColor;
                  Widget trailingIcon;

                  if (!isAvailable) {
                    // 1. Tidak Tersedia (Disabled)
                    bgColor = Colors.red.shade50;
                    borderColor = Colors.red.shade200;
                    trailingIcon = const Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 28,
                    );
                  } else if (isSelected) {
                    // 2. Tersedia & Dipilih
                    bgColor = Colors.green.shade50;
                    borderColor = Colors.green.shade200;
                    trailingIcon = const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    );
                  } else {
                    // 3. Tersedia & Belum Dipilih (Default)
                    bgColor = Colors.white;
                    borderColor = Colors.grey.shade300;
                    trailingIcon = const SizedBox(
                      width: 28,
                    ); // Kosongkan saja jika belum dipilih
                  }

                  return GestureDetector(
                    onTap: () {
                      // Jika tidak tersedia, abaikan ketukan
                      if (!isAvailable) return;

                      setState(() {
                        if (isSelected) {
                          selectedTimeSlots.remove(slot['time']);
                        } else {
                          selectedTimeSlots.add(slot['time']);
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            slot['time'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isAvailable
                                  ? const Color(0xFF2C3E50)
                                  : Colors.grey.shade600,
                            ),
                          ),
                          trailingIcon,
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // --- TOMBOL LANJUT KE FORM PESANAN ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Tombol disabled jika belum ada slot yang dipilih
                    onPressed: selectedTimeSlots.isEmpty
                        ? null
                        : () {
                            // Hitung durasi (1 slot = 1 jam)
                            int totalDuration = selectedTimeSlots.length;

                            // Gabungkan jam yang dipilih (contoh: 08.00-09.00, 09.00-10.00)
                            List<String> sortedTimes =
                                selectedTimeSlots.toList()..sort();
                            String combinedHours = sortedTimes.join(', ');

                            context.push(
                              '/admin/form-input-booking', // Sesuaikan dengan path rute Anda
                              extra: {
                                'nameField': selectedField,
                                'fieldId': fieldNameToId[selectedField] ?? 1,
                                'selectedDate': selectedDate,
                                'hours': combinedHours,
                                'duration': totalDuration,
                              },
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF406093),
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Lanjut Isi Form',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
