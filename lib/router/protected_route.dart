import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;
  final String currentRole;

  const ProtectedRoute({
    super.key,
    required this.child,
    required this.allowedRoles,
    required this.currentRole,
  });

  @override
  Widget build(BuildContext context) {
    if (allowedRoles.contains(currentRole)) {
      return child;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akses Ditolak', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red.shade800,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.gpp_bad_rounded, size: 100, color: Colors.red.shade700),
            const SizedBox(height: 24),
            const Text(
              'Batasan Hak Akses',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              'Maaf, Akun Anda dengan tingkat hak akses "$currentRole" tidak memiliki otorisasi keamanan untuk membuka menu ini.',
              style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                if (currentRole == 'owner') {
                  context.go('/owner/dashboard');
                } else if (currentRole == 'treasurer') {
                  context.go('/treasurer/dashboard');
                } else {
                  context.go('/admin/dashboard');
                }
              },
              icon: const Icon(Icons.dashboard_rounded, color: Colors.white),
              label: const Text('Kembali ke Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
