import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/components/attribute_card.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/attribute_service.dart';

class ListAttributeAdminScreen extends StatefulWidget {
  const ListAttributeAdminScreen({super.key});

  @override
  State<ListAttributeAdminScreen> createState() => _ListAttributeAdminScreenState();
}

class _ListAttributeAdminScreenState extends State<ListAttributeAdminScreen> {
  List<Map<String, dynamic>> _attributes = [];
  bool _isLoading = true;
  String? _errorMessage;
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
        _isLoading = true;
        _errorMessage = null;
      });

      final rawData = await AttributeService.fetchListAttribute(search: search);
      final list = rawData.map((item) => item as Map<String, dynamic>).toList();

      setState(() {
        _attributes = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAttribute(int id, String name) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Atribut', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppThemeConstants.errorRed),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AttributeService.deleteAttribute(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data atribut berhasil dihapus.'), backgroundColor: AppThemeConstants.successGreen),
          );
          _loadData(search: _searchController.text);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Master Data Atribut', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Cari nama atau tipe atribut...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => _loadData(search: val.isEmpty ? null : val),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/admin/add-attribute').then((_) => _loadData()),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Tambah Atribut Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeConstants.accentBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
                : RefreshIndicator(
                    onRefresh: () => _loadData(search: _searchController.text),
                    child: _buildContentView(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: AppThemeConstants.errorRed)));
    }
    if (_attributes.isEmpty) {
      return const Center(child: Text('Tidak ada data atribut.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attributes.length,
      itemBuilder: (context, i) {
        final item = _attributes[i];
        final id = int.tryParse(item['id']?.toString() ?? '0') ?? 0;
        return AttributeCard(
          item: item,
          onEdit: () => context.push('/admin/add-attribute', extra: item).then((_) => _loadData()),
          onDelete: () => _deleteAttribute(id, item['name'] ?? '-'),
          onTap: () => context.push('/admin/add-attribute', extra: item).then((_) => _loadData()),
        );
      },
    );
  }
}
