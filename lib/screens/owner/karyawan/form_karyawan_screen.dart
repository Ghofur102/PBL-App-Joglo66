import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/components/input_field.dart';
import 'package:pbl_app_joglo66/services/karyawan_service.dart';

// DEVELOPER: DANIL

class FormKaryawanScreen extends StatelessWidget {
  final Map<String, dynamic>? editData;
  const FormKaryawanScreen({super.key, this.editData});

  @override
  Widget build(BuildContext context) {
    // Logic UI: Memakai reusable 'InputField' untuk mengisi nama, email, password, dan dropdown pilihan hak akses (role).
    // Mendeteksi apakah form berjalan dalam mode tambah baru atau edit data lama.
    return const Scaffold(body: Center(child: Text("Form Entri & Edit Akun Karyawan - Danil")));
  }
}