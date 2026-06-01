import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/components/button.dart';
import 'package:pbl_app_joglo66/components/input_field.dart';
import 'package:pbl_app_joglo66/services/gaji_service.dart';

class FormGajiScreen extends StatefulWidget {
  const FormGajiScreen({super.key});

  @override
  State<FormGajiScreen> createState() => _FormGajiScreenState();
}

class _FormGajiScreenState extends State<FormGajiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();

  // TODO: ganti dari KaryawanService setelah Danil selesai
  final List<Map<String, dynamic>> _dummyKaryawan = [
    {'id': 1, 'name': 'Ahmad'},
    {'id': 2, 'name': 'Budi'},
    {'id': 3, 'name': 'Citra'},
    {'id': 4, 'name': 'Dewi'},
  ];

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  int? _selectedKaryawanId;
  int? _selectedMonth;
  int? _selectedYear;
  bool _isSaving = false;

  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKaryawanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih karyawan terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final payload = {
        'karyawan_id': _selectedKaryawanId,
        'bulan': _selectedMonth ?? DateTime.now().month,
        'tahun': _selectedYear ?? DateTime.now().year,
        'nominal': int.parse(_nominalController.text.trim()),
      };

      await GajiService.storeGaji(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data gaji berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    _selectedMonth ??= now.month;
    _selectedYear ??= now.year;

    return Scaffold(
      appBar: AppBar(title: const Text('Form Gaji Karyawan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Karyawan',
                  border: OutlineInputBorder(),
                ),
                value: _selectedKaryawanId,
                hint: const Text('Pilih karyawan'),
                items: _dummyKaryawan.map((e) {
                  return DropdownMenuItem(
                    value: e['id'] as int,
                    child: Text(e['name'] as String),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedKaryawanId = v),
                validator: (v) => v == null ? 'Pilih karyawan' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Bulan',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedMonth,
                      items: List.generate(12, (i) {
                        return DropdownMenuItem(
                          value: i + 1,
                          child: Text(_months[i]),
                        );
                      }),
                      onChanged: (v) => setState(() => _selectedMonth = v),
                      validator: (v) => v == null ? 'Pilih bulan' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Tahun',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedYear,
                      items: List.generate(5, (i) {
                        final year = now.year - 2 + i;
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }),
                      onChanged: (v) => setState(() => _selectedYear = v),
                      validator: (v) => v == null ? 'Pilih tahun' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InputField(
                label: 'Nominal Gaji',
                hint: 'Masukkan nominal gaji',
                controller: _nominalController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                  final number = int.tryParse(v.trim());
                  if (number == null) return 'Harus angka';
                  if (number <= 0) return 'Harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Button(
                  label: _isSaving ? 'Menyimpan...' : 'Simpan Gaji',
                  onPressed: _isSaving ? () {} : () { _submit(); },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
