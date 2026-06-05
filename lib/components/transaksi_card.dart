import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/models/transaksi_harian.dart';

class TransaksiCard extends StatelessWidget {
  final TransaksiHarian transaksi;
  final String Function(int) onFormatRupiah;
  final String Function(DateTime?) onFormatTime;

  const TransaksiCard({
    super.key,
    required this.transaksi,
    required this.onFormatRupiah,
    required this.onFormatTime,
  });

  // Konfigurasi visual dipetakan menggunakan Map untuk efisiensi kognitif
  static const Map<String, _TypeTheme> _themeMap = {
    'down payment': _TypeTheme(
      color: Color(0xFF1B4F8A),
      bg: Color(0xFFE6F1FB),
      icon: Icons.monetization_on_outlined,
    ),
    'final payment': _TypeTheme(
      color: Color(0xFF3B6D11),
      bg: Color(0xFFEAF3DE),
      icon: Icons.check_circle_outline,
    ),
    'dp hangus': _TypeTheme(
      color: Color(0xFFA32D2D),
      bg: Color(0xFFFCEBEB),
      icon: Icons.local_fire_department_outlined,
    ),
    'attribute': _TypeTheme(
      color: Color(0xFF854F0B),
      bg: Color(0xFFFAEEDA),
      icon: Icons.style_outlined,
    ),
  };

  _TypeTheme get _currentTheme => _themeMap[transaksi.jenisTransaksi] ?? const _TypeTheme(
    color: Color(0xFF888780),
    bg: Color(0xFFF1EFE8),
    icon: Icons.receipt_outlined,
  );

  String _avatarText(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final isHangus = transaksi.jenisTransaksi == 'dp hangus';
    final theme = _currentTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD3D1C7)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: theme.bg,
            child: isHangus
                ? Icon(theme.icon, size: 18, color: theme.color)
                : Text(
                    _avatarText(transaksi.namaCustomer),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.color),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaksi.namaCustomer,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF2C2C2A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  transaksi.fieldName ?? '-',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF888780)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isHangus ? '- ' : ''}${onFormatRupiah(transaksi.nominal)}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.color),
              ),
              const SizedBox(height: 2),
              Text(
                onFormatTime(transaksi.waktu),
                style: const TextStyle(fontSize: 10, color: Color(0xFF888780)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeTheme {
  final Color color;
  final Color bg;
  final IconData icon;
  const _TypeTheme({required this.color, required this.bg, required this.icon});
}