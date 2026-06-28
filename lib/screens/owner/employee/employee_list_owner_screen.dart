import 'package:flutter/material.dart';
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
      setState(() { _employees = data; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Karyawan'), backgroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _employees.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(_employees[i]['name'] ?? '-'),
                subtitle: Text(_employees[i]['position'] ?? '-'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: AppThemeConstants.accentBlue),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeeFormOwnerScreen(editData: _employees[i]))).then((_) => _loadData()),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeFormOwnerScreen())).then((_) => _loadData()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
