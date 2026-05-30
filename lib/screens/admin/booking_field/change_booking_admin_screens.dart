import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/info_box.dart';
import 'package:pbl_app_joglo66/components/input_field.dart';
import 'package:pbl_app_joglo66/components/tab_button.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChangeBookingAdminScreens extends StatefulWidget {
  final String bookingId;

  const ChangeBookingAdminScreens({super.key, required this.bookingId});

  @override
  State<ChangeBookingAdminScreens> createState() => _ChangeBookingAdminScreenState();
}

class _ChangeBookingAdminScreenState extends State<ChangeBookingAdminScreens> {
  String _activeTab = 'Reschedule';
  bool _isLoadingData = true;
  bool _isSubmitting = false;
  bool _isLoadingSlots = false;

  Map<String, dynamic>? _bookingData;
  Map<String, dynamic>? _sessionData;
  
  bool _isPast = false;
  bool _isMepet = false;
  bool _isFieldClosure = false;
  
  String _status = '';
  int _totalPaid = 0;
  String _refundStatus = 'None';
  int _remainingPayment = 0;
  int _fieldId = 0;

  final TextEditingController _reasonCancelController = TextEditingController();
  final TextEditingController _reasonRescheduleController = TextEditingController();
  final TextEditingController _newDateController = TextEditingController();

  List<Map<String, dynamic>> _availableSlots = [];
  List<Map<String, dynamic>> _fieldClosures = [];
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
      final sessions = data['sessions'] as List;
      final sessionData = sessions.firstWhere((s) => s['id'].toString() == widget.bookingId);

      _status = sessionData['status'] ?? 'Unknown';
      _isFieldClosure = _status.toLowerCase().contains('field closure');

