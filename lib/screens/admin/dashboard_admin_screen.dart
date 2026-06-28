import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbl_app_joglo66/components/info_card_circle.dart';
import 'package:pbl_app_joglo66/components/menu_grid.dart';
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
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await DashboardService.fetchDashboardData();

      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _dashboardData = {
          'name': 'Joglo66',
          'slotTerisi': 0,
          'totalSlot': 0,
          'slotKosong': 0,
          'totalBooking': 0,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fieldMenu = [
      {'icon': Icons.list_alt, 'label': 'Daftar Booking', 'color': Colors.blue, 'onTap': () => context.push('/admin/list-booking')},
      {'icon': Icons.info_outline, 'label': 'Daftar Lapangan', 'color': Colors.green, 'onTap': () => context.push('/admin/list-field')},
      {'icon': Icons.money, 'label': 'Pengeluaran', 'color': Colors.orange, 'onTap': () => context.push('/admin/list-expense-field')},
      {'icon': Icons.inventory_2, 'label': 'Master Atribut', 'color': Colors.purple, 'onTap': () => context.push('/admin/list-attribute')},
      {'icon': Icons.shopping_cart, 'label': 'Sewa Atribut', 'color': Colors.teal, 'onTap': () => context.push('/admin/rent-attribute')},
      {'icon': Icons.receipt_long, 'label': 'Riwayat Atribut', 'color': Colors.indigo, 'onTap': () => context.push('/admin/history-rent-attribute')},
      {'icon': Icons.book, 'label': 'Rekap Harian', 'color': Colors.indigo, 'onTap': () => context.push('/laporan-bulanan')},
    ];

    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 380,
                  automaticallyImplyLeading: false,
                  backgroundColor: AppThemeConstants.primaryBlue,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: HeaderSection(dashboardData: _dashboardData ?? {}),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage != null) _buildWarningBox(),
                        Text(
                          _dashboardData?['name'] ?? 'Joglo66',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
                        ),
                        const SizedBox(height: 20),
                        MenuGrid(menuItems: fieldMenu),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeConstants.lightAmber,
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
        border: Border.all(color: AppThemeConstants.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Peringatan', style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.warningAmber)),
          Text(_errorMessage ?? '', style: const TextStyle(fontSize: 12, color: AppThemeConstants.warningAmber)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final Map<String, dynamic> dashboardData;

  const HeaderSection({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            dashboardData['name'] ?? 'Joglo66',
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ringkasan Hari Ini',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoCardCircle(
                    title: 'Slot Terisi',
                    value: '${dashboardData['slotTerisi']}/${dashboardData['totalSlot']}',
                    icon: Icons.check_circle,
                  ),
                  InfoCardCircle(
                    title: 'Slot Kosong',
                    value: '${dashboardData['slotKosong']}/${dashboardData['totalSlot']}',
                    icon: Icons.open_in_full,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: InfoCardCircle(
                  title: 'Total Booking',
                  value: '${dashboardData['totalBooking']}',
                  icon: Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
