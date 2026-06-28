import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';

class SuccessfulPaymentAdminScreen extends StatelessWidget {
  final bool isSuccess;
  final String message;

  const SuccessfulPaymentAdminScreen({
    super.key,
    this.isSuccess = true,
    this.message = 'Pembayaran dari customer telah dikonfirmasi dengan sukses',
  });

  @override
  Widget build(BuildContext context) {
    final Color stateColor = isSuccess ? AppThemeConstants.successGreen : AppThemeConstants.errorRed;
    final Color containerBg = isSuccess ? AppThemeConstants.lightGreen : AppThemeConstants.lightRed;
    final IconData statusIcon = isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isSuccess ? 'Transaksi Sukses' : 'Transaksi Gagal', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: containerBg, shape: BoxShape.circle),
              child: Icon(statusIcon, size: 64, color: stateColor),
            ),
            const SizedBox(height: 24),
            Text(
              isSuccess ? 'Pembayaran Berhasil!' : 'Pembayaran Gagal',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppThemeConstants.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: stateColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (isSuccess) {
                    context.go('/admin/dashboard');
                  } else {
                    context.pop();
                  }
                },
                child: Text(
                  isSuccess ? 'Kembali ke Beranda' : 'Coba Ulangi Kembali',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
