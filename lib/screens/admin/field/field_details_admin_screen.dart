import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/core/utils/currency_util.dart'; // Menggunakan integrasi CurrencyUtil baru

class FieldDetailsAdminScreen extends StatefulWidget {
  final String fieldId;

  const FieldDetailsAdminScreen({super.key, required this.fieldId});

  @override
  State<FieldDetailsAdminScreen> createState() => _FieldDetailsAdminScreenState();
}

class _FieldDetailsAdminScreenState extends State<FieldDetailsAdminScreen> {
  Map<String, dynamic>? _fieldData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFieldDetail();
  }

  Future<void> _fetchFieldDetail() async {
    try {
      final data = await FieldService.fetchFieldDetail(widget.fieldId);
      if (mounted) {
        setState(() {
          _fieldData = data;
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

  String _getFinalImageUrl() {
    final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final String rawImageUrl = _fieldData?['image_url'] ?? '';

    if (rawImageUrl.isEmpty) return '';
    if (rawImageUrl.startsWith('http')) return rawImageUrl;

    return baseUrl.endsWith('/') ? '$baseUrl$rawImageUrl' : '$baseUrl/$rawImageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final String finalImageUrl = _getFinalImageUrl();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin/dashboard'),
        ),
        title: const Text('Detail Lapangan', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : _errorMessage.isNotEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: AppThemeConstants.errorRed, fontSize: 16))))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 180,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: AppThemeConstants.lightBlue,
                          borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
                          child: finalImageUrl.isEmpty
                              ? const Center(child: Text('TIDAK ADA FOTO', style: TextStyle(color: AppThemeConstants.accentBlue, fontWeight: FontWeight.bold)))
                              : Image.network(
                                  finalImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                          SizedBox(height: 8),
                                          Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      _buildInformationCard(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          label: 'Edit Data Lapangan',
                          backgroundColor: AppThemeConstants.lightAmber,
                          textColor: AppThemeConstants.warningAmber,
                          onPressed: () async {
                            await context.push('/admin/edit-field-details/${widget.fieldId}');
                            _fetchFieldDetail();
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInformationCard() {
    final List<dynamic> priceList = _fieldData!['field_prices'] ?? _fieldData!['fieldPrices'] ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeConstants.bgLight,
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
        border: Border.all(color: AppThemeConstants.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Lapangan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
          const SizedBox(height: 16),
          DetailRow(label: 'Nama Lapangan', value: _fieldData!['name'] ?? '-'),
          DetailRow(label: 'Kategori Lapangan', value: _fieldData!['category'] ?? '-'),
          DetailRow(label: 'Deskripsi', value: _fieldData!['description'] ?? 'Tidak ada deskripsi'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Divider(color: AppThemeConstants.borderGrey, thickness: 1)),
          const Text('Jadwal & Ketentuan Harga:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppThemeConstants.textSecondary)),
          const SizedBox(height: 12),

          // ===================================================================
          // 🛡️ FORM CARD AMAN HIGH OVERFLOW:
          // Membatasi tinggi area list agar tidak menabrak batas layar jika database memuat puluhan jadwal harga.
          // ===================================================================
          if (priceList.isEmpty)
            const Text('Belum ada jadwal harga yang diatur.', style: TextStyle(color: AppThemeConstants.errorRed, fontStyle: FontStyle.italic))
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 200), // Batas tinggi maksimal aman dari overflow luar
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
                border: Border.all(color: AppThemeConstants.borderGrey.withOpacity(0.5)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
                child: RawScrollbar(
                  thumbColor: AppThemeConstants.accentBlue.withOpacity(0.3),
                  radius: const Radius.circular(AppThemeConstants.radiusSmall),
                  thickness: 4,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: List.generate(priceList.length, (index) {
                        final priceItem = priceList[index];
                        final String day = priceItem['day_type'].toString().toUpperCase();
                        final String startTime = priceItem['start_time'].toString().substring(0, 5);
                        final String endTime = priceItem['end_time'].toString().substring(0, 5);

                        // Konversi String/Dynamic dari DB langsung masuk ke utilitas Rupiah otomatis
                        final String formattedPrice = CurrencyUtil.toRupiah(priceItem['price']);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 14, color: AppThemeConstants.textSecondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$day ($startTime - $endTime)',
                                    style: const TextStyle(fontSize: 12, color: AppThemeConstants.textPrimary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Text(
                                '$formattedPrice / Jam',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppThemeConstants.successGreen),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
