import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/screens/admin/successful_payment_admin_screens.dart';
class WaitingPaymentAdminsScreen extends StatefulWidget {
  const WaitingPaymentAdminsScreen({super.key});

  @override
  State<WaitingPaymentAdminsScreen> createState() => _WaitingPaymentAdminsScreenState();
}

class _WaitingPaymentAdminsScreenState extends State<WaitingPaymentAdminsScreen> {
  
  @override
  void initState() {
    super.initState();
    
    // Memulai hitung mundur 5 detik saat layar pertama kali dirender
    Future.delayed(const Duration(seconds: 5), () {
      // Pindah ke halaman selanjutnya
      // Gunakan pushReplacement agar halaman loading ini dihapus dari tumpukan memori
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Ganti 'HalamanTujuanScreen()' dengan nama class screen tujuan Anda
          builder: (context) => const SuccessfulPaymentAdminScreen(), 
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Sedang Memproses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),

              // LOADING
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// SCREEN DUMMY (Sebagai contoh halaman tujuan)
// Hapus kode di bawah ini jika Anda sudah memiliki halaman tujuannya sendiri
// =========================================================================
class HalamanTujuanScreen extends StatelessWidget {
  const HalamanTujuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran Sukses')),
      body: const Center(
        child: Text(
          'Halaman Selanjutnya!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}