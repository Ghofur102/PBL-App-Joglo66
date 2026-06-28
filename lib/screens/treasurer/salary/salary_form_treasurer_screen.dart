import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/salary_service.dart';

class SalaryFormTreasurerScreen extends StatefulWidget {
  const SalaryFormTreasurerScreen({super.key});

  @override
  State<SalaryFormTreasurerScreen> createState() => _SalaryFormTreasurerScreenState();
}

class _SalaryFormTreasurerScreenState extends State<SalaryFormTreasurerScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now()
      .year;
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _errorMessage;
  List<dynamic> _employees = [];

  final List<String> _monthLabels = [
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

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await SalaryService.fetchSalary(
        _selectedMonth,
        _selectedYear,
      );
      setState(() => _employees = data);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);
    try {
      final message = await SalaryService.syncSalary(
        _selectedMonth,
        _selectedYear,
      );
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      await _fetchData();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppThemeConstants.errorRed,
          ),
        );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        title: const Text('Penggajian Karyawan'),
        backgroundColor: AppThemeConstants.primaryBlue,
      ),
      body: Column(
        children: [
          _buildFilterRow(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _isSyncing
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _isLoading ? null : _syncData,
                    icon: const Icon(Icons.sync),
                    label: const Text('Sinkronisasi Data'),
                  ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppThemeConstants.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _employees.length,
                    itemBuilder: (context, i) => ListTile(
                      title: Text(_employees[i]['name'] ?? '-'),
                      subtitle: Text(
                        'Gaji Pokok: ${_employees[i]['amount_paid']}',
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedMonth,
              items: List.generate(
                12,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(_monthLabels[i + 1]),
                ),
              ),
              onChanged: (v) => setState(() => _selectedMonth = v ?? 1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedYear,
              items: List.generate(
                5,
                (i) => DropdownMenuItem(
                  value: DateTime.now().year - i,
                  child: Text('${DateTime.now().year - i}'),
                ),
              ),
              onChanged: (v) =>
                  setState(() => _selectedYear = v ?? DateTime.now().year),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _fetchData, child: const Text('Filter')),
        ],
      ),
    );
  }
}
