import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // <-- JANGAN LUPA IMPORT INI UNTUK FORMAT RUPIAH
import 'package:pbl_app_joglo66/services/field_service.dart';

class CheckSlotAvailabilityAdminScreens extends StatefulWidget {
  const CheckSlotAvailabilityAdminScreens({super.key});

  @override
  State<CheckSlotAvailabilityAdminScreens> createState() =>
      _CheckSlotAvailabilityPageState();
}

class _CheckSlotAvailabilityPageState extends State<CheckSlotAvailabilityAdminScreens> {
  // Dynamic data from API
  List<Map<String, dynamic>> fields = [];
  String? selectedFieldId; 
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

  /// Fetch field data dari API
  Future<void> _loadFields() async {
    try {
      final rawData = await FieldService.fetchListField();
      final fieldList = rawData.map((item) => item as Map<String, dynamic>).toList();
      
      if (mounted) {
        setState(() {
          fields = fieldList;
          isLoadingFields = false;
          errorMessage = null;

          // Auto-pilih lapangan pertama agar dropdown tidak kosong
          if (fields.isNotEmpty && selectedFieldId == null) {
            selectedFieldId = fields[0]['id'].toString();
            selectedFieldName = fields[0]['name'] ?? '';
            _loadSlots(); 
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString().replaceAll('Exception: ', '');
          isLoadingFields = false; 
        });
      }
    }
  }

  /// Fetch available slots dari API
  Future<void> _loadSlots() async {
    if (selectedFieldId == null) return;

    try {
      if (mounted) setState(() => isLoadingSlots = true);

      final fieldId = int.tryParse(selectedFieldId!) ?? 0;
      final String formattedDate = selectedDate.toString().split(' ')[0];

      final rawSlots = await FieldService.checkAvailability(
        fieldId: fieldId,
        date: formattedDate,
      );

      final slots = rawSlots.map((slot) => slot as Map<String, dynamic>).toList();

      if (mounted) {
        setState(() {
          availableSlots = slots;
          isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          availableSlots = [];
          isLoadingSlots = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
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

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
        selectedTimeSlots.clear();
      });
      _loadSlots();
    }
  }

  String formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    var filteredSlots = availableSlots
        .where((slot) => getTimeType(slot['start']) == selectedTimeFilter)
        .toList();

    if (isLoadingFields) {
      return const Scaffold(
        backgroundColor: Color(0xFF406093),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Loading lapangan...', style: TextStyle(color: Colors.white)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                      if (value != null && mounted) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                                if (mounted) {
                                  setState(() {
                                    selectedTimeFilter = e;
                                  });
                                }
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Ketersediaan Slot',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),

                if (isLoadingSlots)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (filteredSlots.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Tidak ada slot tersedia / Lapangan Tutup',
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
                    
                    // 1. CEK STATUS KETERSEDIAAN DARI API
                    bool isAvailable = slot['is_available'] ?? true; 
                    bool isPastTime = false;

                    // =========================================================
                    // 2. LOGIKA BARU: CEK WAKTU TERLEWAT (PAST TIME VALIDATION)
                    // =========================================================
                    final now = DateTime.now();
                    // Jika tanggal yang dipilih adalah HARI INI
                    if (selectedDate.year == now.year && 
                        selectedDate.month == now.month && 
                        selectedDate.day == now.day) {
                      
                      final parts = slot['start'].toString().split(':');
                      if (parts.length >= 2) {
                        final slotHour = int.parse(parts[0]);
                        final slotMinute = int.parse(parts[1]);
                        
                        // Buat jam dari slot tersebut di hari ini
                        final slotTime = DateTime(now.year, now.month, now.day, slotHour, slotMinute);
                        
                        // Jika waktu sekarang sudah MELEWATI waktu mulai slot
                        if (now.isAfter(slotTime)) {
                          isAvailable = false; // Matikan slot
                          isPastTime = true;   // Tandai sebagai sudah terlewat
                        }
                      }
                    }
                    // =========================================================
                    
                    // Hanya bisa terpilih jika dia available dan diklik
                    final bool isSelected = isAvailable && selectedTimeSlots.contains(timeKey);
                    
                    // Format Harga ke Rupiah
                    final int price = slot['price'] is int ? slot['price'] : int.tryParse(slot['price'].toString()) ?? 0;
                    final String formatRp = NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0
                    ).format(price);

                    return GestureDetector(
                      // MATIKAN FUNGSI KLIK JIKA SUDAH DIPESAN ATAU TERLEWAT
                      onTap: isAvailable ? () {
                        if (mounted) {
                          setState(() {
                            if (isSelected) {
                              selectedTimeSlots.remove(timeKey);
                            } else {
                              selectedTimeSlots.add(timeKey);
                            }
                          });
                        }
                      } : null, 
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          // WARNA ABU-ABU JIKA SUDAH DIPESAN/TERLEWAT
                          color: !isAvailable 
                              ? Colors.grey.shade200 
                              : (isSelected ? Colors.green.shade50 : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !isAvailable 
                                ? Colors.grey.shade300 
                                : (isSelected ? Colors.green.shade200 : Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timeDisplay,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    // TEKS DICORET JIKA SUDAH DIPESAN/TERLEWAT
                                    color: !isAvailable ? Colors.grey.shade500 : const Color(0xFF2C3E50),
                                    decoration: !isAvailable ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  // TAMPILKAN TEKS DINAMIS BERDASARKAN KONDISI
                                  !isAvailable 
                                    ? (isPastTime ? 'Waktu Terlewat' : 'Sudah Dipesan / Tutup') 
                                    : formatRp,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: !isAvailable 
                                        ? Colors.red.shade400 
                                        : (isSelected ? Colors.green.shade700 : Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              // GANTI IKON JADI BLOKIR JIKA SUDAH DIPESAN/TERLEWAT
                              !isAvailable 
                                  ? Icons.block 
                                  : (isSelected ? Icons.check_circle : Icons.radio_button_unchecked),
                              color: !isAvailable 
                                  ? Colors.grey.shade400 
                                  : (isSelected ? Colors.green : Colors.grey),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedTimeSlots.isEmpty || selectedFieldId == null
                        ? null
                        : () {
                            int totalDuration = selectedTimeSlots.length;
                            List<String> sortedTimes = selectedTimeSlots.toList()..sort();
                            String combinedHours = sortedTimes.join(', ');

                            final int fieldId = int.tryParse(selectedFieldId!) ?? 0;
                            
                            // MENGAMBIL HARGA SEBENARNYA DARI SLOT YANG DIPILIH
                            int realPrice = 150000;
                            if (sortedTimes.isNotEmpty) {
                              var chosenSlot = availableSlots.firstWhere(
                                (s) => '${s['start']}-${s['end']}' == sortedTimes.first,
                                orElse: () => {'price': 150000}
                              );
                              realPrice = chosenSlot['price'] is int 
                                  ? chosenSlot['price'] 
                                  : int.tryParse(chosenSlot['price'].toString()) ?? 150000;
                            }

                            context.push(
                              '/admin/form-input-booking',
                              extra: {
                                'nameField': selectedFieldName,
                                'fieldId': fieldId,
                                'selectedDate': selectedDate,
                                'hours': combinedHours,
                                'duration': totalDuration,
                                'fieldPrice': realPrice, // Harga dari DB dikirim ke form!
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