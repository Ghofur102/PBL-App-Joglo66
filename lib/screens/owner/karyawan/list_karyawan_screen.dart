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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Karyawan berhasil dihapus.'), backgroundColor: Colors.green));
          _loadKaryawan();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = e is Exception ? e.toString() : 'Terjadi kesalahan sistem';
            _isLoading = false;
          });
        }
      }
    }
  }

  String _formatRupiah(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final int val = (amount is num) ? amount.toInt() : int.tryParse(amount.toString()) ?? 0;
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp ${val.toString().replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  Color _roleColor(String? role) {
    if (role == null || role.isEmpty) return Colors.grey.shade600; // Warna untuk Karyawan Non-Sistem
    switch (role) {
      case 'owner': return Colors.red;
      case 'treasurer': return Colors.purple;
      case 'worker': return Colors.teal;
      default: return Colors.grey;
    }
  }

  Widget _buildRoleBadge(String? role) {
    final String displayText = (role == null || role.isEmpty)
        ? 'Non-Sistem'
        : role[0].toUpperCase() + role.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _roleColor(role).withAlpha(30),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _roleColor(role)
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
        title: const Text('Data Karyawan', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: const Color(0xFFE2E8F0), height: 1)),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF406093),
        onPressed: () async {
          final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const FormKaryawanScreen()));
          if (result == true) _loadKaryawan();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Karyawan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadKaryawan,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF406093), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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
            Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle), child: const Icon(Icons.people_outline, size: 48, color: Color(0xFF94A3B8))),
            const SizedBox(height: 16),
            const Text('Belum ada data karyawan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
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
          final position = item['position']?.toString() ?? '-';
          final baseSalary = item['base_salary'] ?? 0;
          final role = item['role']?.toString() ?? '';
          final status = item['status']?.toString() ?? 'active';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => FormKaryawanScreen(editData: item)));
                if (result == true) _loadKaryawan();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                        _buildRoleBadge(role),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(position, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gaji Pokok', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                            const SizedBox(height: 2),
                            Text(_formatRupiah(baseSalary), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF406093))),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: status == 'active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(status == 'active' ? 'Aktif' : 'Nonaktif', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: status == 'active' ? Colors.green : Colors.red)),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
                          padding: EdgeInsets.zero,
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => FormKaryawanScreen(editData: item)));
                              if (result == true) _loadKaryawan();
                            } else if (value == 'delete') {
                              _deleteKaryawan(id, name);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
