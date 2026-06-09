import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/services/gaji_service.dart';

class FormGajiScreen extends StatefulWidget {
  const FormGajiScreen({super.key});

  @override
  State<FormGajiScreen> createState() => _FormGajiScreenState();
}

class _FormGajiScreenState extends State<FormGajiScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _errorMessage;
  List<dynamic> _employees = [];

  static const _primaryBlue = Color(0xFF1B4F8A);
  static const _lightBlue = Color(0xFFE3F2FD);
  static const _borderColor = Color(0xFFD3D1C7);

  final List<String> _months = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  bool get _isFutureDate {
    final now = DateTime.now();
    if (_selectedYear > now.year) return true;
    if (_selectedYear == now.year && _selectedMonth > now.month) return true;
    return false;
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await GajiService.fetchGaji(_selectedMonth, _selectedYear);
      setState(() => _employees = data);
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);
    try {
      final message = await GajiService.syncGaji(_selectedMonth, _selectedYear);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      }
      await _fetchData();
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
      setState(() => _isSyncing = false);
    }
  }

  int _safeParseInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  String _formatRupiah(dynamic amount) {
    final int val = _safeParseInt(amount);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp ${val.toString().replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  void _showEditDialog(Map<String, dynamic> emp) {
    final amountCtrl = TextEditingController(
      text: emp['amount_paid'].toString(),
    );
    final bonusCtrl = TextEditingController(text: emp['bonus'].toString());
    final deductionCtrl = TextEditingController(
      text: emp['deduction'].toString(),
    );
    final notesCtrl = TextEditingController(
      text: emp['notes'].toString() == '-' ? '' : emp['notes'].toString(),
    );
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Edit Gaji: ${emp['name']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInputRow('Gaji Pokok', amountCtrl),
                    const SizedBox(height: 12),
                    _buildInputRow('Bonus', bonusCtrl),
                    const SizedBox(height: 12),
                    _buildInputRow('Potongan', deductionCtrl),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setModalState(() => isSaving = true);
                          try {
                            final payload = {
                              'employee_id': emp['employee_id'],
                              'bulan': _selectedMonth,
                              'tahun': _selectedYear,
                              'amount_paid': int.tryParse(amountCtrl.text) ?? 0,
                              'bonus': int.tryParse(bonusCtrl.text) ?? 0,
                              'deduction':
                                  int.tryParse(deductionCtrl.text) ?? 0,
                              'notes': notesCtrl.text,
                            };
                            await GajiService.updateGaji(payload);
                            if (ctx.mounted) Navigator.pop(ctx);
                            _fetchData();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gaji disimpan'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            setModalState(() => isSaving = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixText: 'Rp ',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Penggajian Karyawan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: _primaryBlue,
        iconTheme: const IconThemeData(color: Color(0xFFB5D4F4)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: _borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedMonth,
                        isExpanded: true,
                        items: List.generate(
                          12,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(_months[i + 1]),
                          ),
                        ),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedMonth = v);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: _borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedYear,
                        isExpanded: true,
                        items: List.generate(5, (i) {
                          final y = DateTime.now().year - i;
                          return DropdownMenuItem(value: y, child: Text('$y'));
                        }),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedYear = v);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _fetchData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Filter',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isFutureDate)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Colors.orange.shade800,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Edit dan sinkronisasi gaji dikunci untuk bulan masa depan.',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSyncing || _isLoading || _isFutureDate
                    ? null
                    : _syncData,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _primaryBlue,
                        ),
                      )
                    : const Icon(Icons.sync),
                label: const Text(
                  'Sinkronisasi Data Bulan Ini',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lightBlue,
                  foregroundColor: _primaryBlue,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: _primaryBlue),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _primaryBlue),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : _employees.isEmpty
                        ? const Center(child: Text('Tidak ada data karyawan aktif.'))
                        : RefreshIndicator(
                            onRefresh: _fetchData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(14),
                              itemCount: _employees.length,
                              itemBuilder: (ctx, i) {
                                final emp = _employees[i] as Map<String, dynamic>;
                                final isEdited = emp['is_edited'] == true;

                                final amountPaid = _safeParseInt(emp['amount_paid']);
                                final bonus = _safeParseInt(emp['bonus']);
                                final deduction = _safeParseInt(emp['deduction']);
                                final total = amountPaid + bonus - deduction;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: _borderColor),
                                  ),
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              emp['name'],
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2C2C2A),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isEdited
                                                    ? Colors.green.withOpacity(0.1)
                                                    : Colors.orange.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isEdited
                                                    ? 'Tersimpan'
                                                    : 'Belum Disinkronisasi',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: isEdited
                                                      ? Colors.green
                                                      : Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          emp['position'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const Divider(height: 24),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Total Diterima',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              _formatRupiah(total),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: _primaryBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: _isFutureDate
                                                ? null
                                                : () => _showEditDialog(emp),
                                            icon: const Icon(Icons.edit, size: 16),
                                            label: const Text('Edit Gaji Bulan Ini'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: _primaryBlue,
                                              side: const BorderSide(
                                                color: _primaryBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
