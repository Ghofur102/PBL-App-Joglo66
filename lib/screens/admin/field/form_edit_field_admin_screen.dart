import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/core/utils/currency_util.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class FormEditFieldAdminScreen extends StatefulWidget {
  final String fieldId;

  const FormEditFieldAdminScreen({super.key, required this.fieldId});

  @override
  State<FormEditFieldAdminScreen> createState() => _FormEditFieldAdminScreenState();
}

class _FormEditFieldAdminScreenState extends State<FormEditFieldAdminScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  File? _selectedImage;
  String? _existingImageUrl;
  List<Map<String, dynamic>> _pricingRules = [];

  bool _showAddForm = false;
  final List<String> _inlineSelectedDays = ['monday'];
  final List<Map<String, TextEditingController>> _inlineSlotInputs = [];

  final List<String> _daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  final Map<String, String> _dayNamesIndo = {
    'monday': 'Senin',
    'tuesday': 'Selasa',
    'wednesday': 'Rabu',
    'thursday': 'Kamis',
    'friday': 'Jumat',
    'saturday': 'Sabtu',
    'sunday': 'Minggu',
  };

  @override
  void initState() {
    super.initState();
    _addNewSlotInput('08:00', '12:00');
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _clearInlineControllers();
    super.dispose();
  }

  void _clearInlineControllers() {
    for (var slot in _inlineSlotInputs) {
      slot['start']?.dispose();
      slot['end']?.dispose();
      slot['price']?.dispose();
    }
    _inlineSlotInputs.clear();
  }

  void _addNewSlotInput([String? start, String? end]) {
    String defaultStart = '08:00';
    String defaultEnd = '12:00';

    if (start != null && end != null) {
      defaultStart = start;
      defaultEnd = end;
    } else if (_inlineSlotInputs.isNotEmpty) {
      final String lastEnd = _inlineSlotInputs.last['end']?.text ?? '12:00';
      final int hour = int.tryParse(lastEnd.split(':')[0]) ?? 12;
      int nextHour = hour + 4;
      if (nextHour > 24) nextHour = 24;
      defaultStart = lastEnd;
      defaultEnd = "${nextHour.toString().padLeft(2, '0')}:00";
    }

    _inlineSlotInputs.add({
      'start': TextEditingController(text: defaultStart),
      'end': TextEditingController(text: defaultEnd),
      'price': TextEditingController(),
    });
  }

  bool _isTimeOverlapping(String start1, String end1, String start2, String end2) {
    return start1.compareTo(end2) < 0 && start2.compareTo(end1) < 0;
  }

  Future<void> _loadData() async {
    try {
      final data = await FieldService.fetchFieldDetail(widget.fieldId);
      if (mounted) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _descController.text = data['description'] ?? '';
          _categoryController.text = data['category'] ?? '';

          final String rawImageUrl = data['image_url'] ?? '';
          if (rawImageUrl.isNotEmpty) {
            if (rawImageUrl.startsWith('http')) {
              _existingImageUrl = rawImageUrl;
            } else {
              final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
              _existingImageUrl = baseUrl.endsWith('/')
                  ? '$baseUrl$rawImageUrl'
                  : '$baseUrl/$rawImageUrl';
            }
          }

          if (data['field_prices'] != null) {
            _pricingRules = List<Map<String, dynamic>>.from(
              data['field_prices'].map((item) {
                String st = item['start_time'] ?? '08:00';
                String et = item['end_time'] ?? '22:00';
                if (st.length > 5) st = st.substring(0, 5);
                if (et.length > 5) et = et.substring(0, 5);

                return {
                  'day_type': item['day_type'],
                  'start_time': st,
                  'end_time': et,
                  'price': item['price'],
                };
              }),
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: AppThemeConstants.errorRed,
          ),
        );
        context.pop();
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka galeri.'),
          backgroundColor: AppThemeConstants.errorRed,
        ),
      );
    }
  }

  Future<void> _saveData() async {
    if (_nameController.text.isEmpty || _pricingRules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama lapangan dan minimal 1 jadwal harga wajib diisi!'),
          backgroundColor: AppThemeConstants.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FieldService.updateField(
        id: int.parse(widget.fieldId),
        name: _nameController.text,
        description: _descController.text,
        category: _categoryController.text,
        pricingRules: _pricingRules,
        imagePath: _selectedImage?.path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data lapangan berhasil diperbarui!'),
            backgroundColor: AppThemeConstants.successGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppThemeConstants.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _removeSingleRule(Map<String, dynamic> targetRule) {
    setState(() {
      _pricingRules.removeWhere((r) =>
          r['day_type'] == targetRule['day_type'] &&
          r['start_time'] == targetRule['start_time'] &&
          r['end_time'] == targetRule['end_time'] &&
          r['price'] == targetRule['price']);
    });
  }

  void _removeAllRulesForDay(String day) {
    setState(() {
      _pricingRules.removeWhere((r) => r['day_type'] == day);
    });
  }

  void _submitInlineForm() {
    if (_inlineSelectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu hari!'),
          backgroundColor: AppThemeConstants.warningAmber,
        ),
      );
      return;
    }

    for (int i = 0; i < _inlineSlotInputs.length; i++) {
      final String startI = _inlineSlotInputs[i]['start']!.text;
      final String endI = _inlineSlotInputs[i]['end']!.text;
      final String priceText = _inlineSlotInputs[i]['price']!.text.trim();

      if (priceText.isEmpty || startI.compareTo(endI) >= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setiap slot wajib memiliki harga & rentang jam yang valid!'),
            backgroundColor: AppThemeConstants.warningAmber,
          ),
        );
        return;
      }

      for (int j = i + 1; j < _inlineSlotInputs.length; j++) {
        final String startJ = _inlineSlotInputs[j]['start']!.text;
        final String endJ = _inlineSlotInputs[j]['end']!.text;

        if (_isTimeOverlapping(startI, endI, startJ, endJ)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Slot ${i + 1} ($startI - $endI) bentrok dengan Slot ${j + 1} ($startJ - $endJ) pada form yang diisi!'),
              backgroundColor: AppThemeConstants.warningAmber,
            ),
          );
          return;
        }
      }
    }

    for (var day in _inlineSelectedDays) {
      final String dayNameIndo = _dayNamesIndo[day] ?? day;

      for (var slot in _inlineSlotInputs) {
        final String newStart = slot['start']!.text;
        final String newEnd = slot['end']!.text;

        for (var existingRule in _pricingRules) {
          if (existingRule['day_type'].toString().toLowerCase() == day) {
            final String existStart = existingRule['start_time'].toString();
            final String existEnd = existingRule['end_time'].toString();

            if (_isTimeOverlapping(newStart, newEnd, existStart, existEnd)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Jadwal $newStart - $newEnd pada hari $dayNameIndo bentrok dengan jadwal yang sudah ada ($existStart - $existEnd)!'),
                  backgroundColor: AppThemeConstants.warningAmber,
                ),
              );
              return;
            }
          }
        }
      }
    }

    setState(() {
      for (var day in _inlineSelectedDays) {
        for (var slot in _inlineSlotInputs) {
          final int price = int.tryParse(slot['price']!.text.trim()) ?? 0;
          _pricingRules.add({
            'day_type': day,
            'start_time': slot['start']!.text,
            'end_time': slot['end']!.text,
            'price': price,
          });
        }
      }
      _showAddForm = false;
      _resetInlineFormInputs();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jadwal harga berhasil ditambahkan!'),
        backgroundColor: AppThemeConstants.successGreen,
      ),
    );
  }

  void _resetInlineFormInputs() {
    _inlineSelectedDays.clear();
    _inlineSelectedDays.add('monday');
    _clearInlineControllers();
    _addNewSlotInput('08:00', '12:00');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.primaryBlue,
      appBar: AppBar(
        title: const Text("Edit Data Lapangan", style: TextStyle(color: Colors.white)),
        backgroundColor: AppThemeConstants.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppThemeConstants.bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            context.push('/admin/close-field/${widget.fieldId}'),
                        icon: const Icon(Icons.lock_clock, color: Colors.white),
                        label: const Text("Tutup Sementara Lapangan",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemeConstants.errorRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text("Foto Lapangan",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppThemeConstants.textPrimary)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppThemeConstants.borderGrey),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _selectedImage != null
                              ? Image.file(_selectedImage!, fit: BoxFit.cover)
                              : (_existingImageUrl != null &&
                                      _existingImageUrl!.isNotEmpty)
                                  ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                                  : const Center(
                                      child: Icon(Icons.add_a_photo,
                                          size: 40, color: Colors.grey),
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppInputField(label: 'Nama Lapangan', controller: _nameController),
                    const SizedBox(height: 16),
                    AppInputField(label: 'Kategori', controller: _categoryController),
                    const SizedBox(height: 16),
                    AppInputField(
                        label: 'Deskripsi', controller: _descController, maxLines: 3),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Jadwal & Pengaturan Harga",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        IconButton(
                          icon: Icon(
                            _showAddForm ? Icons.remove_circle : Icons.add_circle,
                            color: _showAddForm ? AppThemeConstants.errorRed : AppThemeConstants.successGreen,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              _showAddForm = !_showAddForm;
                              if (_showAddForm && _inlineSlotInputs.isEmpty) {
                                _addNewSlotInput('08:00', '12:00');
                              }
                            });
                          },
                        )
                      ],
                    ),
                    if (_showAddForm) ...[
                      const SizedBox(height: 8),
                      _buildInlineAddForm(),
                      const SizedBox(height: 16),
                    ],
                    _buildPricingRulesListGroupedByDay(),
                    const SizedBox(height: 16),
                    _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              label: 'Simpan Perubahan',
                              onPressed: _saveData,
                            ),
                          ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInlineAddForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeConstants.accentBlue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tambah Jadwal Baru',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppThemeConstants.accentBlue),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: AppThemeConstants.textSecondary),
                onPressed: () => setState(() => _showAddForm = false),
              )
            ],
          ),
          const Divider(height: 12),
          const Text(
            'Pilih Hari:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _inlineSelectedDays.clear();
                    _inlineSelectedDays.addAll(_daysOfWeek);
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Semua Hari', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _inlineSelectedDays.clear();
                    _inlineSelectedDays.addAll(['monday', 'tuesday', 'wednesday', 'thursday', 'friday']);
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Hari Kerja', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _inlineSelectedDays.clear();
                    _inlineSelectedDays.addAll(['saturday', 'sunday']);
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Akhir Pekan', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: _daysOfWeek.map((day) {
              final bool isSelected = _inlineSelectedDays.contains(day);
              return FilterChip(
                label: Text(_dayNamesIndo[day] ?? day),
                selected: isSelected,
                selectedColor: AppThemeConstants.primaryBlue.withOpacity(0.2),
                checkmarkColor: AppThemeConstants.primaryBlue,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _inlineSelectedDays.add(day);
                    } else {
                      _inlineSelectedDays.remove(day);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rentang Jam & Harga:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _addNewSlotInput();
                  });
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tambah Jam', style: TextStyle(fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: _inlineSlotInputs.asMap().entries.map((entry) {
              final index = entry.key;
              final slot = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppThemeConstants.borderGrey),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Slot ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppThemeConstants.accentBlue)),
                        if (_inlineSlotInputs.length > 1)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _inlineSlotInputs.removeAt(index);
                              });
                            },
                            child: const Icon(Icons.close, size: 18, color: AppThemeConstants.errorRed),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AppInputField(
                            label: 'Mulai',
                            controller: slot['start']!,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: const TimeOfDay(hour: 8, minute: 0),
                              );
                              if (picked != null) {
                                setState(() {
                                  slot['start']!.text =
                                      "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppInputField(
                            label: 'Selesai',
                            controller: slot['end']!,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: const TimeOfDay(hour: 12, minute: 0),
                              );
                              if (picked != null) {
                                setState(() {
                                  slot['end']!.text =
                                      "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppInputField(
                      label: 'Harga (Rp)',
                      controller: slot['price']!,
                      keyboardType: TextInputType.number,
                      prefixText: 'Rp ',
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Simpan Ke Jadwal',
              onPressed: _submitInlineForm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRulesListGroupedByDay() {
    if (_pricingRules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          "Belum ada aturan harga. Silakan tambahkan minimal satu.",
          style: TextStyle(color: AppThemeConstants.errorRed),
        ),
      );
    }

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var day in _daysOfWeek) {
      final dayRules = _pricingRules
          .where((r) => r['day_type'].toString().toLowerCase() == day)
          .toList();
      if (dayRules.isNotEmpty) {
        grouped[day] = dayRules;
      }
    }

    return Column(
      children: grouped.entries.map((entry) {
        final String dayEnglish = entry.key;
        final String dayIndo = _dayNamesIndo[dayEnglish] ?? dayEnglish.toUpperCase();
        final List<Map<String, dynamic>> rules = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppThemeConstants.borderGrey),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dayIndo.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppThemeConstants.accentBlue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded,
                          color: AppThemeConstants.errorRed, size: 22),
                      tooltip: 'Hapus Semua Jadwal $dayIndo',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => _removeAllRulesForDay(dayEnglish),
                    )
                  ],
                ),
                const Divider(height: 16),
                Column(
                  children: rules.map((rule) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 16, color: AppThemeConstants.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                '${rule['start_time']} - ${rule['end_time']}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppThemeConstants.textPrimary),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                CurrencyUtil.toRupiah(rule['price']),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppThemeConstants.successGreen),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _removeSingleRule(rule),
                                child: const Icon(Icons.close_rounded,
                                    size: 18, color: AppThemeConstants.errorRed),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
