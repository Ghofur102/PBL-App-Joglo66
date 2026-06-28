import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';

class MenuGrid extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;

  const MenuGrid({super.key, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    final gridView = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return MenuGridItem(
          icon: item['icon'] as IconData,
          label: item['label'] as String,
          color: item['color'] as Color,
          onTap: (item['onTap'] as VoidCallback?) ?? () {},
        );
      },
    );

    return gridView;
  }
}

class MenuGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const MenuGridItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemWidget = GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge),
          border: Border.all(color: AppThemeConstants.borderGrey),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppThemeConstants.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    return itemWidget;
  }
}
