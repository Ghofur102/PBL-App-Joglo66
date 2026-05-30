import 'package:pbl_app_joglo66/services/api_client.dart';

// DEVELOPER: DANIL

class KaryawanService {
  static Future<List<dynamic>> getAllKaryawan() async {
    // Logic: Request GET ke '/api/admin/karyawan' untuk list data.
    return [];
  }
  static Future<void> createKaryawan(Map<String, dynamic> data) async {
    // Logic: Request POST ke '/api/admin/karyawan' membawa payload data akun baru.
  }
  static Future<void> updateKaryawan(int id, Map<String, dynamic> data) async {
    // Logic: Request PUT ke '/api/admin/karyawan/$id' untuk update profil/role.
  }
  static Future<void> deleteKaryawan(int id) async {
    // Logic: Request DELETE ke '/api/admin/karyawan/$id' untuk hapus data.
  }
}