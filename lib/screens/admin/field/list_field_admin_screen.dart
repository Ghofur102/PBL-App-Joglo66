import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class ListFieldAdminScreen extends StatefulWidget {
  const ListFieldAdminScreen({super.key});

  @override
  State<ListFieldAdminScreen> createState() => _ListFieldAdminScreenState();
}

class _ListFieldAdminScreenState extends State<ListFieldAdminScreen> {
  List<Map<String, dynamic>> _fields = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFieldData();
  }

  Future<void> _loadFieldData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final List<dynamic> rawData = await FieldService.fetchListField();
      final fieldList = rawData.map((item) => item as Map<String, dynamic>).toList();

      setState(() {
        _fields = fieldList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Widget _buildFieldCard(BuildContext context, Map<String, dynamic> field) {
    final int fieldId = field['id'] is int ? field['id'] as int : int.tryParse(field['id'].toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
        border: Border.all(color: AppThemeConstants.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.sports_soccer, color: AppThemeConstants.accentBlue, size: 32),
        title: Text(field['name']?.toString() ?? 'Lapangan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('Kategori: ${field['category']?.toString() ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => context.push('/admin/field-details/$fieldId'),
      ),
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
          icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin/dashboard'),
        ),
        title: const Text('Daftar Lapangan', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: AppThemeConstants.lightAmber, borderRadius: BorderRadius.circular(8)),
                      child: Text(_errorMessage!, style: const TextStyle(color: AppThemeConstants.warningAmber, fontSize: 13)),
                    ),
                  if (_fields.isNotEmpty) ...[
                    Text('Total Lapangan (${_fields.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._fields.map((field) => _buildFieldCard(context, field)),
                  ],
                  if (_fields.isEmpty && _errorMessage == null)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Tidak ada data lapangan.'))),
                ],
              ),
            ),
    );
  }
}
