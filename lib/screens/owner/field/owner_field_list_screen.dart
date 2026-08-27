import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/screens/owner/field/owner_field_form_screen.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class OwnerFieldListScreen extends StatefulWidget {
  const OwnerFieldListScreen({super.key});

  @override
  State<OwnerFieldListScreen> createState() => _OwnerFieldListScreenState();
}

class _OwnerFieldListScreenState extends State<OwnerFieldListScreen> {
  List<dynamic> _fields = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    try {
      setState(() => _isLoading = true);
      final data = await FieldService.fetchListField();
      if (mounted) {
        setState(() {
          _fields = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        title: const Text('Manajemen Lapangan', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary), onPressed: () => context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : _fields.isEmpty
              ? const Center(child: Text('Belum ada data lapangan.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _fields.length,
                  itemBuilder: (context, i) {
                    final item = _fields[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(item['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Kategori: ${item['category'] ?? '-'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                          onPressed: () => Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => OwnerFieldFormScreen(editData: item)),
                          ).then((_) => _loadFields()),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppThemeConstants.accentBlue,
        onPressed: () => Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const OwnerFieldFormScreen()),
        ).then((_) => _loadFields()),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Lapangan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
