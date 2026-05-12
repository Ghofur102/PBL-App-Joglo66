import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/input_field.dart';
import 'package:pbl_app_joglo66/components/tab_button.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class ChangeBookingAdminScreens extends StatefulWidget {
  final String bookingId;

  const ChangeBookingAdminScreens({super.key, required this.bookingId});

  @override
  State<ChangeBookingAdminScreens> createState() =>
      _ChangeBookingAdminScreenState();
}

class _ChangeBookingAdminScreenState extends State<ChangeBookingAdminScreens> {
  String _activeTab = 'Reschedule';

  bool _isLoadingData = true;
  Map<String, dynamic>? _bookingData;
  
  // --- VARIABEL LOGIKA BARU ---
  bool _isPast = false;
  bool _isMepet = false; // Deteksi H-3
  bool _isFieldClosure = false; // Deteksi Lapangan Tutup
  String _status = '';
  int _totalPaid = 0;
  String _refundStatus = 'None'; // Pilihan dropdown refund

  int _remainingPayment = 0;
  int _fieldId = 0;

  final TextEditingController _reasonCancelController = TextEditingController();
  final TextEditingController _reasonRescheduleController =
      TextEditingController();
  final TextEditingController _newDateController = TextEditingController();

  bool _isSubmitting = false;

  bool _isLoadingSlots = false;
  List<Map<String, dynamic>> _availableSlots = [];
  String _selectedTimeFilter = 'Pagi';
  String? _selectedNewStartTime;
  String? _selectedNewEndTime;
  int? _selectedNewPrice;
  
  @override
  void initState() {
    super.initState();
    _loadBookingData();
  }

