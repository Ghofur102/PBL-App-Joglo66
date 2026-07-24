import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class FormCloseFieldAdminScreen extends StatefulWidget {
  final String fieldId;

  const FormCloseFieldAdminScreen({super.key, required this.fieldId});

  @override
  State<FormCloseFieldAdminScreen> createState() => _FormCloseFieldAdminScreenState();
}

class _FormCloseFieldAdminScreenState extends State<FormCloseFieldAdminScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppThemeConstants.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() {
        controller.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitForm() async {
    if (_startDateController.text.isEmpty || _startTimeController.text.isEmpty || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal Mulai, Jam Mulai, dan Alasan wajib diisi!'), backgroundColor: AppThemeConstants.errorRed),
      );
      return;
    }

    final String startDateTimeStr = "${_startDateController.text} ${_startTimeController.text}:00";
    final String endDateStr = _endDateController.text.isEmpty ? _startDateController.text : _endDateController.text;
    final String endTimeStr = _endTimeController.text.isEmpty ? "23:59:00" : "${_endTimeController.text}:00";
    final String endDateTimeStr = "$endDateStr $endTimeStr";

    setState(() {
      _isSaving = true;
    });

    try {
      await FieldService.closeField(
        fieldId: int.parse(widget.fieldId),
        startTime: startDateTimeStr,
        endTime: endDateTimeStr,
        reason: _reasonController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lapangan berhasil ditutup sementara!'), backgroundColor: AppThemeConstants.successGreen),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final String cleanError = e
            .toString()
            .replaceAll('FormatException: ', '')
            .replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cleanError), backgroundColor: AppThemeConstants.errorRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.primaryBlue,
      appBar: AppBar(
        title: const Text("Tutup Lapangan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppThemeConstants.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.lock_clock, size: 60, color: AppThemeConstants.textPrimary),
                    SizedBox(height: 12),
                    Text("Tutup Sementara Lapangan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppThemeConstants.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppInputField(label: 'Tanggal Mulai', hint: 'YYYY-MM-DD', controller: _startDateController, icon: Icons.calendar_month, readOnly: true, onTap: () => _pickDate(_startDateController)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppInputField(label: 'Jam Mulai', hint: '00:00', controller: _startTimeController, icon: Icons.access_time, readOnly: true, onTap: () => _pickTime(_startTimeController)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppInputField(label: 'Tanggal Selesai', hint: 'YYYY-MM-DD', controller: _endDateController, icon: Icons.calendar_month, readOnly: true, onTap: () => _pickDate(_endDateController)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppInputField(label: 'Jam Selesai', hint: '00:00', controller: _endTimeController, icon: Icons.access_time, readOnly: true, onTap: () => _pickTime(_endTimeController)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text("• Kosongkan Waktu Selesai jika tutup hanya seharian penuh.", style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppThemeConstants.textSecondary)),
              const SizedBox(height: 20),
              AppInputField(label: 'Alasan Penutupan', hint: 'Contoh: Perbaikan rumput, cuaca buruk...', controller: _reasonController, maxLines: 3),
              const SizedBox(height: 32),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(width: double.infinity, child: AppButton(label: 'Simpan Perubahan', onPressed: _submitForm)),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/admin/list-closed-booking'),
                  child: const Text("Lihat Riwayat Tutup", style: TextStyle(color: AppThemeConstants.errorRed, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
