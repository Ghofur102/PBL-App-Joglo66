import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/components/info_box.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class CheckSlotAvailabilityAdminScreen extends StatefulWidget {
  const CheckSlotAvailabilityAdminScreen({super.key});

  @override
  State<CheckSlotAvailabilityAdminScreen> createState() => _CheckSlotAvailabilityPageState();
}

class _CheckSlotAvailabilityPageState extends State<CheckSlotAvailabilityAdminScreen> {
  List<Map<String, dynamic>> _fields = [];
  String? _selectedFieldId;
  String _selectedFieldName = '';
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeFilter = 'Pagi';
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
    if (_selectedFieldId == null) return;
    try {
      if (mounted) setState(() => _isLoadingSlots = true);
      final String formattedDate = _selectedDate.toString().split(' ')[0];

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
        setState(() { _availableSlots = []; _isLoadingSlots = false; });
      }
    }
  }

  String _getSlotTimeType(String startTime) {
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

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() { _selectedDate = picked; _selectedTimeSlots.clear(); });
      _loadSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSlots = _availableSlots.where((slot) => _getSlotTimeType(slot['start']) == _selectedTimeFilter).toList();
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (_isLoadingFields) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppThemeConstants.primaryBlue,
      appBar: AppBar(title: const Text('Cek Slot Ketersediaan', style: TextStyle(fontWeight: FontWeight.bold))),
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
                setState(() { _selectedFieldId = v; _selectedTimeSlots.clear(); });
                _loadSlots();
              },
            ),
            const SizedBox(height: 12),
            AppInputField(label: 'Tanggal Main', controller: TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate)), readOnly: true, onTap: _pickDate),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTimeFilter,
              items: ['Pagi', 'Siang', 'Sore', 'Malam'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _selectedTimeFilter = v ?? 'Pagi'),
            ),
            Expanded(
              child: _isLoadingSlots
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredSlots.length,
                      itemBuilder: (context, i) {
                        final slot = filteredSlots[i];
                        final String timeKey = '${slot['start']}-${slot['end']}';
                        final bool isSelected = _selectedTimeSlots.contains(timeKey);
                        final int price = int.tryParse(slot['price']?.toString() ?? '0') ?? 0;

                        return ListTile(
                          title: Text('${slot['start']} - ${slot['end']}'),
                          subtitle: Text(formatRp.format(price)),
                          selected: isSelected,
                          onTap: () => setState(() { isSelected ? _selectedTimeSlots.remove(timeKey) : _selectedTimeSlots.add(timeKey); }),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Lanjut Isi Form',
                onPressed: _selectedTimeSlots.isEmpty ? null : () {
                  List<String> sortedTimes = _selectedTimeSlots.toList()..sort();
                  var chosenSlot = _availableSlots.firstWhere((s) => '${s['start']}-${s['end']}' == sortedTimes.first, orElse: () => {'price': 150000});

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
}
