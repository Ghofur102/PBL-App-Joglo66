import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/services/attribute_field.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/header_two.dart';
import 'package:intl/intl.dart';

class ShowAttributeScreens extends StatefulWidget {
  final String attributeId;

  const ShowAttributeScreens({super.key, required this.attributeId});

  @override
  State<ShowAttributeScreens> createState() => _ShowAttributeScreensState();
}

class _ShowAttributeScreensState extends State<ShowAttributeScreens> {
  Map<String, dynamic>? attribute;
  bool isLoading = true;
  String errorMessage = '';

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
          attribute = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString().replaceAll('Exception: ', '');
          isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleStatus() async {
    try {
      final id = int.tryParse(widget.attributeId) ?? 0;
      final updated = await AttributeService.toggleStatus(id);

      if (mounted) {
        setState(() => attribute = updated);
        final newStatus = updated['status'] == 'active' ? 'diaktifkan' : 'dinonaktifkan';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Atribut berhasil $newStatus.'),
            backgroundColor: Colors.green,
          ),
        );
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
    }
  }

  String _formatPrice(dynamic price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final int value = price is int ? price : int.tryParse(price?.toString() ?? '0') ?? 0;
    return format.format(value);
  }

  String _typeIcon(String? type) {
    switch (type) {
      case 'sepatu':
        return '👟';
      case 'rompi':
        return '🦺';
      default:
        return '⚽';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'Detail Atribut',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF406093).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _typeIcon(attribute?['type']?.toString()),
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              attribute?['name']?.toString() ?? '-',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: (attribute?['status'] == 'active'
                                        ? Colors.green
                                        : Colors.red)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                attribute?['status'] == 'active'
                                    ? 'Aktif'
                                    : 'Nonaktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: attribute?['status'] == 'active'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HeaderTwo(title: 'Informasi Atribut'),
                            const SizedBox(height: 8),
                            DetailRow(
                              label: 'Nama',
                              value: attribute?['name']?.toString() ?? '-',
                              isBoldValue: true,
                            ),
                            DetailRow(
                              label: 'Jenis',
                              value: attribute?['type']?.toString() ?? '-',
                            ),
                            DetailRow(
                              label: 'Harga Sewa',
                              value: _formatPrice(attribute?['price_hour']),
                              isBoldValue: true,
                            ),
                            DetailRow(
                              label: 'Stok Tersedia',
                              value: attribute?['stock']?.toString() ?? '0',
                              isBoldValue: true,
                            ),
                            DetailRow(
                              label: 'Lapangan',
                              value: attribute?['field']?['name']?.toString() ?? '-',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HeaderTwo(title: 'Riwayat Data'),
                            const SizedBox(height: 8),
                            DetailRow(
                              label: 'Dibuat Pada',
                              value: attribute?['created_at']?.toString() ?? '-',
                            ),
                            DetailRow(
                              label: 'Diperbarui',
                              value: attribute?['updated_at']?.toString() ?? '-',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await context.push(
                              '/admin/add-attribute',
                              extra: attribute,
                            );
                            _loadData();
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text(
                            'Edit Data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCC80),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _toggleStatus,
                          icon: Icon(
                            attribute?['status'] == 'active'
                                ? Icons.block
                                : Icons.check_circle,
                          ),
                          label: Text(
                            attribute?['status'] == 'active'
                                ? 'Nonaktifkan Atribut'
                                : 'Aktifkan Atribut',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: attribute?['status'] == 'active'
                                ? Colors.red
                                : Colors.green,
                            side: BorderSide(
                              color: attribute?['status'] == 'active'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}
