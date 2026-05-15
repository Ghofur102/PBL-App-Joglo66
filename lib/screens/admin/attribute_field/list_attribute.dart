import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/services/attribute_field.dart';
import 'package:intl/intl.dart';

class ListAttributeScreens extends StatefulWidget {
  const ListAttributeScreens({super.key});

  @override
  State<ListAttributeScreens> createState() => _ListAttributeScreensState();
}

class _ListAttributeScreensState extends State<ListAttributeScreens> {
  List<Map<String, dynamic>> attributes = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({String? search}) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final rawData = await AttributeService.fetchListAttribute(search: search);
      final list =
          rawData.map((item) => item as Map<String, dynamic>).toList();

      setState(() {
        attributes = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _deleteAttribute(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Atribut'),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AttributeService.deleteAttribute(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data atribut berhasil dihapus.'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData(search: _searchController.text);
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
  }

  String _formatPrice(int? price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(price ?? 0);
  }

  Color _statusColor(String? status) {
    return status == 'active' ? Colors.green : Colors.red;
  }

  String _statusLabel(String? status) {
    return status == 'active' ? 'Aktif' : 'Nonaktif';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Master Data Atribut',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari atribut...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadData();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {});
                _loadData(search: value.isEmpty ? null : value);
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _loadData(search: _searchController.text),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Peringatan',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(errorMessage ?? '',
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _loadData(search: _searchController.text),
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        if (attributes.isNotEmpty) ...[
                          Text(
                            'Daftar Atribut (${attributes.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...attributes.map((item) => _buildCard(item)),
                        ],
                        if (attributes.isEmpty && errorMessage == null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(Icons.inventory_2,
                                      size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Data atribut kosong.\nSilahkan tambahkan data di menu Master Data terlebih dahulu',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF406093),
        onPressed: () async {
          await context.push('/admin/add-attribute');
          _loadData(search: _searchController.text);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final int id = item['id'] is int ? item['id'] : int.tryParse(item['id'].toString()) ?? 0;
    final String name = item['name']?.toString() ?? '-';
    final String type = item['type']?.toString() ?? 'lainnya';
    final int stock = item['stock'] is int ? item['stock'] : int.tryParse(item['stock'].toString()) ?? 0;
    final int price = item['price_hour'] is int ? item['price_hour'] : int.tryParse(item['price_hour'].toString()) ?? 0;
    final String status = item['status']?.toString() ?? 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await context.push('/admin/show-attribute/$id');
          _loadData(search: _searchController.text);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF406093).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  type == 'sepatu'
                      ? Icons.shopping_bag
                      : type == 'rompi'
                          ? Icons.checkroom
                          : Icons.sports_tennis,
                  color: const Color(0xFF406093),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: _statusColor(status).withOpacity(0.5)),
                          ),
                          child: Text(
                            _statusLabel(status),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _statusColor(status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.category, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          type[0].toUpperCase() + type.substring(1),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.inventory, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Stok: $stock',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(price),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                    onPressed: () async {
                      await context.push('/admin/add-attribute', extra: item);
                      _loadData(search: _searchController.text);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _deleteAttribute(id, name),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
