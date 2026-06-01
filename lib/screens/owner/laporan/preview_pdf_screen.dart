import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pbl_app_joglo66/services/pdf_service.dart';
import 'package:intl/intl.dart';

class PreviewPdfScreen extends StatefulWidget {
  const PreviewPdfScreen({super.key});

  @override
  State<PreviewPdfScreen> createState() => _PreviewPdfScreenState();
}

class _PreviewPdfScreenState extends State<PreviewPdfScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;
  final _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await PdfService.fetchPdfPreview(_now.month, _now.year);
      if (mounted) setState(() => _data = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadPdf() async {
    final url = PdfService.getDownloadPdfUrl(_now.month, _now.year);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka URL: $url')),
        );
      }
    }
  }

  String _formatRupiah(dynamic value) {
    final number = int.tryParse(value?.toString() ?? '0') ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, Color headerColor, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: headerColor)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Laporan Bulanan')),
      floatingActionButton: _data != null
          ? FloatingActionButton.extended(
              onPressed: _downloadPdf,
              backgroundColor: const Color(0xFF406093),
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text('Download PDF', style: TextStyle(color: Colors.white)),
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadPreview, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    if (_data == null) {
      return const Center(child: Text('Tidak ada data'));
    }

    final details = _data!['details'] as Map<String, dynamic>? ?? {};
    final income = details['income'] as Map<String, dynamic>? ?? {};
    final expense = details['expense'] as Map<String, dynamic>? ?? {};

    return RefreshIndicator(
      onRefresh: _loadPreview,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              '${_data!['month']} ${_data!['year']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (_data!['field'] != null)
            Center(
              child: Text(
                (_data!['field'] as Map<String, dynamic>)['name']?.toString() ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          const SizedBox(height: 16),

          _sectionCard(
            'Ringkasan',
            const Color(0xFF406093),
            Column(
              children: [
                _infoRow('Total Pendapatan', _formatRupiah(_data!['total_income']), color: Colors.green),
                _infoRow('Total Pengeluaran', _formatRupiah(_data!['total_expense']), color: Colors.red),
                const Divider(),
                _infoRow('Laba Bersih', _formatRupiah(_data!['net_profit']),
                    color: (int.tryParse(_data!['net_profit']?.toString() ?? '0') ?? 0) >= 0
                        ? Colors.green
                        : Colors.red),
              ],
            ),
          ),

          _sectionCard(
            'Detail Pendapatan',
            Colors.green,
            Column(
              children: [
                _infoRow('Booking', _formatRupiah(income['booking'])),
                _infoRow('DP', _formatRupiah(income['down_payment'])),
                _infoRow('Pelunasan', _formatRupiah(income['final_payment'])),
                _infoRow('DP Hangus', _formatRupiah(income['forsaken_downpayment'])),
              ],
            ),
          ),

          _sectionCard(
            'Detail Pengeluaran',
            Colors.red,
            Column(
              children: [
                _infoRow('Operasional', _formatRupiah(expense['operational'])),
                _infoRow('Gaji', _formatRupiah(expense['salary'])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
