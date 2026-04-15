import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/services/dashboard_service.dart';

class CheckSlotAvailabilityAdminScreens extends StatefulWidget {
  const CheckSlotAvailabilityAdminScreens({super.key});

  @override
  State<CheckSlotAvailabilityAdminScreens> createState() =>
      _CheckSlotAvailabilityPageState();
}

class _CheckSlotAvailabilityPageState
    extends State<CheckSlotAvailabilityAdminScreens> {
  // Dynamic data from API
  List<Map<String, dynamic>> fields = [];
  String? selectedFieldId; // Ubah dari String ke int first
  String selectedFieldName = '';
  DateTime selectedDate = DateTime.now();
  String selectedTimeFilter = 'Pagi';
  Set<String> selectedTimeSlots = {};

  // For loading states
  bool isLoadingFields = true;
  bool isLoadingSlots = false;
  String? errorMessage;

  // Available slots from API
  List<Map<String, dynamic>> availableSlots = [];

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  /// Fetch fields dari API
  Future<void> _loadFields() async {
    try {
      setState(() {
        isLoadingFields = true;
        errorMessage = null;
      });

      final fetchedFields = await DashboardService.fetchFields();
      
      setState(() {
        fields = fetchedFields;
        if (fetchedFields.isNotEmpty) {
          selectedFieldId = fetchedFields[0]['id'].toString();
          selectedFieldName = fetchedFields[0]['name'] ?? '';
          // Fetch slots untuk field pertama
          _loadSlots();
        }
        isLoadingFields = false;
      });

      print('[CheckSlot] ${fetchedFields.length} fields loaded');
    } catch (e) {
      print('[CheckSlot] Error loading fields: $e');
      setState(() {
        errorMessage = e.toString();
        isLoadingFields = false;
      });
    }
  }

  /// Fetch available slots dari API
  Future<void> _loadSlots() async {
    if (selectedFieldId == null) return;

    try {
      setState(() {
        isLoadingSlots = true;
      });

      final fieldId = int.tryParse(selectedFieldId!) ?? 0;
      final slots = await DashboardService.fetchAvailableSlots(
        fieldId,
        selectedDate,
      );

      setState(() {
        availableSlots = slots;
        isLoadingSlots = false;
      });

      print('[CheckSlot] ${slots.length} slots loaded for field $fieldId');
    } catch (e) {
      print('[CheckSlot] Error loading slots: $e');
      setState(() {
        availableSlots = [];
        isLoadingSlots = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading slots: $e')),
      );
    }
  }

  /// Format time dari format API "HH:00:00" ke "HH.00 - HH+1.00"
  String formatTimeSlot(String startTime, String endTime) {
    try {
      final start = startTime.split(':')[0];
      final end = endTime.split(':')[0];
      return '$start.00 - $end.00';
    } catch (e) {
      return '$startTime - $endTime';
    }
  }

  /// Determine time type (Pagi/Siang/Sore/Malam) dari hour
  String getTimeType(String startTime) {
    try {
      final hour = int.parse(startTime.split(':')[0]);
      if (hour >= 6 && hour < 12) return 'Pagi';
      if (hour >= 12 && hour < 15) return 'Siang';
      if (hour >= 15 && hour < 18) return 'Sore';
      return 'Malam';
    } catch (e) {
      return 'Pagi';
    }
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
      // Fetch slots untuk tanggal baru
      _loadSlots();
    }
  }

  String formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Filter slots berdasarkan time type
    var filteredSlots = availableSlots
        .where((slot) => getTimeType(slot['start']) == selectedTimeFilter)
        .toList();

    if (isLoadingFields) {
      return Scaffold(
        backgroundColor: const Color(0xFF406093),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading lapangan...'),
            ],
          ),
        ),
      );
    }

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
                  color: Colors.black.withValues(),
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

                // Error message
                if (errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),

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
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: DropdownButton<String>(
                    value: selectedFieldId,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: fields
                        .map<DropdownMenuItem<String>>(
                          (field) => DropdownMenuItem<String>(
                            value: field['id'].toString(),
                            child: Text(
                              field['name'] ?? 'Lapangan',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final selected = fields.firstWhere(
                          (f) => f['id'].toString() == value,
                          orElse: () => fields[0],
                        );
                        setState(() {
                          selectedFieldId = value;
                          selectedFieldName = selected['name'] ?? '';
                          selectedTimeSlots.clear();
                        });
                        _loadSlots();
                      }
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

                // Loading state untuk slots
                if (isLoadingSlots)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (filteredSlots.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Tidak ada slot tersedia untuk waktu ini',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ...filteredSlots.map((slot) {
                    final String timeKey = '${slot['start']}-${slot['end']}';
                    final String timeDisplay = formatTimeSlot(slot['start'], slot['end']);
                    final bool isSelected = selectedTimeSlots.contains(timeKey);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedTimeSlots.remove(timeKey);
                          } else {
                            selectedTimeSlots.add(timeKey);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green.shade200
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              timeDisplay,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isSelected ? Colors.green : Colors.grey,
                              size: 28,
                            ),
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
                    onPressed: selectedTimeSlots.isEmpty || selectedFieldId == null
                        ? null
                        : () {
                            // Hitung durasi (1 slot = 1 jam)
                            int totalDuration = selectedTimeSlots.length;

                            // Gabungkan jam yang dipilih
                            List<String> sortedTimes =
                                selectedTimeSlots.toList()..sort();
                            String combinedHours = sortedTimes.join(', ');

                            // Get fieldId dan harga dari field data
                            final int fieldId = int.tryParse(selectedFieldId!) ?? 0;
                            final fieldData = fields.firstWhere(
                              (f) => f['id'].toString() == selectedFieldId,
                              orElse: () => {'price': 150000},
                            );
                            final int fieldPrice = fieldData['price'] is int
                                ? fieldData['price'] as int
                                : int.tryParse(fieldData['price'].toString()) ?? 150000;

                            context.push(
                              '/admin/form-input-booking',
                              extra: {
                                'nameField': selectedFieldName,
                                'fieldId': fieldId,
                                'selectedDate': selectedDate,
                                'hours': combinedHours,
                                'duration': totalDuration,
                                'fieldPrice': fieldPrice,
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
