import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/services/karyawan_service.dart';
import 'package:pbl_app_joglo66/screens/owner/karyawan/form_karyawan_screen.dart';

class ListKaryawanScreen extends StatefulWidget {
  const ListKaryawanScreen({super.key});

  @override
  State<ListKaryawanScreen> createState() => _ListKaryawanScreenState();
}

class _ListKaryawanScreenState extends State<ListKaryawanScreen> {
  List<dynamic> _karyawan = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadKaryawan();
  }

  Future<void> _loadKaryawan() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final data = await KaryawanService.getAllKaryawan();
      if (mounted) {
        setState(() {
          _karyawan = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteKaryawan(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Karyawan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?\nTindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await KaryawanService.deleteKaryawan(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Karyawan berhasil dihapus.'), backgroundColor: Colors.green),
          );
          _loadKaryawan();
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

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.blue;
      case 'owner':
        return Colors.purple;
      case 'treasure':
        return Colors.orange;
      case 'worker':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _roleColor(role).withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role[0].toUpperCase() + role.substring(1),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _roleColor(role),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Data Karyawan',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF406093),
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const FormKaryawanScreen()),
          );
          if (result == true) _loadKaryawan();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Karyawan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadKaryawan,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF406093),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_karyawan.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline, size: 48, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada data karyawan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadKaryawan,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _karyawan.length,
        itemBuilder: (context, index) {
          final item = _karyawan[index] as Map<String, dynamic>;
          final id = int.tryParse(item['id']?.toString() ?? '0') ?? 0;
          final name = item['name']?.toString() ?? '';
          final email = item['email']?.toString() ?? '';
          final role = item['role']?.toString() ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(email, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRoleBadge(role),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormKaryawanScreen(editData: item),
                          ),
                        );
                        if (result == true) _loadKaryawan();
                      } else if (value == 'delete') {
                        _deleteKaryawan(id, name);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormKaryawanScreen(editData: item),
                  ),
                );
                if (result == true) _loadKaryawan();
              },
            ),
          );
        },
      ),
    );
  }
}
