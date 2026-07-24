import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/components/info_box.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/core/utils/currency_util.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class CheckSlotAvailabilityAdminScreen extends StatefulWidget {
  const CheckSlotAvailabilityAdminScreen({super.key});

  @override
  State<CheckSlotAvailabilityAdminScreen> createState() => _CheckSlotAvailabilityAdminScreenState();
}

class _CheckSlotAvailabilityAdminScreenState extends State<CheckSlotAvailabilityAdminScreen> {
  List<Map<String, dynamic>> _fields = [];
  String? _selectedFieldId;
  String _selectedFieldName = '';
  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedTimeSlots = {};

  bool _isLoadingFields = true;
  bool _isLoadingSlots = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    try {
      final rawData = await FieldService.fetchListField();
      final fieldList = rawData.map((item) => item as Map<String, dynamic>).toList();

      if (mounted) {
        setState(() {
          _fields = fieldList;
          _isLoadingFields = false;
          _errorMessage = null;
          if (_fields.isNotEmpty && _selectedFieldId == null) {
            _selectedFieldId = _fields[0]['id'].toString();
            _selectedFieldName = _fields[0]['name'] ?? '';
            _loadSlots();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoadingFields = false;
        });
      }
    }
  }

  Future<void> _loadSlots() async {
    if (_selectedFieldId == null) {
      return;
    }
    try {
      if (mounted) {
        setState(() {
          _isLoadingSlots = true;
          _errorMessage = null;
        });
      }
      final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final rawSlots = await FieldService.checkAvailability(
        fieldId: int.parse(_selectedFieldId!),
        date: formattedDate,
      );

      if (mounted) {
        setState(() {
          _availableSlots = rawSlots.map((slot) => slot as Map<String, dynamic>).toList();
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableSlots = [];
          _isLoadingSlots = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlots.clear();
      });
      _loadSlots();
    }
  }

  List<Map<String, dynamic>> _generate24HourSlots() {
    final List<Map<String, dynamic>> fullDaySlots = [];
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime targetDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    final bool isPastDate = targetDate.isBefore(today);
    final bool isToday = targetDate.isAtSameMomentAs(today);

    for (int i = 0; i < 24; i++) {
      final String startHour = '${i.toString().padLeft(2, '0')}:00';
      final String endHour = '${(i + 1).toString().padLeft(2, '0')}:00';

      final match = _availableSlots.firstWhere(
        (slot) => slot['start'].toString().startsWith(i.toString().padLeft(2, '0')),
        orElse: () => {},
      );

      bool isClosed = match.isNotEmpty ? (match['is_closed'] ?? false) : false;
      bool isAvailable = match.isNotEmpty ? (match['is_available'] ?? false) : false;

      if (isPastDate) {
        isAvailable = false;
      } else if (isToday && now.hour >= i) {
        isAvailable = false;
      }

      fullDaySlots.add({
        'start': match.isNotEmpty ? match['start'] : startHour,
        'end': match.isNotEmpty ? match['end'] : endHour,
        'price': match.isNotEmpty ? match['price'] : 0,
        'is_available': isAvailable,
        'is_open': match.isNotEmpty,
        'is_closed': isClosed,
      });
    }
    return fullDaySlots;
  }

  void _showScreenshotSummaryDialog() {
    final allSlots = _generate24HourSlots();
    final String formattedDateString = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedFieldName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDateString,
                  style: const TextStyle(fontSize: 12, color: AppThemeConstants.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendChip(Colors.green, 'Buka'),
                    const SizedBox(width: 12),
                    _buildLegendChip(Colors.grey.shade400, 'Dipesan / Lewat'),
                    const SizedBox(width: 12),
                    _buildLegendChip(AppThemeConstants.errorRed, 'Tutup'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSlotGrid(allSlots),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Tutup Ringkasan',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlotGrid(List<Map<String, dynamic>> allSlots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.3,
      ),
      itemCount: allSlots.length,
      itemBuilder: (context, index) {
        final slot = allSlots[index];
        final bool isOpen = slot['is_open'];
        final bool isAvailable = slot['is_available'];
        final bool isClosed = slot['is_closed'] ?? false;

        Color badgeColor = Colors.green;
        if (!isOpen || isClosed) {
          badgeColor = AppThemeConstants.errorRed;
        } else if (!isAvailable) {
          badgeColor = Colors.grey.shade400;
        }

        final String displayTimeRange =
            '${slot['start'].toString().substring(0, 5)} - ${slot['end'].toString().substring(0, 5)}';

        return Container(
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: badgeColor, width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            displayTimeRange,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: badgeColor),
          ),
        );
      },
    );
  }

  Widget _buildLegendChip(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFields) {
      return const Scaffold(
        backgroundColor: AppThemeConstants.primaryBlue,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final openSlotsOnly = _generate24HourSlots().where((slot) => slot['is_open'] == true).toList();

    return Scaffold(
      backgroundColor: AppThemeConstants.primaryBlue,
      appBar: AppBar(
        title: const Text('Cek Slot Ketersediaan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InfoBox(message: _errorMessage!, backgroundColor: AppThemeConstants.lightRed, textColor: AppThemeConstants.errorRed),
              ),
            DropdownButtonFormField<String>(
              value: _selectedFieldId,
              items: _fields.map((f) => DropdownMenuItem(value: f['id'].toString(), child: Text(f['name'] ?? 'Lapangan'))).toList(),
              onChanged: (v) {
                if (v != null) {
                  final selected = _fields.firstWhere((f) => f['id'].toString() == v);
                  setState(() {
                    _selectedFieldId = v;
                    _selectedFieldName = selected['name'] ?? '';
                    _selectedTimeSlots.clear();
                  });
                  _loadSlots();
                }
              },
            ),
            const SizedBox(height: 12),
            AppInputField(
              label: 'Tanggal Main',
              controller: TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate)),
              readOnly: true,
              icon: Icons.calendar_today,
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoadingSlots || _availableSlots.isEmpty ? null : _showScreenshotSummaryDialog,
                icon: const Icon(Icons.grid_view_rounded, size: 18),
                label: const Text(
                  'Lihat Ringkasan Jadwal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeConstants.primaryBlue,
                  side: const BorderSide(color: AppThemeConstants.primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildSlotList(openSlotsOnly),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Lanjut Isi Form',
                onPressed: _selectedTimeSlots.isEmpty
                    ? null
                    : () {
                        List<String> sortedTimes = _selectedTimeSlots.toList()..sort();
                        var chosenSlot = _availableSlots.firstWhere(
                          (s) => '${s['start']}-${s['end']}' == sortedTimes.first,
                          orElse: () => {'price': 150000},
                        );

                        context.push('/admin/form-input-booking', extra: {
                          'nameField': _selectedFieldName,
                          'fieldId': int.parse(_selectedFieldId!),
                          'selectedDate': _selectedDate,
                          'hours': sortedTimes.join(', '),
                          'duration': _selectedTimeSlots.length,
                          'fieldPrice': chosenSlot['price'] is int ? chosenSlot['price'] : int.parse(chosenSlot['price'].toString()),
                        });
                      },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSlotList(List<Map<String, dynamic>> openSlotsOnly) {
    if (_isLoadingSlots) {
      return const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue));
    }
    if (openSlotsOnly.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada jadwal operasional pada tanggal ini.',
          style: TextStyle(color: AppThemeConstants.textSecondary, fontStyle: FontStyle.italic),
        ),
      );
    }
    return ListView.builder(
      itemCount: openSlotsOnly.length,
      itemBuilder: (context, i) {
        final slot = openSlotsOnly[i];
        return _buildSlotTile(slot);
      },
    );
  }

  Widget _buildSlotTile(Map<String, dynamic> slot) {
    final String timeKey = '${slot['start']}-${slot['end']}';
    final bool isAvailable = slot['is_available'] == true;
    final bool isClosed = slot['is_closed'] == true;
    final bool isSelected = _selectedTimeSlots.contains(timeKey);

    final String startTimeStr = slot['start'].toString().substring(0, 5);
    final String endTimeStr = slot['end'].toString().substring(0, 5);
    final String subtitleText = _determineSubtitleText(slot, isAvailable, isClosed);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: !isAvailable
            ? Colors.grey.shade100
            : (isSelected ? AppThemeConstants.lightGreen : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppThemeConstants.successGreen : AppThemeConstants.borderGrey.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        enabled: isAvailable,
        title: Text(
          '$startTimeStr - $endTimeStr',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: !isAvailable ? Colors.grey : AppThemeConstants.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitleText,
          style: TextStyle(
            color: !isAvailable
                ? (isClosed ? AppThemeConstants.errorRed : Colors.grey)
                : AppThemeConstants.successGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
          color: isSelected ? AppThemeConstants.successGreen : Colors.grey,
        ),
        onTap: !isAvailable
            ? null
            : () {
                setState(() {
                  if (isSelected) {
                    _selectedTimeSlots.remove(timeKey);
                  } else {
                    _selectedTimeSlots.add(timeKey);
                  }
                });
              },
      ),
    );
  }

  String _determineSubtitleText(Map<String, dynamic> slot, bool isAvailable, bool isClosed) {
    if (isAvailable) {
      return CurrencyUtil.toRupiah(slot['price']);
    }

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime targetDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final int startHourInt = int.tryParse(slot['start'].toString().substring(0, 2)) ?? 0;

    final bool isPastDate = targetDate.isBefore(today);
    final bool isPastHour = targetDate.isAtSameMomentAs(today) && now.hour >= startHourInt;

    if (isPastDate || isPastHour) {
      return 'Waktu Sudah Terlewat';
    }

    if (isClosed) {
      return 'Lapangan Ditutup';
    }

    return 'Jadwal Sudah Dipesan';
  }
}
