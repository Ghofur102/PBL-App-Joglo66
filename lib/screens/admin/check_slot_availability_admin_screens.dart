import 'package:flutter/material.dart';

class SlotPage extends StatefulWidget {
  const SlotPage({super.key});

  @override
  State<SlotPage> createState() => _SlotPageState();
}

class _SlotPageState extends State<SlotPage> {
  String selectedField = 'Mini Soccer';
  DateTime selectedDate = DateTime.now();
  String selectedTimeFilter = 'Pagi';

  final List<String> fields = ['Mini Soccer', 'Futsal'];

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
                  color: Colors.black.withOpacity(0.1),
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
                // Pilih Lapangan
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
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: DropdownButton<String>(
                    value: selectedField,
                    isExpanded: true,
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
                // Pilih Tanggal
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
                // Filter waktu
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
                // List slot
                Text(
                  'Ketersediaan Slot',
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                ...filteredSlots.map(
                  (slot) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: slot['status']
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: slot['status']
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          slot['time'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        Icon(
                          slot['status'] ? Icons.check_circle : Icons.cancel,
                          color: slot['status'] ? Colors.green : Colors.red,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
