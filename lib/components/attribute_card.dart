import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/status_badge.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';

class AttributeCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const AttributeCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String name = item['name']?.toString() ?? '-';
    final String type = item['type']?.toString() ?? 'lainnya';
    final int stock = int.tryParse(item['stock']?.toString() ?? '0') ?? 0;
    final int price = int.tryParse(item['price_hour']?.toString() ?? '0') ?? 0;
    final String status = item['status']?.toString() ?? 'active';
    final String fieldName = item['field']?['name']?.toString() ?? 'Semua Lapangan';

    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    IconData typeIcon;
    Color typeColor;

    switch (type.toLowerCase()) {
      case 'sepatu':
        typeIcon = Icons.shopping_bag_rounded;
        typeColor = Colors.blue;
        break;
      case 'rompi':
        typeIcon = Icons.checkroom_rounded;
        typeColor = Colors.orange;
        break;
      default:
        typeIcon = Icons.sports_tennis_rounded;
        typeColor = AppThemeConstants.successGreen;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge),
        border: Border.all(color: AppThemeConstants.borderGrey),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 56,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(fieldName, style: const TextStyle(fontSize: 12, color: AppThemeConstants.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        'Stok: $stock | ${formatRp.format(price)} / jam',
                        style: const TextStyle(fontSize: 12, color: AppThemeConstants.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppThemeConstants.errorRed, size: 20),
                      onPressed: onDelete,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
