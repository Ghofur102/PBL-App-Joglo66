import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String paymentMethod = '';
  bool agree = false;
  String lapangan = 'Futsal';
  DateTime? selectedDate;
  String? selectedSlot;
  String durasi = '1';
  bool customDurasi = false;
  final TextEditingController customDurasiController = TextEditingController();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController waController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  List<String> get timeSlots {
    List<String> slots = [];
    for (int start = 8; start <= 22; start++) {
      String startTime = DateFormat(
        'HH:mm',
      ).format(DateTime(2000, 1, 1, start, 0));
      String endTime = DateFormat(
        'HH:mm',
      ).format(DateTime(2000, 1, 1, start + 1, 0));
      slots.add('$startTime - $endTime');
    }
    return slots;
  }

  void nextPage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking berhasil ditambahkan ..')),
    );
  }

  Widget infoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF757575),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF406093), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget paymentOption(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile(
        value: title,
        groupValue: paymentMethod,
        onChanged: (value) {
          setState(() {
            paymentMethod = value.toString();
          });
        },
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF406093),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2C3E50),
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

  void _selectLapangan(String? value) {
    setState(() {
      lapangan = value ?? 'Futsal';
    });
  }

  void _selectSlot(String? slot) {
    setState(() {
      selectedSlot = slot;
    });
  }

  void _selectDurasi(String d) {
    setState(() {
      durasi = d;
      customDurasi = false;
    });
  }

  void _toggleCustomDurasi() {
    setState(() {
      customDurasi = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formattedDate = selectedDate != null
        ? DateFormat('dd MMM yyyy').format(selectedDate!)
        : 'Pilih tanggal';

    return Scaffold(
      backgroundColor: const Color(0xFF406093),
      appBar: AppBar(
        title: const Text(
          'Form Booking Lapangan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 20,
          ),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: 500,
              minWidth: screenWidth * 0.9,
            ),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Lengkapi Booking',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Detail Booking
                const Text(
                  'Detail Booking',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                // Lapangan Dropdown
                const Text(
                  'Lapangan',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: DropdownButton<String>(
                    value: lapangan,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'Futsal',
                        child: Text(
                          'Futsal',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Mini Soccer',
                        child: Text(
                          'Mini Soccer',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    ],
                    onChanged: _selectLapangan,
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
                const SizedBox(height: 16),
                // Tanggal
                const Text(
                  'Tanggal',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedDate != null
                                ? Colors.black87
                                : const Color(0xFF9E9E9E),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Color(0xFF406093),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Jam
                const Text(
                  'Jam',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: DropdownButton<String>(
                    value: selectedSlot,
                    hint: Text(
                      'Pilih slot jam',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    isExpanded: true,
                    items: timeSlots
                        .map(
                          (slot) => DropdownMenuItem(
                            value: slot,
                            child: Text(
                              slot,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _selectSlot,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2C3E50),
                    ),
                    dropdownColor: Colors.white,
                    icon: const Icon(
                      Icons.access_time,
                      color: Color(0xFF406093),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Durasi
                const Text(
                  'Durasi',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['1', '2', '3', '4']
                            .map(
                              (d) => GestureDetector(
                                onTap: () => _selectDurasi(d),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: durasi == d
                                        ? const Color(0xFF406093)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    '$d Jam',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: durasi == d
                                          ? Colors.white
                                          : const Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleCustomDurasi,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: customDurasi
                              ? const Color(0xFF406093)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit,
                              size: 16,
                              color: Color(0xFF2C3E50),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Lainnya',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: customDurasi
                                    ? Colors.white
                                    : const Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (customDurasi) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: customDurasiController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Masukkan durasi (jam)',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF406093)),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Data Pemesan
                const Text(
                  'Data Pemesan',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                inputField('Nama Lengkap', namaController),
                const SizedBox(height: 16),
                inputField('No. WhatsApp', waController),
                const SizedBox(height: 16),
                inputField('Email', emailController),
                const SizedBox(height: 16),
                inputField(
                  'Catatan (opsional)',
                  catatanController,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                // Ringkasan Pembayaran
                const Text(
                  'Ringkasan Pembayaran',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Harga Sewa',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const Text(
                            'Rp 800.000',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Durasi',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            '${customDurasi ? customDurasiController.text : durasi} Jam',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const Text(
                            'Rp 800.000',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Metode Pembayaran
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                paymentOption('Transfer Bank'),
                paymentOption('E-Wallet'),
                paymentOption('Bayar di Tempat'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: agree,
                      activeColor: const Color(0xFF406093),
                      onChanged: (value) {
                        setState(() {
                          agree = value!;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Saya setuju dengan syarat & ketentuan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Next Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: agree && paymentMethod.isNotEmpty
                            ? nextPage
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF406093),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Next',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
