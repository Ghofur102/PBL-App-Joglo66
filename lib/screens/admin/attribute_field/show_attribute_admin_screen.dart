import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/attribute_service.dart';

class ShowAttributeAdminScreen extends StatefulWidget {
  final String attributeId;

  const ShowAttributeAdminScreen({super.key, required this.attributeId});

  @override
  State<ShowAttributeAdminScreen> createState() => _ShowAttributeAdminScreenState();
}

class _ShowAttributeAdminScreenState extends State<ShowAttributeAdminScreen> {
  Map<String, dynamic>? _attribute;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final id = int.tryParse(widget.attributeId) ?? 0;
      final data = await AttributeService.fetchDetailAttribute(id);

      if (mounted) {
        setState(() {
          _attribute = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleStatus() async {
    try {
      final id = int.tryParse(widget.attributeId) ?? 0;
      final updated = await AttributeService.toggleStatus(id);

      if (mounted) {
        setState(() => _attribute = updated);
        final labelText = updated['status'] == 'active' ? 'diaktifkan' : 'dinonaktifkan';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Atribut berhasil $labelText.'), backgroundColor: AppThemeConstants.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed));
      }
    }
  }

  String _formatPrice(dynamic price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final int value = price is int ? price : int.tryParse(price?.toString() ?? '0') ?? 0;
    return format.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = _attribute?['status'] == 'active';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Detail Atribut', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary), onPressed: () => context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: AppThemeConstants.errorRed)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppThemeConstants.bgLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppThemeConstants.borderGrey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_attribute?['name']?.toString() ?? '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            DetailRow(label: 'Nama', value: _attribute?['name']?.toString() ?? '-'),
                            DetailRow(label: 'Jenis', value: _attribute?['type']?.toString().toUpperCase() ?? '-'),
                            DetailRow(label: 'Harga Sewa', value: _formatPrice(_attribute?['price_hour'])),
                            DetailRow(label: 'Stok Tersedia', value: _attribute?['stock']?.toString() ?? '0'),
                            DetailRow(label: 'Status Sistem', value: isActive ? 'Aktif' : 'Nonaktif'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          label: 'Edit Data Atribut',
                          backgroundColor: AppThemeConstants.lightAmber,
                          textColor: AppThemeConstants.warningAmber,
                          onPressed: () => context.push('/admin/add-attribute', extra: _attribute).then((_) => _loadData()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          label: isActive ? 'Nonaktifkan Atribut' : 'Aktifkan Atribut',
                          backgroundColor: isActive ? AppThemeConstants.lightRed : AppThemeConstants.lightGreen,
                          textColor: isActive ? AppThemeConstants.errorRed : AppThemeConstants.successGreen,
                          onPressed: _toggleStatus,
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
