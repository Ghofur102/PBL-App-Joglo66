import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 

class SuccessfulPaymentAdminScreen extends StatelessWidget {
  final bool isSuccess;
  final String message;

  const SuccessfulPaymentAdminScreen({
    super.key,
    // Secara default kita anggap sukses jika tidak ada parameter yang dikirim
    this.isSuccess = true, 
    this.message = 'Pembayaran dari customer telah dikonfirmasi dengan sukses',
  });

  @override
  Widget build(BuildContext context) {
    // --- TENTUKAN WARNA & IKON SECARA DINAMIS ---
    final Color mainColor = isSuccess ? Colors.green.shade600 : Colors.red.shade600;
    final Color bgColor = isSuccess ? Colors.green.shade50 : Colors.red.shade50;
    final Color borderColor = isSuccess ? Colors.green.shade300 : Colors.red.shade300;
    final IconData icon = isSuccess ? Icons.check_circle : Icons.cancel;
    final String title = isSuccess ? 'Pembayaran Berhasil' : 'Pembayaran Gagal';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- IKON STATUS ---
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: mainColor.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 80,
                  color: mainColor,
                ),
              ),
              const SizedBox(height: 32),

              // --- JUDUL ---
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // --- PESAN DINAMIS DARI API ---
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- TOMBOL KEMBALI ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor, // Warna tombol ikut dinamis
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () async { 
                    ScaffoldMessenger.of(context).clearSnackBars();
                    
                    await Future.delayed(const Duration(milliseconds: 50));

                    if (!context.mounted) return;

                    if (isSuccess) {
                      context.go('/admin/dashboard');
                    } else {
                      context.pop();
                    }
                  },
                  child: Text(
                    isSuccess ? 'Kembali' : 'Coba Lagi',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}