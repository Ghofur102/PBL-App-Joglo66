import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/dashboard_service.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final data = await DashboardService.fetchDashboardData();
      if (mounted) {
        setState(() {
          _dashboardData = data;
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

  @override
  Widget build(BuildContext context) {
    final formatRp = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final int todayIncome =
        int.tryParse(_dashboardData?['today_income']?.toString() ?? '0') ?? 0;
    final int monthlyIncome =
        int.tryParse(_dashboardData?['monthly_income']?.toString() ?? '0') ?? 0;
    final int todaySchedulesCount =
        int.tryParse(_dashboardData?['today_schedules']?.toString() ?? '0') ?? 0;

    final List<dynamic> schedulesList = (_dashboardData?['schedules'] is List)
        ? (_dashboardData!['schedules'] as List)
        : [];

    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        title: Text(
          'Dashboard Admin',
          style: GoogleFonts.poppins(
            color: AppThemeConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppThemeConstants.primaryBlue,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: AppThemeConstants.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppThemeConstants.lightRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppThemeConstants.errorRed),
                        ),
                      ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Pemasukan Hari Ini',
                            value: formatRp.format(todayIncome),
                            icon: Icons.payments_rounded,
                            color: AppThemeConstants.successGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Pemasukan Bulan Ini',
                            value: formatRp.format(monthlyIncome),
                            icon: Icons.account_balance_wallet_rounded,
                            color: AppThemeConstants.accentBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      title: 'Total Jadwal Main Hari Ini',
                      value: '$todaySchedulesCount Sesi',
                      icon: Icons.calendar_today_rounded,
                      color: AppThemeConstants.primaryBlue,
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Navigasi Cepat',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppThemeConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuGrid(context),

                    if (schedulesList.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Jadwal Main Hari Ini',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppThemeConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: schedulesList.map((item) {
                          final schedule = Map<String, dynamic>.from(item as Map);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AppThemeConstants.borderGrey),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.sports_soccer_rounded,
                                  color: AppThemeConstants.accentBlue),
                              title: Text(
                                schedule['team_name']?.toString() ?? 'Tim',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${schedule['field_name'] ?? 'Lapangan'} • ${schedule['start_time']} - ${schedule['end_time']}',
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeConstants.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppThemeConstants.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppThemeConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final List<Map<String, dynamic>> menus = [
      {
        'title': 'Cek Slot',
        'icon': Icons.edit_calendar_rounded,
        'path': '/admin/check-availability',
      },
      {
        'title': 'Data Booking',
        'icon': Icons.list_alt_rounded,
        'path': '/admin/list-booking',
      },
      {
        'title': 'Kelola Lapangan',
        'icon': Icons.sports_tennis_rounded,
        'path': '/admin/list-field',
      },
      {
        'title': 'Master Atribut',
        'icon': Icons.inventory_2_rounded,
        'path': '/admin/list-attribute',
      },
      {
        'title': 'Pengeluaran',
        'icon': Icons.receipt_long_rounded,
        'path': '/admin/list-expense-field',
      },
      {
        'title': 'Laporan Kas',
        'icon': Icons.analytics_rounded,
        'path': '/laporan-bulanan',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        return InkWell(
          onTap: () => context.push(menu['path'] as String),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppThemeConstants.borderGrey),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppThemeConstants.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    menu['icon'] as IconData,
                    color: AppThemeConstants.accentBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    menu['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppThemeConstants.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
