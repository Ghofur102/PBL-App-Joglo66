import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/components/status_badge.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/attribute_booking_service.dart';
import 'package:pbl_app_joglo66/services/attribute_service.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';

class BookingDetailsAdminScreen extends StatefulWidget {
  final String bookingId;
  const BookingDetailsAdminScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsAdminScreen> createState() =>
      _BookingDetailsAdminScreenState();
}

class _BookingDetailsAdminScreenState extends State<BookingDetailsAdminScreen> {
  Map<String, dynamic>? _bookingData;
  List<Map<String, dynamic>> _rentedAttributes = [];
  bool _isLoading = true;
  bool _isAttributeProcessing = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchBookingDetail();
    if (_bookingData != null) {
      await _fetchRentedAttributes();
    }
  }

  String _cleanError(dynamic e) {
    if (e is FormatException) return e.message;
    return e
        .toString()
        .replaceAll('FormatException: ', '')
        .replaceAll('Exception: ', '');
  }

  String _parseToYmd(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) {
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    final String trimmed = rawDate.trim();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
      return trimmed;
    }
    try {
      final DateTime parsed = DateFormat('dd MMM yyyy', 'en_US').parse(trimmed);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      try {
        final DateTime parsed = DateFormat('dd MMMM yyyy', 'en_US').parse(trimmed);
        return DateFormat('yyyy-MM-dd').format(parsed);
      } catch (_) {
        try {
          final DateTime parsed = DateTime.parse(trimmed);
          return DateFormat('yyyy-MM-dd').format(parsed);
        } catch (_) {
          return DateFormat('yyyy-MM-dd').format(DateTime.now());
        }
      }
    }
  }

  Future<void> _fetchBookingDetail() async {
    try {
      final data = await BookingService.fetchBookingDetail(widget.bookingId);
      if (mounted) {
        setState(() {
          _bookingData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _cleanError(e);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRentedAttributes() async {
    try {
      final dynamic result = await AttributeBookingService.fetchHistory();
      List<Map<String, dynamic>> list = [];

      if (result is Map<String, dynamic> && result['data'] is List) {
        list = List<Map<String, dynamic>>.from(result['data'] as List);
      } else if (result is List) {
        list = List<Map<String, dynamic>>.from(result);
      }

      final int parentBookingId =
          int.tryParse(_bookingData?['booking_id']?.toString() ?? '0') ?? 0;

      if (mounted) {
        setState(() {
          _rentedAttributes = list.where((item) {
            final fkId = int.tryParse(item['fk_booking_id']?.toString() ?? '0') ?? 0;
            return fkId == parentBookingId && parentBookingId != 0;
          }).toList();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _rentedAttributes = [];
        });
      }
    }
  }

  int _calculateSessionDurationHours(String startTimeStr, String endTimeStr) {
    try {
      final DateFormat format = DateFormat('HH:mm');
      final DateTime start = format.parse(startTimeStr.trim());
      final DateTime end = format.parse(endTimeStr.trim());
      final int diffMinutes = end.difference(start).inMinutes;
      final int hours = (diffMinutes / 60).ceil();
      return hours > 0 ? hours : 1;
    } catch (_) {
      return 1;
    }
  }

  Future<void> _processReturnItem(int rentalId, String itemName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pengembalian'),
        content: Text('Apakah Anda yakin atribut "$itemName" sudah dikembalikan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppThemeConstants.successGreen),
            child: const Text('Ya, Kembalikan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isAttributeProcessing = true);
    try {
      await AttributeBookingService.returnItem(rentalId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atribut berhasil dikembalikan, stok otomatis bertambah.'),
          backgroundColor: AppThemeConstants.successGreen,
        ),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanError(e)),
          backgroundColor: AppThemeConstants.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAttributeProcessing = false);
    }
  }

  void _showExtendConfirmationDialog(Map<String, dynamic> session) {
    final int detailId = int.tryParse(session['id']?.toString() ?? '0') ?? 0;
    final String startTime = session['start_time']?.toString() ?? '00:00';
    final String endTime = session['end_time']?.toString() ?? '00:00';
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    DateTime endDt = DateFormat('HH:mm').parse(endTime);
    DateTime newEndDt = endDt.add(const Duration(minutes: 30));
    String newEndTimeStr = DateFormat('HH:mm').format(newEndDt);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Perpanjang Waktu Main', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda ingin memperpanjang durasi sesi ini sebanyak 30 menit?', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemeConstants.bgLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppThemeConstants.borderGrey),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Waktu Saat Ini:', style: TextStyle(fontSize: 12, color: AppThemeConstants.textSecondary)),
                      Text('$startTime - $endTime', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Waktu Baru (+30 mnt):', style: TextStyle(fontSize: 12, color: AppThemeConstants.accentBlue, fontWeight: FontWeight.bold)),
                      Text('$startTime - $newEndTimeStr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppThemeConstants.accentBlue)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppThemeConstants.accentBlue),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isAttributeProcessing = true);
              try {
                final result = await BookingService.extendBookingTime(
                  bookingDetailId: detailId,
                  extendMinutes: 30,
                );

                if (!mounted) return;
                final int addedPrice = int.tryParse(result['additional_price']?.toString() ?? '0') ?? 0;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Waktu berhasil diperpanjang hingga ${result['new_end_time']}. Tagihan bertambah +${formatRp.format(addedPrice)}.'),
                    backgroundColor: AppThemeConstants.successGreen,
                  ),
                );
                _loadData();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_cleanError(e)),
                    backgroundColor: AppThemeConstants.errorRed,
                  ),
                );
              } finally {
                if (mounted) setState(() => _isAttributeProcessing = false);
              }
            },
            child: const Text('Konfirmasi & Tambah', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddAttributeModal({Map<String, dynamic>? initialSession}) async {
    final userInfo = _bookingData!['user_info'] as Map<String, dynamic>? ?? {};
    final fieldInfo = _bookingData!['field_info'] as Map<String, dynamic>? ?? {};
    final List<dynamic> sessionsRaw = (_bookingData!['sessions'] as List?) ?? [];
    final List<Map<String, dynamic>> sessions = sessionsRaw
        .map((s) => Map<String, dynamic>.from(s as Map))
        .toList();

    if (sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada sesi jadwal main pada pesanan ini.'),
          backgroundColor: AppThemeConstants.warningAmber,
        ),
      );
      return;
    }

    final fieldId = int.tryParse(fieldInfo['id']?.toString() ?? '0') ?? 0;

    List<Map<String, dynamic>> availableAttributes = [];
    try {
      final allAttr = await AttributeService.fetchListAttribute();
      availableAttributes = allAttr
          .map((a) => a as Map<String, dynamic>)
          .where((a) =>
              a['status']?.toString() == 'active' &&
              (int.tryParse(a['stock']?.toString() ?? '0') ?? 0) > 0 &&
              (int.tryParse(a['fk_field_id']?.toString() ?? '0') ?? 0) == fieldId)
          .toList();
    } catch (_) {}

    if (!mounted) return;

    if (availableAttributes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada atribut aktif yang tersedia di lapangan ini. Pastikan stok di Master Atribut tersedia.'),
          backgroundColor: AppThemeConstants.warningAmber,
        ),
      );
      return;
    }

    int? selectedSessionId = (initialSession?['id'] as int?) ??
        (sessions.isNotEmpty ? sessions.first['id'] as int? : null);
    int? selectedAttributeId = availableAttributes.first['id'] as int?;
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (contextState, setModalState) {
            final selectedSession = sessions.firstWhere(
              (s) => (s['id'] as int?) == selectedSessionId,
              orElse: () => sessions.first,
            );

            final String startTime = selectedSession['start_time']?.toString() ?? '00:00';
            final String endTime = selectedSession['end_time']?.toString() ?? '00:00';
            final int durationHours = _calculateSessionDurationHours(startTime, endTime);

            final selectedAttr = availableAttributes.firstWhere(
              (a) => a['id'] == selectedAttributeId,
              orElse: () => availableAttributes.first,
            );
            final int priceHour = int.tryParse(selectedAttr['price_hour']?.toString() ?? '0') ?? 0;
            final int stock = int.tryParse(selectedAttr['stock']?.toString() ?? '0') ?? 1;
            final int totalCost = priceHour * quantity * durationHours;
            final formatRpModal = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sewa Atribut Per Sesi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(modalCtx),
                      )
                    ],
                  ),
                  const Divider(height: 12),
                  const SizedBox(height: 8),
                  const Text('Pilih Sesi Jadwal Main:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    value: selectedSessionId,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: sessions.map((sess) {
                      final int sessId = sess['id'] as int;
                      final String date = sess['play_date']?.toString() ?? '-';
                      final String st = sess['start_time']?.toString() ?? '00:00';
                      final String et = sess['end_time']?.toString() ?? '00:00';
                      return DropdownMenuItem<int>(
                        value: sessId,
                        child: Text('$date ($st - $et)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedSessionId = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Pilih Atribut:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    value: selectedAttributeId,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: availableAttributes.map((attr) {
                      return DropdownMenuItem<int>(
                        value: attr['id'] as int,
                        child: Text('${attr['name']} (Stok: ${attr['stock']})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedAttributeId = val;
                        quantity = 1;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Jumlah (Pcs):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: quantity > 1
                                      ? () => setModalState(() => quantity--)
                                      : null,
                                ),
                                Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: quantity < stock
                                      ? () => setModalState(() => quantity++)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Durasi Sesi (Otomatis):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppThemeConstants.bgLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppThemeConstants.borderGrey),
                              ),
                              child: Text(
                                '$durationHours Jam ($startTime - $endTime)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppThemeConstants.accentBlue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppThemeConstants.bgLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppThemeConstants.borderGrey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Biaya Sewa:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          formatRpModal.format(totalCost),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.successGreen, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: 'Konfirmasi Sewa Atribut',
                      backgroundColor: AppThemeConstants.accentBlue,
                      onPressed: () async {
                        Navigator.pop(modalCtx);
                        if (!mounted) return;
                        setState(() => _isAttributeProcessing = true);
                        try {
                          final String customerName = userInfo['team_name']?.toString() ?? userInfo['name']?.toString() ?? 'Guest';
                          final String customerPhone = userInfo['phone']?.toString() ?? '';
                          final String rawPlayDate = selectedSession['play_date']!.toString();
                          final String formattedTransactionDate = _parseToYmd(rawPlayDate);

                          await AttributeBookingService.rentAttribute(
                            fkBookingDetailId: selectedSessionId!,
                            items: [
                              {
                                'fk_attribute_id': selectedAttributeId,
                                'quantity': quantity,
                              }
                            ],
                            customerName: customerName,
                            customerPhone: customerPhone,
                            durationHours: durationHours,
                            transactionDate: formattedTransactionDate,
                          );

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sewa atribut untuk sesi berhasil ditambahkan.'),
                              backgroundColor: AppThemeConstants.successGreen,
                            ),
                          );
                          _loadData();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_cleanError(e)),
                              backgroundColor: AppThemeConstants.errorRed,
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _isAttributeProcessing = false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppThemeConstants.textPrimary,
          ),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin/dashboard'),
        ),
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            color: AppThemeConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading || _isAttributeProcessing
          ? const Center(
              child: CircularProgressIndicator(
                color: AppThemeConstants.primaryBlue,
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: AppThemeConstants.errorRed),
                  ),
                )
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final formatRp = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final sessions = (_bookingData!['sessions'] as List?) ?? [];
    final userInfo = _bookingData!['user_info'] as Map<String, dynamic>? ?? {};
    final fieldInfo =
        _bookingData!['field_info'] as Map<String, dynamic>? ?? {};
    final paymentInfo =
        _bookingData!['payment_details'] as Map<String, dynamic>? ?? {};

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppThemeConstants.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(userInfo, fieldInfo, paymentInfo, formatRp),
            const SizedBox(height: 24),
            const Text(
              'Daftar Sesi Jadwal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppThemeConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '*Klik pada kartu sesi untuk memproses modifikasi atau pelunasan kasir.',
              style: TextStyle(
                fontSize: 11,
                color: AppThemeConstants.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            ...sessions.map((sessionItem) {
              final session = sessionItem as Map<String, dynamic>;
              return _buildSessionCard(session, formatRp);
            }),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    Map<String, dynamic> session,
    NumberFormat formatRp,
  ) {
    final int remainingPayment =
        int.tryParse(session['remaining_payment']?.toString() ?? '0') ?? 0;
    final bool isLunas = remainingPayment <= 0;
    final String opStatus = (session['status'] ?? 'WAITING')
        .toString()
        .toUpperCase();

    Color opBadgeColor = AppThemeConstants.warningAmber;
    Color opBgColor = AppThemeConstants.lightAmber;
    if (opStatus == 'ACTIVE') {
      opBadgeColor = AppThemeConstants.successGreen;
      opBgColor = AppThemeConstants.lightGreen;
    } else if (opStatus.contains('CANCEL')) {
      opBadgeColor = AppThemeConstants.errorRed;
      opBgColor = AppThemeConstants.lightRed;
    }

    final int currentSessionDetailId = int.tryParse(session['id']?.toString() ?? '0') ?? 0;
    final sessionAttributes = _rentedAttributes.where((item) {
      final int fkDetailId = int.tryParse(item['fk_booking_detail_id']?.toString() ?? '0') ?? 0;
      return fkDetailId == currentSessionDetailId && currentSessionDetailId != 0;
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLunas
              ? AppThemeConstants.borderGrey.withOpacity(0.6)
              : AppThemeConstants.warningAmber.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              context
                  .push('/admin/change-booking/${session['id']}')
                  .then((_) => _loadData());
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 15,
                                  color: AppThemeConstants.primaryBlue,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    session['play_date'] ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppThemeConstants.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 15,
                                  color: AppThemeConstants.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${session['start_time']} - ${session['end_time']}',
                                    style: const TextStyle(
                                      color: AppThemeConstants.textSecondary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatRp.format(
                              int.tryParse(session['price']?.toString() ?? '0') ?? 0,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppThemeConstants.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppThemeConstants.borderGrey),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: opBgColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                opStatus,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: opBadgeColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isLunas
                                    ? AppThemeConstants.lightGreen
                                    : AppThemeConstants.lightRed,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isLunas
                                      ? AppThemeConstants.successGreen
                                      : AppThemeConstants.errorRed,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isLunas
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.info_outline_rounded,
                                    size: 13,
                                    color: isLunas
                                        ? AppThemeConstants.successGreen
                                        : AppThemeConstants.errorRed,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      isLunas
                                          ? 'LUNAS'
                                          : 'BELUM LUNAS (-${formatRp.format(remainingPayment)})',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isLunas
                                            ? AppThemeConstants.successGreen
                                            : AppThemeConstants.errorRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppThemeConstants.borderGrey),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atribut Disewa Sesi Ini:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppThemeConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                if (sessionAttributes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Belum ada atribut disewa untuk sesi ini.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppThemeConstants.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  Column(
                    children: sessionAttributes.map((item) {
                      final String itemName = item['attribute']?['name']?.toString() ?? 'Atribut';
                      final String status = item['status']?.toString() ?? 'dipinjam';
                      final int qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
                      final int total = int.tryParse(item['total']?.toString() ?? '0') ?? 0;
                      final int rentalId = int.tryParse(item['id']?.toString() ?? '0') ?? 0;
                      final bool canReturn = ['dipinjam', 'terlambat'].contains(status.toLowerCase());

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppThemeConstants.borderGrey),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        itemName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      const SizedBox(width: 6),
                                      StatusBadge(status: status),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$qty Pcs • Total: ${formatRp.format(total)}',
                                    style: const TextStyle(fontSize: 11, color: AppThemeConstants.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (canReturn && rentalId != 0)
                              ElevatedButton(
                                onPressed: () => _processReturnItem(rentalId, itemName),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppThemeConstants.successGreen,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Kembalikan', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showExtendConfirmationDialog(session),
                      icon: const Icon(Icons.add_alarm_rounded, size: 15),
                      label: const Text('+ Perpanjang 30 Mnt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppThemeConstants.warningAmber,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddAttributeModal(initialSession: session),
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 15),
                      label: const Text('+ Sewa Atribut Sesi Ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppThemeConstants.accentBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    Map<String, dynamic> user,
    Map<String, dynamic> field,
    Map<String, dynamic> payment,
    NumberFormat formatRp,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge),
        border: Border.all(color: AppThemeConstants.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pelanggan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppThemeConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoItem('Nama', user['name']?.toString() ?? '-'),
          _buildInfoItem('Tim', user['team_name']?.toString() ?? '-'),
          _buildInfoItem('Kontak', user['phone']?.toString() ?? '-'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppThemeConstants.borderGrey),
          ),
          const Text(
            'Informasi Lapangan & Pembayaran',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppThemeConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            'Lapangan',
            field['name']?.toString() ?? '-',
            isBoldValue: true,
          ),
          _buildInfoItem(
            'Total Tagihan',
            formatRp.format(
              int.tryParse(payment['total_price']?.toString() ?? '0') ?? 0,
            ),
          ),
          _buildInfoItem(
            'Total Dibayar',
            formatRp.format(
              int.tryParse(payment['total_paid']?.toString() ?? '0') ?? 0,
            ),
          ),
          _buildInfoItem(
            'Metode Pembayaran',
            payment['payment_method'].toString().toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value, {
    bool isBoldValue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppThemeConstants.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppThemeConstants.textPrimary,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