      try {
        DateTime parsedDate = DateFormat("dd MMMM yyyy", "id_ID").parse(sessionData['play_date']);
        List<String> timeParts = sessionData['end_time'].toString().split(':');
        DateTime finalDateTime = DateTime(parsedDate.year, parsedDate.month, parsedDate.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
        _isPast = finalDateTime.isBefore(DateTime.now());

        DateTime todayOnly = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        _isMepet = parsedDate.difference(todayOnly).inDays < 3;
      } catch (_) {
        try {
          DateTime parsedDate = DateFormat("dd MMM yyyy").parse(sessionData['play_date']);
          DateTime todayOnly = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          _isMepet = parsedDate.difference(todayOnly).inDays < 3;
        } catch (_) {
          _isPast = false;
          _isMepet = false;
        }
      }

      _totalPaid = int.tryParse(sessionData['total_paid']?.toString() ?? '0') ?? 0;
      _remainingPayment = int.tryParse(sessionData['remaining_payment']?.toString() ?? '0') ?? 0;

      if (_isFieldClosure) {
        _refundStatus = 'Full';
      } else if (_isMepet) {
        _refundStatus = 'None';
      }

      // TARIK DATA CLOSURES LANGSUNG DARI JSON RESPONSE (Tidak panggil API lagi)
      _fieldClosures = List<Map<String, dynamic>>.from(data['field_closures'] ?? []);
      _fieldId = int.tryParse(data['field_info']?['id']?.toString() ?? '0') ?? 0;

      setState(() {
        _bookingData = data;
        _sessionData = sessionData;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
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
        var currentField = fields.firstWhere((f) => f['name'] == fieldName, orElse: () => fields[0]);
        _fieldId = int.tryParse(currentField['id'].toString()) ?? 0;
      }

      final rawSlots = await FieldService.checkAvailability(fieldId: _fieldId, date: formattedDate);

      if (mounted) {
        setState(() {
          _availableSlots = rawSlots.map((slot) => slot as Map<String, dynamic>).toList();
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSlots = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
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
    if (_newDateController.text.isEmpty || _selectedNewStartTime == null || _reasonRescheduleController.text.isEmpty) return;
    setState(() => _isSubmitting = true);
    
    try {
      await BookingService.rescheduleBooking(
        detailBookingId: widget.bookingId,
        newPlayDate: _newDateController.text,
        newStartTime: _selectedNewStartTime!.substring(0, 5),
        newEndTime: _selectedNewEndTime!.substring(0, 5),
        reason: _reasonRescheduleController.text,
        newPrice: _selectedNewPrice, 
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil Reschedule!'), backgroundColor: Colors.green));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _submitCancel() async {
    if (_reasonCancelController.text.isEmpty) return;
    setState(() => _isSubmitting = true);

    try {
      await BookingService.cancelBooking(
        detailBookingId: widget.bookingId,
        reason: _reasonCancelController.text,
        statusRefund: _refundStatus,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan Dibatalkan!'), backgroundColor: Colors.green));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _handleKembalian() async {
    setState(() => _isSubmitting = true);
    try {
      final baseUrl = dotenv.env['API_BASE_URL']!;
      final url = Uri.parse('$baseUrl/api/admin/refund-overpayment/${widget.bookingId}');
      final response = await ApiClient.post(url, headers: BookingService.headers, body: jsonEncode({}));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kelebihan pembayaran berhasil dikembalikan tunai!'), backgroundColor: Colors.green));
          context.pop();
        }
      } else {
        throw Exception(jsonData['message'] ?? 'Gagal memproses refund kelebihan.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    }
  }

  String _getTimeType(String startTime) {
    try {
      final hour = int.parse(startTime.split(':')[0]);
      if (hour >= 6 && hour < 12) return 'Pagi';
      if (hour >= 12 && hour < 15) return 'Siang';
      if (hour >= 15 && hour < 18) return 'Sore';
      return 'Malam';
    } catch (_) {
      return 'Pagi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => context.pop()),
        title: const Text('Detail & Modify Booking', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  if (_status.toLowerCase().contains('cancel'))
                    InfoBox(message: 'Sesi ini sudah Dibatalkan.', backgroundColor: Colors.red.shade100, textColor: Colors.red.shade800)
                  else if (_isPast)
                    InfoBox(message: 'Waktu main sudah lewat.', backgroundColor: Colors.grey.shade300, textColor: Colors.black87)
                  else if (_isMepet && !_isFieldClosure)
                    InfoBox(message: 'Batas operasional H-3 terlewati. Pesanan terkunci untuk modifikasi formulir jadwal.', backgroundColor: Colors.orange.shade100, textColor: Colors.orange.shade900)
                  else
                    _buildInteractiveForm(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final statusLower = _status.toLowerCase();
    final isCancelled = statusLower.contains('cancel');
    
    Color cardColor = _isFieldClosure ? Colors.purple.shade50 : const Color(0xFFE8F5E9);
    Color borderColor = _isFieldClosure ? Colors.purple.shade200 : Colors.green.shade200;
    Color iconBgColor = _isFieldClosure ? Colors.purple : const Color(0xFF4CAF50);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.sports_soccer, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_bookingData!['user_info']['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(_bookingData!['field_info']['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${_sessionData!['play_date']} | ${_sessionData!['start_time']} - ${_sessionData!['end_time']}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('Status: ${_status.toUpperCase()}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: iconBgColor)),
                  ],
                ),
              ),
            ],
          ),
          if (!isCancelled) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(thickness: 1)),
            if (_isFieldClosure)
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Telah Dibayar:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text(formatRp.format(_totalPaid), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(8)),
                    child: const Text('REFUNDABLE', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            else if (_remainingPayment > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sisa Tagihan Sesi:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text(formatRp.format(_remainingPayment), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final serviceInfo = _bookingData?['service_info'] ?? {'duration': 1};
                      final int? bId = int.tryParse(_bookingData?['booking_id']?.toString() ?? widget.bookingId);
                      final int durationValue = int.tryParse(serviceInfo['duration'].toString()) ?? 1;
                      
                      context.push(
                        '/admin/payment-details',
                        extra: {
                          'nameField': _bookingData?['field_info']?['name'] ?? '-',
                          'nameTenant': _bookingData?['user_info']?['name'] ?? '-',
                          'selectedDate': DateTime.now(),
                          'hours': '${_sessionData!['start_time']} - ${_sessionData!['end_time']}',
                          'duration': durationValue,
                          'totalPrice': _sessionData!['price'] ?? 0,
                          'downPaymentPrice': _totalPaid,
                          'statusEarly': 'Lunas',
                          'bookingId': bId, 
                          'paymentAmount': _remainingPayment,
                        },
                      );
                    },
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('Lunasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )
                ],
              )
            else if (_remainingPayment < 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kelebihan Bayar:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text(formatRp.format(_remainingPayment.abs()), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _handleKembalian,
                    icon: const Icon(Icons.assignment_return, size: 16),
                    label: const Text('Kembalikan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Harga Sesi:', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text(formatRp.format(_sessionData!['price']), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.green.shade300)),
                    child: const Text('LUNAS', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              )
          ],
        ],
      ),
    );
  }

  Widget _buildInteractiveForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _isFieldClosure ? Colors.purple.shade50 : const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TabButton(title: 'Reschedule', icon: Icons.edit_calendar, isActive: _activeTab == 'Reschedule', activeColor: _isFieldClosure ? Colors.purple.shade300 : const Color(0xFF64B5F6), onTap: () => setState(() => _activeTab = 'Reschedule')),
              const SizedBox(width: 8),
              TabButton(title: 'Cancel', icon: Icons.cancel_outlined, isActive: _activeTab == 'Cancel', activeColor: const Color(0xFFE57373), onTap: () => setState(() => _activeTab = 'Cancel')),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: _activeTab == 'Reschedule' ? _buildRescheduleForm() : _buildCancelForm(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : (_activeTab == 'Reschedule' ? _submitReschedule : _submitCancel),
              style: ElevatedButton.styleFrom(
                backgroundColor: _activeTab == 'Reschedule' ? const Color(0xFF64B5F6) : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescheduleForm() {
    var filteredSlots = _availableSlots.where((slot) => _getTimeType(slot['start']) == _selectedTimeFilter).toList();
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputField(
          label: 'Current Schedule',
          initialValue: '${_sessionData!['play_date']} | ${_sessionData!['start_time']} - ${_sessionData!['end_time']}',
          isEnabled: false,
        ),
        const SizedBox(height: 16),
        InputField(
          label: 'New Play Date',
          hint: 'Pilih Tanggal Baru',
          controller: _newDateController,
          icon: Icons.calendar_today,
          readOnly: true,
          onTap: () async {
            DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
            if (picked != null) {
              String newDate = DateFormat('yyyy-MM-dd').format(picked);
              setState(() => _newDateController.text = newDate);
              _loadSlotsForNewDate(newDate);
            }
          },
        ),
        const SizedBox(height: 16),
        if (_newDateController.text.isNotEmpty) ...[
          const Text('Select Available Slot', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Pagi', 'Siang', 'Sore', 'Malam'].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e),
                    selected: _selectedTimeFilter == e,
                    selectedColor: Colors.blue.shade100,
                    onSelected: (_) => setState(() => _selectedTimeFilter = e),
                  ),
                ),
              ).toList(),
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingSlots)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
          else if (filteredSlots.isEmpty)
            const Text('Tidak ada slot tersedia di waktu ini', style: TextStyle(color: Colors.red))
          else
            ...filteredSlots.map((slot) {
              bool isTimePassed = false;
              if (_newDateController.text == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
                try {
                  List<String> startParts = slot['start'].toString().split(':');
                  int slotHour = int.parse(startParts[0]);
                  int slotMinute = int.parse(startParts[1]);
                  DateTime now = DateTime.now();
                  if (slotHour < now.hour || (slotHour == now.hour && slotMinute <= now.minute)) {
                    isTimePassed = true;
                  }
                } catch (_) {}
              }

              bool isInsideClosureRange = false;
              try {
                List<String> sParts = slot['start'].toString().split(':');
                List<String> eParts = slot['end'].toString().split(':');
                
                DateTime slotStartDT = DateTime.parse('${_newDateController.text} ${sParts[0].padLeft(2, '0')}:${sParts[1].padLeft(2, '0')}:00');
                DateTime slotEndDT = DateTime.parse('${_newDateController.text} ${eParts[0].padLeft(2, '0')}:${eParts[1].padLeft(2, '0')}:00');
                
                for (var closure in _fieldClosures) {
                  DateTime closureStart = DateTime.parse(closure['field_closure_start_time'].toString());
                  DateTime closureEnd = DateTime.parse(closure['field_closure_end_time'].toString());
                  
                  if (slotStartDT.isBefore(closureEnd) && slotEndDT.isAfter(closureStart)) {
                    isInsideClosureRange = true;
                    break;
                  }
                }
              } catch (_) {}

              bool isSlotClosed = (slot['is_closed'] == true) || isInsideClosureRange;
              final isAvailable = (slot['is_available'] ?? true) && !isTimePassed && !isSlotClosed;
              final isSelected = _selectedNewStartTime == slot['start'] && _selectedNewEndTime == slot['end'];
              final price = slot['price'] is int ? slot['price'] : int.tryParse(slot['price'].toString()) ?? 0;

              return GestureDetector(
                onTap: isAvailable ? () => setState(() { _selectedNewStartTime = slot['start']; _selectedNewEndTime = slot['end']; _selectedNewPrice = price; }) : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: !isAvailable ? Colors.grey.shade200 : (isSelected ? Colors.blue.shade50 : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${slot['start'].toString().split(':')[0] ?? '00'}.00 - ${slot['end'].toString().split(':')[0] ?? '00'}.00', style: TextStyle(decoration: !isAvailable ? TextDecoration.lineThrough : null)),
                      Text(!isAvailable ? (isTimePassed ? 'Sudah Lewat' : (isSlotClosed ? 'Lapangan Ditutup' : 'Booked')) : formatRp.format(price), style: TextStyle(color: !isAvailable ? Colors.red : Colors.green)),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
        ],
        const Text('Reason', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(controller: _reasonRescheduleController, maxLines: 3, decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
      ],
    );
  }

  Widget _buildCancelForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isMepet && !_isFieldClosure) ...[
          InfoBox(message: 'Pembatalan H-3 tidak mendapatkan Refund.', backgroundColor: Colors.red.shade50, textColor: Colors.red, icon: Icons.warning_amber),
          const SizedBox(height: 16),
        ],
        const Text('Status Refund', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: (_isMepet && !_isFieldClosure) ? Colors.grey.shade200 : Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _refundStatus,
              onChanged: (_isMepet && !_isFieldClosure) ? null : (v) => setState(() => _refundStatus = v!),
              items: const [
                DropdownMenuItem(value: 'None', child: Text('None (Tidak ada Refund)')),
                DropdownMenuItem(value: 'Full', child: Text('Full Refund (Kembali Penuh)')),
                DropdownMenuItem(value: 'Partial', child: Text('Partial Refund (Sebagian)')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Reason', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(controller: _reasonCancelController, maxLines: 3, decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
      ],
    );
  }
}