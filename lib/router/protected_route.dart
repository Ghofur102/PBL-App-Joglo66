import 'package:flutter/material.dart';

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
        title: const Text('Akses Ditolak'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Maaf, role "$currentRole" tidak bisa mengakses halaman ini.',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}