  Future<void> _loadBookingData() async {
    setState(() => _isLoadingData = true);
    try {
      final data = await BookingService.fetchBookingDetail(widget.bookingId);

      String dateStr = data['time_info']['play_date'];
      String timeStr = data['time_info']['play_time'];
      _status = data['status'] ?? 'Unknown';
      _isFieldClosure = _status.toString().toLowerCase() == 'field closure';

      try {
        DateTime parsedDate = DateFormat(
          "EEEE, MMMM dd, yyyy",
          "en_US",
        ).parse(dateStr);
        
        String endTimeStr = timeStr.split(' - ')[1].trim();
        List<String> timeParts = endTimeStr.split(':');
        
        DateTime finalDateTime = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        _isPast = finalDateTime.isBefore(DateTime.now());

        // --- HITUNG APAKAH JADWAL MEPET H-3 ---
        DateTime todayOnly = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        DateTime playDateOnly = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        
        int diffDays = playDateOnly.difference(todayOnly).inDays;
        _isMepet = diffDays < 3; // Jika selisih kurang dari 3 hari, berarti Mepet!

      } catch (e) {
        print("Gagal parsing waktu: $e");
        _isPast = false;
        _isMepet = false;
      }

      int totalPrice = data['service_info']['total_price'] ?? 0;
      _totalPaid = data['service_info']['total_down_payment'] ?? 0;
      _remainingPayment = totalPrice - _totalPaid;

      // --- LOGIKA SMART DEFAULT REFUND ---
      if (_isFieldClosure) {
        _refundStatus = 'Full'; // Jika lapangan tutup, otomatis Full Refund
      } else if (_isMepet) {
        _refundStatus = 'None'; // Jika mepet biasa, otomatis dilarang Refund
      }

      setState(() {
        _bookingData = data;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        context.pop();
      }
    }
  }

  Future<void> _loadSlotsForNewDate(String formattedDate) async {
    setState(() {
      _isLoadingSlots = true;
      _availableSlots = [];
      _selectedNewStartTime = null;
      _selectedNewEndTime = null;
    });

    try {
      if (_fieldId == 0) {
        final fields = await FieldService.fetchListField();
        final fieldName = _bookingData!['field_info']['name'];
        var currentField = fields.firstWhere(
          (f) => f['name'] == fieldName,
          orElse: () => fields[0],
        );
        _fieldId = currentField['id'] is int
            ? currentField['id']
            : int.parse(currentField['id'].toString());
      }

      final rawSlots = await FieldService.checkAvailability(
        fieldId: _fieldId,
        date: formattedDate,
      );

      if (mounted) {
        setState(() {
          _availableSlots = rawSlots
              .map((slot) => slot as Map<String, dynamic>)
              .toList();
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSlots = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengecek slot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _reasonCancelController.dispose();
    _reasonRescheduleController.dispose();
    _newDateController.dispose();
    super.dispose();
  }

  Future<void> _submitReschedule() async {
    if (_newDateController.text.isEmpty ||
        _selectedNewStartTime == null ||
        _selectedNewEndTime == null ||
        _reasonRescheduleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih slot jam dan isi alasan Reschedule!'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      String safeStartTime = _selectedNewStartTime!;
      String safeEndTime = _selectedNewEndTime!;

      if (safeStartTime.length >= 5) safeStartTime = safeStartTime.substring(0, 5);
      if (safeEndTime.length >= 5) safeEndTime = safeEndTime.substring(0, 5);

      await BookingService.rescheduleBooking(
        detailBookingId: widget.bookingId,
        newPlayDate: _newDateController.text,
        newStartTime: safeStartTime,
        newEndTime: safeEndTime,
        reason: _reasonRescheduleController.text,
        newPrice: _selectedNewPrice, 
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal berhasil di-Reschedule!'),
            backgroundColor: Colors.green,
          ),
        );
        _newDateController.clear();
        _selectedNewStartTime = null;
        _selectedNewEndTime = null;
        _reasonRescheduleController.clear();
        _availableSlots.clear();
        _loadBookingData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitCancel() async {
    if (_reasonCancelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan pembatalan wajib diisi!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await BookingService.cancelBooking(
        detailBookingId: widget.bookingId,
        reason: _reasonCancelController.text,
        statusRefund: _refundStatus, // --- KIRIM STATUS REFUND KE BACKEND ---
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibatalkan!'),
            backgroundColor: Colors.green,
          ),
        );
        _reasonCancelController.clear();
        _loadBookingData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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

  String formatTimeSlot(String startTime, String endTime) {
    try {
      final start = startTime.split(':')[0];
      final end = endTime.split(':')[0];
      return '$start.00 - $end.00';
    } catch (e) {
      return '$startTime - $endTime';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text(
          'Detail & Modify Booking',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  if (_status == 'Cancelled')
                    _buildInfoBox(
                      'Pesanan ini sudah Dibatalkan.',
                      Colors.red.shade100,
                      Colors.red.shade800,
                    )
                  else if (_status == 'Rescheduled')
                    _buildInfoBox(
                      'Jadwal ini telah dipindah ke hari/jam lain. Riwayat ini tidak bisa diubah lagi.',
                      Colors.orange.shade100,
                      Colors.orange.shade800,
                    )
                  else if (_isPast)
                    _buildInfoBox(
                      'Waktu main sudah lewat. Pesanan tidak bisa diubah lagi.',
                      Colors.grey.shade300,
                      Colors.black87,
                    )
                  else
                    _buildInteractiveForm(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final formatRp = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    // Warna dan gaya khusus jika lapangan ditutup
    Color cardColor = _isFieldClosure ? Colors.purple.shade50 : const Color(0xFFE8F5E9);
    Color borderColor = _isFieldClosure ? Colors.purple.shade200 : Colors.green.shade200;
    Color iconBgColor = _isFieldClosure ? Colors.purple : const Color(0xFF4CAF50);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.sports_soccer,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _bookingData!['user_info']['name'] ?? 'Unknown Tenant',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _bookingData!['field_info']['name'] ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_bookingData!['time_info']['play_date']} | ${_bookingData!['time_info']['play_time']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status: ${_status.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _status == 'Cancelled'
                                ? Colors.red
                                : (_status == 'Rescheduled'
                                      ? Colors.orange
                                      : (_isFieldClosure ? Colors.purple : Colors.green.shade800)),
                          ),
                        ),
                        Text(
                          'ID: ${widget.bookingId}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // =======================================================
          // LOGIKA PEMBAYARAN: FIELD CLOSURE vs NORMAL vs KEMBALIAN
          // =======================================================
          if (!_isPast && _status != 'Cancelled' && _status != 'Rescheduled') ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: _isFieldClosure ? Colors.purple.shade100 : Colors.white, thickness: 2),
            ),
            
            // JIKA LAPANGAN TUTUP: Tampilkan uang yang sudah disetor untuk direfund
            if (_isFieldClosure)
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Telah Dibayar:',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        formatRp.format(_totalPaid),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple.shade400),
                    ),
                    child: const Text(
                      'REFUNDABLE',
                      style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ],
              )
            // JIKA NORMAL: Tampilkan Sisa Tagihan, Kembalian, atau Lunas
            else if (_remainingPayment < 0)
              // KONDISI 1: NGURANG HARGA (LEBIH BAYAR / KEMBALIAN)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kelebihan Bayar (Kembalian):',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        formatRp.format(_remainingPayment.abs()), // Hilangkan tanda minus
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade400),
                    ),
                    child: const Text(
                      'KEMBALIKAN',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ],
              )
            else if (_remainingPayment > 0)
              // KONDISI 2: NAMBAH HARGA ATAU BELUM LUNAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sisa Tagihan:',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        formatRp.format(_remainingPayment),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push(
                        '/admin/payment-details',
                        extra: {
                          'nameField': _bookingData!['field_info']['name'],
                          'nameTenant': _bookingData!['user_info']['name'],
                          'selectedDate': DateTime.now(),
                          'hours': _bookingData!['time_info']['play_time'],
                          'duration': _bookingData!['service_info']['duration'],
                          'totalPrice': _bookingData!['service_info']['total_price'],
                          'downPaymentPrice': _totalPaid,
                          'statusEarly': 'Lunas',
                          'bookingId': _bookingData!['id'], 
                          'paymentAmount': _remainingPayment,
                        },
                      );
                    },
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('Lunasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                ],
              )
            else
              // KONDISI 3: PAS / LUNAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sisa Tagihan:',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        'Rp 0',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade400),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'LUNAS',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoBox(String message, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isFieldClosure ? Colors.purple.shade50 : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (_isFieldClosure) ...[
             const Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.warning_amber_rounded, color: Colors.purple),
                 SizedBox(width: 8),
                 Text('PENUTUPAN LAPANGAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 16)),
               ],
             ),
             const SizedBox(height: 8),
             const Text(
               'Lapangan sedang ditutup operasional. Berikan solusi kepada Customer dengan memindahkan jadwal (bebas hambatan H-3) atau lakukan pembatalan pesanan.',
               textAlign: TextAlign.center,
               style: TextStyle(fontSize: 12, color: Colors.black87),
             ),
             const SizedBox(height: 20),
          ] else ...[
             const Text(
              'Modify / Cancel Order',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 20),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TabButton(
                title: 'Reschedule',
                icon: Icons.edit_calendar,
                isActive: _activeTab == 'Reschedule',
                activeColor: _isFieldClosure ? Colors.purple.shade300 : const Color(0xFF64B5F6),
                onTap: () => setState(() => _activeTab = 'Reschedule'),
              ),
              const SizedBox(width: 8),
              TabButton(
                title: 'Cancel',
                icon: Icons.cancel_outlined,
                isActive: _activeTab == 'Cancel',
                activeColor: const Color(0xFFE57373),
                onTap: () => setState(() => _activeTab = 'Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 215, 222, 228),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _activeTab == 'Reschedule'
                ? _buildRescheduleForm()
                : _buildCancelForm(),
          ),
          
          // Jika Reschedule diblokir karena H-3, sembunyikan tombol simpan
          if (_activeTab == 'Reschedule' && _isMepet && !_isFieldClosure)
             const SizedBox.shrink()
          else ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : (_activeTab == 'Reschedule'
                        ? _submitReschedule
                        : _submitCancel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFieldClosure && _activeTab == 'Reschedule' ? Colors.purple.shade300 : const Color(0xFFFFCC80),
                  foregroundColor: _isFieldClosure && _activeTab == 'Reschedule' ? Colors.white : Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // FORM KHUSUS RESCHEDULE
  Widget _buildRescheduleForm() {
    // --- LOGIKA HAMBATAN H-3 ---
    if (_isMepet && !_isFieldClosure) {
      return _buildInfoBox(
        'Maaf, Reschedule tidak diizinkan karena jadwal main kurang dari H-3. Perubahan mendadak melanggar aturan operasional.',
        Colors.red.shade100,
        Colors.red.shade800,
      );
    }

    var filteredSlots = _availableSlots
        .where((slot) => getTimeType(slot['start']) == _selectedTimeFilter)
        .toList();
    final formatRp = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputField(
          label: 'Current Schedule (Read-only)',
          initialValue:
              '${_bookingData!['time_info']['play_date']} | ${_bookingData!['time_info']['play_time']}',
          isEnabled: false,
        ),
        const SizedBox(height: 16),

        InputField(
          label: 'New Play Date',
          hint: 'Select New Date',
          controller: _newDateController,
          icon: Icons.calendar_today,
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            if (pickedDate != null) {
              String newDate = DateFormat('yyyy-MM-dd').format(pickedDate);
              setState(() => _newDateController.text = newDate);
              _loadSlotsForNewDate(newDate);
            }
          },
        ),
        const SizedBox(height: 16),

        if (_newDateController.text.isNotEmpty) ...[
          const Text(
            'Select Available Slot',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Pagi', 'Siang', 'Sore', 'Malam']
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(e),
                        selected: _selectedTimeFilter == e,
                        selectedColor: _isFieldClosure ? Colors.purple.shade200 : const Color(0xFF64B5F6),
                        onSelected: (_) =>
                            setState(() => _selectedTimeFilter = e),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          if (_isLoadingSlots)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filteredSlots.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Tidak ada slot tersedia di waktu ini',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          else
            ...filteredSlots.map((slot) {
              final bool isAvailable = slot['is_available'] ?? true;
              final bool isSelected =
                  _selectedNewStartTime == slot['start'] &&
                  _selectedNewEndTime == slot['end'];
              final int price = slot['price'] is int
                  ? slot['price']
                  : int.tryParse(slot['price'].toString()) ?? 0;

              return GestureDetector(
                onTap: isAvailable
                    ? () {
                        setState(() {
                          _selectedNewStartTime = slot['start'];
                          _selectedNewEndTime = slot['end'];
                          _selectedNewPrice = price;
                        });
                      }
                    : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: !isAvailable
                        ? Colors.grey.shade300
                        : (isSelected ? (_isFieldClosure ? Colors.purple.shade100 : Colors.blue.shade100) : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? (_isFieldClosure ? Colors.purple : Colors.blue) : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatTimeSlot(slot['start'], slot['end']),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: !isAvailable
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          Text(
                            !isAvailable ? 'Booked' : formatRp.format(price),
                            style: TextStyle(
                              color: !isAvailable ? Colors.red : Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: _isFieldClosure ? Colors.purple : Colors.blue),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
        ],

        const Text(
          'Reason for Reschedule',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonRescheduleController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: _isFieldClosure ? 'Pindah jadwal akibat lapangan ditutup...' : 'Mengapa jadwal dipindah...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // FORM KHUSUS CANCEL
  Widget _buildCancelForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LOGIKA HAMBATAN H-3 UNTUK REFUND ---
        if (_isMepet && !_isFieldClosure) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Pembatalan kurang dari H-3 tidak bisa mendapatkan Refund.', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        const Text(
          'Status Refund',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: (_isMepet && !_isFieldClosure) ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _refundStatus,
              // JIKA NORMAL MEPET H-3: Disable Dropdown (Pasti None)
              onChanged: (_isMepet && !_isFieldClosure) 
                  ? null 
                  : (String? newValue) {
                      setState(() {
                        _refundStatus = newValue!;
                      });
                    },
              items: const [
                DropdownMenuItem(value: 'None', child: Text('None (Tidak ada Refund)')),
                DropdownMenuItem(value: 'Full', child: Text('Full Refund (Kembali Penuh)')),
                DropdownMenuItem(value: 'Partial', child: Text('Partial Refund (Sebagian)')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Reason for Cancellation',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonCancelController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Tulis alasan mengapa pesanan ini dibatalkan...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}