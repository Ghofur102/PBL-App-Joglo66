import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _message = "Belum ada data";

  // Fungsi untuk memanggil API Laravel
  Future<void> fetchData() async {
    // UBAH IP INI SESUAIAIKAN DENGAN LANGKAH 2 DI ATAS!
    // Contoh ini menggunakan Android Emulator
    String baseUrl = dotenv.env['API_BASE_URL'] ?? "http://10.252.57.16";
    final url = Uri.parse('$baseUrl/api/hello');
    print("URL=$url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse data JSON
        final data = json.decode(response.body);
        setState(() {
          _message = data['message'];
        });
      } else {
        setState(() {
          _message = "Gagal mengambil data: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error jaringan: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Laravel x Flutter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchData,
              child: Text('Panggil API'),
            ),
          ],
        ),
      ),
    );
  }
}