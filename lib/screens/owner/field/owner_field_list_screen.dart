import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/screens/owner/field/owner_field_form_screen.dart';
import 'package:pbl_app_joglo66/services/field_service.dart';

class OwnerFieldListScreen extends StatefulWidget {
  const OwnerFieldListScreen({super.key});

  @override
  State<OwnerFieldListScreen> createState() => _OwnerFieldListScreenState();
}

class _OwnerFieldListScreenState extends State<OwnerFieldListScreen> {
  List<dynamic> _fields = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final data = await FieldService.fetchOwnerFields();
      if (mounted) {
        setState(() {
          _fields = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('FormatException: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToForm([Map<String, dynamic>? item]) async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerFieldFormScreen(editData: item),
      ),
    );

    if (result == true) {
      _loadFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        title: const Text(
          'Manajemen Lapangan',
          style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : RefreshIndicator(
              onRefresh: _loadFields,
              color: AppThemeConstants.primaryBlue,
              child: _errorMessage != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 60),
                        const Icon(Icons.error_outline_rounded, color: AppThemeConstants.errorRed, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppThemeConstants.textPrimary, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppThemeConstants.accentBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _loadFields,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ),
                      ],
                    )
                  : _fields.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(32),
                          children: const [
                            SizedBox(height: 100),
                            Icon(Icons.sports_soccer_rounded, color: AppThemeConstants.textSecondary, size: 64),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada data lapangan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppThemeConstants.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tekan tombol di bawah untuk menambahkan unit lapangan baru.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppThemeConstants.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _fields.length,
                          itemBuilder: (context, i) {
                            final item = _fields[i] as Map<String, dynamic>;
                            final String category = (item['category'] ?? '-').toString().toUpperCase();
                            final String? description = item['description']?.toString();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
                                border: Border.all(color: AppThemeConstants.borderGrey),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppThemeConstants.lightBlue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.sports_soccer_rounded,
                                    color: AppThemeConstants.primaryBlue,
                                    size: 26,
                                  ),
                                ),
                                title: Text(
                                  item['name'] ?? '-',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppThemeConstants.lightGreen,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        category,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppThemeConstants.successGreen,
                                        ),
                                      ),
                                    ),
                                    if (description != null && description.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppThemeConstants.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit_rounded, color: AppThemeConstants.accentBlue),
                                  tooltip: 'Edit Lapangan',
                                  onPressed: () => _navigateToForm(item),
                                ),
                              ),
                            );
                          },
                        ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppThemeConstants.accentBlue,
        onPressed: () => _navigateToForm(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Lapangan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
