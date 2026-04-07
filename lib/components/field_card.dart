import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable FieldCard Component
/// 
/// Props:
/// - fieldName: Nama lapangan (required)
/// - status: Status ketersediaan lapangan (required)
/// - availabilityTime: Jam ketersediaan (required)
/// - image: Image path atau URL (optional)
/// - onTap: Callback ketika card ditekan (optional)

class FieldCard extends StatelessWidget {
  final String fieldName;
  final String status;
  final String availabilityTime;
  final String? image;
  final VoidCallback? onTap;

  const FieldCard({
    super.key,
    required this.fieldName,
    required this.status,
    required this.availabilityTime,
    this.image,
    this.onTap,
  });

  /// Get status color based on status value
  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return const Color(0xFF4CAF50);
      case 'ditutup':
        return const Color(0xFF9C27B0);
      case 'maintenance':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  /// Get status text color (white for dark status, dark for light status)
  Color _getStatusTextColor() {
    switch (status.toLowerCase()) {
      case 'tersedia':
      case 'ditutup':
      case 'maintenance':
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Placeholder Section
            _buildImageSection(),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field Name
                  Text(
                    fieldName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Status and Availability Time Row
                  Row(
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _getStatusTextColor(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Availability Time
                      Expanded(
                        child: Text(
                          availabilityTime,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF757575),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build image or placeholder widget
  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        height: 140,
        color: const Color(0xFFE0E0E0),
        child: image != null && image!.isNotEmpty
            ? Image.asset(
                image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  /// Build placeholder when no image
  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE0E0E0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer,
            size: 40,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
