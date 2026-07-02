import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/info_box.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/components/tab_button.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class ChangeBookingAdminScreen extends StatefulWidget {
  final String bookingId;
  const ChangeBookingAdminScreen({super.key, required this.bookingId});

  @override
  State<ChangeBookingAdminScreen> createState() => _ChangeBookingAdminScreenState();
}

class _ChangeBookingAdminScreenState extends State<ChangeBookingAdminScreen> {
  String _activeTab = 'Reschedule';
  bool _isLoadingData = true;
  bool _isSubmitting = false;
  bool _isLoadingSlots = false;

  Map<String, dynamic>? _bookingData;
  Map<String, dynamic>? _sessionData;

  String _status = '';
  int _totalPaid = 0;
  int _remainingPayment = 0;
  int _fieldId = 0;

  String _timeDistanceInfo = '';
  String _refundStatus = 'None';
  final TextEditingController _customRefundController = TextEditingController(text: '0');
  String _rescheduleFinancialAction = 'Settle_Later';
  int _financialDelta = 0;

  final TextEditingController _reasonCancelController = TextEditingController();
  final TextEditingController _reasonRescheduleController = TextEditingController();
  final TextEditingController _newDateController = TextEditingController();

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

  @override
  void dispose() {
    _reasonCancelController.dispose();
    _reasonRescheduleController.dispose();
    _newDateController.dispose();
    _customRefundController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingData() async {
    try {
      final data = await BookingService.fetchBookingDetail(widget.bookingId);
      final sessions = data['sessions'] as List;
      final sessionData = sessions.firstWhere((s) => s['id'].toString() == widget.bookingId) as Map<String, dynamic>;

      _status = sessionData['status'] ?? 'Unknown';
      _totalPaid = int.tryParse(sessionData['total_paid']?.toString() ?? '0') ?? 0;
      _remainingPayment = int.tryParse(sessionData['remaining_payment']?.toString() ?? '0') ?? 0;
      _fieldId = int.tryParse(data['field_info']?['id']?.toString() ?? '0') ?? 0;

      try {
        DateTime playDate = DateFormat("dd MMMM yyyy", "id_ID").parse(sessionData['play_date']);
        List<String> timeParts = sessionData['start_time'].toString().split(':');
        DateTime playDateTime = DateTime(playDate.year, playDate.month, playDate.day, int.parse(timeParts[0]), int.parse(timeParts[1]));

        Duration diff = playDateTime.difference(DateTime.now());
        if (playDateTime.isBefore(DateTime.now())) {
          _timeDistanceInfo = "Waktu bermain telah terlewat.";
        } else {
          _timeDistanceInfo = "Jadwal main ${diff.inDays} Hari ${diff.inHours % 24} Jam lagi dari sekarang.";
        }
      } catch (_) {
        _timeDistanceInfo = "Informasi waktu bermain tidak terbaca.";
      }

      if (mounted) {
        setState(() {
          _bookingData = data;
          _sessionData = sessionData;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed));
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
      _financialDelta = 0;
    });
    try {
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed));
      }
    }
  }

  void _calculateRescheduleFinance(int newSlotPrice) {
    final int oldPrice = _sessionData!['price'] ?? 0;
    setState(() {
      _selectedNewPrice = newSlotPrice;
      _financialDelta = newSlotPrice - oldPrice;
    });
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
        newPrice: _selectedNewPrice!,
        financialAction: _rescheduleFinancialAction,
        reconciledAmount: _financialDelta.abs(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reschedule & Finansial terekam!'), backgroundColor: AppThemeConstants.successGreen));
        context.pop();
      }
    } catch (e) {
      if (mounted) { setState(() => _isSubmitting = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed)); }
    }
  }

  Future<void> _submitCancel() async {
    if (_reasonCancelController.text.isEmpty) return;
    setState(() => _isSubmitting = true);

    int finalRefundFormAmount = 0;
    if (_refundStatus != 'None') {
      finalRefundFormAmount = int.tryParse(_customRefundController.text) ?? 0;
    }

    try {
      await BookingService.cancelBooking(
        detailBookingId: widget.bookingId,
        reason: _reasonCancelController.text,
        statusRefund: _refundStatus,
        refundAmount: finalRefundFormAmount,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesi Berhasil Dibatalkan!'), backgroundColor: AppThemeConstants.successGreen));
        context.pop();
      }
    } catch (e) {
      if (mounted) { setState(() => _isSubmitting = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed)); }
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
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary), onPressed: () => context.pop()),
        title: const Text('Detail & Modifikasi Sesi', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 12),
                  InfoBox(
                    message: "Panduan Aturan Bisnis Kasir:\n$_timeDistanceInfo",
                    backgroundColor: Colors.blue.shade50,
                    textColor: AppThemeConstants.primaryBlue
                  ),
                  const SizedBox(height: 16),
                  if (_status.toLowerCase().contains('cancel'))
                    const InfoBox(message: 'Sesi ini sudah Dibatalkan.', backgroundColor: AppThemeConstants.lightRed, textColor: AppThemeConstants.errorRed)
                  else
                    _buildInteractiveForm(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppThemeConstants.lightBlue, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppThemeConstants.borderGrey)),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundColor: AppThemeConstants.primaryBlue, child: const Icon(Icons.sports_soccer, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_bookingData!['user_info']['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${_sessionData!['play_date']} | ${_sessionData!['start_time']} - ${_sessionData!['end_time']}', style: const TextStyle(fontSize: 12)),
                    Text('Harga Awal Sesi: ${formatRp.format(_sessionData!['price'] ?? 0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          if (_remainingPayment > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sisa Tagihan: ${formatRp.format(_remainingPayment)}', style: const TextStyle(color: AppThemeConstants.errorRed, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () {
                    context.push('/admin/payment-details', extra: {
                      'nameField': _bookingData?['field_info']?['name'] ?? '-',
                      'nameTenant': _bookingData?['user_info']?['name'] ?? '-',
                      'selectedDate': DateTime.now(),
                      'hours': '${_sessionData!['start_time']} - ${_sessionData!['end_time']}',
                      'duration': int.tryParse(_bookingData?['service_info']?['duration']?.toString() ?? '1') ?? 1,
                      'totalPrice': _sessionData!['price'] ?? 0,
                      'downPaymentPrice': _totalPaid,
                      'statusEarly': 'Lunas',
                      'bookingId': int.tryParse(_bookingData?['booking_id']?.toString() ?? '0') ?? 0,
                      'bookingDetailId': int.tryParse(_sessionData?['id']?.toString() ?? '0'),
                      'paymentAmount': _remainingPayment,
                    });
                  },
                  child: const Text('Lunasi'),
                )
              ],
            )
        ],
      ),
    );
  }

  Widget _buildInteractiveForm() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TabButton(title: 'Reschedule', icon: Icons.edit_calendar, isActive: _activeTab == 'Reschedule', activeColor: const Color(0xFF64B5F6), onTap: () => setState(() => _activeTab = 'Reschedule')),
            const SizedBox(width: 12),
            TabButton(title: 'Cancel Sesi', icon: Icons.cancel_outlined, isActive: _activeTab == 'Cancel', activeColor: AppThemeConstants.errorRed, onTap: () => setState(() => _activeTab = 'Cancel')),
          ],
        ),
        const SizedBox(height: 16),
        _activeTab == 'Reschedule' ? _buildRescheduleForm() : _buildCancelForm(),
        const SizedBox(height: 24),
        _isSubmitting
            ? const CircularProgressIndicator()
            : SizedBox(width: double.infinity, child: AppButton(label: 'Simpan Perubahan', onPressed: _activeTab == 'Reschedule' ? _submitReschedule : _submitCancel))
      ],
    );
  }

  Widget _buildRescheduleForm() {
    var filteredSlots = _availableSlots.where((slot) => _getTimeType(slot['start']) == _selectedTimeFilter).toList();
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppInputField(
          label: 'Tanggal Reschedule Baru',
          hint: 'Pilih Tanggal Baru',
          controller: _newDateController,
          icon: Icons.calendar_today,
          readOnly: true,
          onTap: () async {
            DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 7)), lastDate: DateTime(2030));
            if (picked != null) {
              String newDate = DateFormat('yyyy-MM-dd').format(picked);
              setState(() => _newDateController.text = newDate);
              _loadSlotsForNewDate(newDate);
            }
          },
        ),
        const SizedBox(height: 12),
        if (_newDateController.text.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            value: _selectedTimeFilter,
            items: ['Pagi', 'Siang', 'Sore', 'Malam'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedTimeFilter = v ?? 'Pagi'),
          ),
          const SizedBox(height: 12),
          const Text('Pilih Slot Waktu Operasional:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          if (_isLoadingSlots)
            const Center(child: CircularProgressIndicator())
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredSlots.length,
              itemBuilder: (context, idx) {
                final slot = filteredSlots[idx];
                final bool isAvailable = slot['is_available'] ?? true;
                final bool isSelected = _selectedNewStartTime == slot['start'];
                final int price = int.tryParse(slot['price']?.toString() ?? '0') ?? 0;

                return ListTile(
                  title: Text('${slot['start'].toString().substring(0,5)} - ${slot['end'].toString().substring(0,5)}'),
                  trailing: Text(formatRp.format(price)),
                  selected: isSelected,
                  enabled: isAvailable,
                  onTap: () {
                    setState(() {
                      _selectedNewStartTime = slot['start'];
                      _selectedNewEndTime = slot['end'];
                    });
                    _makeMakeFinanceDelta(price);
                  },
                );
              },
            ),
        ],
        if (_selectedNewStartTime != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _financialDelta < 0 ? Colors.green.shade50 : (_financialDelta > 0 ? Colors.orange.shade50 : Colors.grey.shade50), borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _financialDelta < 0
                      ? 'Kelebihan Pembayaran (Kembalikan ke Penyewa): ${formatRp.format(_financialDelta.abs())}'
                      : (_financialDelta > 0 ? 'Kekurangan Tagihan (Penyewa Harus Bayar): ${formatRp.format(_financialDelta)}' : 'Harga slot sama. Finansial Balance.'),
                  style: TextStyle(fontWeight: FontWeight.bold, color: _financialDelta < 0 ? Colors.green : (_financialDelta > 0 ? Colors.orange.shade900 : Colors.black87)),
                ),
                if (_financialDelta != 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Status Pembayaran Kasir: ', style: TextStyle(fontSize: 12)),
                      const Spacer(),
                      ChoiceChip(
                        label: const Text('Lunas / Selesai'),
                        selected: _rescheduleFinancialAction == 'Lunas',
                        onSelected: (val) => setState(() => _rescheduleFinancialAction = val ? 'Lunas' : 'Settle_Later'),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Nanti'),
                        selected: _rescheduleFinancialAction == 'Settle_Later',
                        onSelected: (val) => setState(() => _rescheduleFinancialAction = val ? 'Settle_Later' : 'Lunas'),
                      ),
                    ],
                  )
                ]
              ],
            ),
          )
        ],
        const SizedBox(height: 12),
        AppInputField(label: 'Alasan Reschedule', controller: _reasonRescheduleController, maxLines: 2),
      ],
    );
  }

  void _makeMakeFinanceDelta(int price) {
    _calculateRescheduleFinance(price);
  }

  Widget _buildCancelForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _refundStatus,
          decoration: const InputDecoration(labelText: 'Skema Kebijakan Refund Kasir'),
          items: const [
            DropdownMenuItem(value: 'None', child: Text('Tanpa Refund (0%)')),
            DropdownMenuItem(value: 'Partial', child: Text('Sebagian (Custom / Otomatis 50%)')),
            DropdownMenuItem(value: 'Full', child: Text('Refund Penuh (100%)')),
          ],
          onChanged: (v) {
            setState(() {
              _refundStatus = v ?? 'None';
              if (_refundStatus == 'Full') {
                _customRefundController.text = _totalPaid.toString();
              } else if (_refundStatus == 'Partial') {
                _customRefundController.text = (_totalPaid * 0.5).toInt().toString();
              } else {
                _customRefundController.text = '0';
              }
            });
          },
        ),
        if (_refundStatus == 'Partial') ...[
          const SizedBox(height: 12),
          AppInputField(
            label: 'Nominal Uang Refund Tunai (Rp)',
            controller: _customRefundController,
            keyboardType: TextInputType.number,
            icon: Icons.money,
          ),
        ],
        const SizedBox(height: 12),
        AppInputField(label: 'Alasan Pembatalan Sesi', controller: _reasonCancelController, maxLines: 2),
      ],
    );
  }
}
