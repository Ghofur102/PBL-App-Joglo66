import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/screens/owner/employee/employee_form_owner_screen.dart';
import 'package:pbl_app_joglo66/services/employee_service.dart';

class EmployeeListOwnerScreen extends StatefulWidget {
  const EmployeeListOwnerScreen({super.key});

  @override
  State<EmployeeListOwnerScreen> createState() => _EmployeeListOwnerScreenState();
}

class _EmployeeListOwnerScreenState extends State<EmployeeListOwnerScreen> {
  List<dynamic> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final data = await EmployeeService.getAllEmployee();
      setState(() {
        _employees = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        title: const Text('Kelola Data Karyawan', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary), onPressed: () => context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : _employees.isEmpty
              ? const Center(child: Text('Belum ada data karyawan.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _employees.length,
                  itemBuilder: (context, i) {
                    final item = _employees[i];
                    final bool isSystem = item['is_system'] == true;
                    final String fieldNames = item['field_names'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(item['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jabatan: ${item['position'] ?? '-'}'),
                            if (isSystem) ...[
                              Text('Akses: ${item['role']?.toString().toUpperCase()}'),
                              if (fieldNames.isNotEmpty)
                                Text('Penugasan: $fieldNames', style: const TextStyle(color: AppThemeConstants.accentBlue, fontWeight: FontWeight.w500)),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                          onPressed: () => Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => EmployeeFormOwnerScreen(editData: item)),
                          ).then((_) => _loadData()),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppThemeConstants.accentBlue,
        onPressed: () => Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeFormOwnerScreen()),
        ).then((_) => _loadData()),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Karyawan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
