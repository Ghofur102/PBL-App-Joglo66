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
    // Ambil base URL dari .env, fallback ke localhost jika tidak ada
    String baseUrl = dotenv.env['API_BASE_URL'] ?? "http://10.28.239.114:8000";
    final url = Uri.parse('$baseUrl/api/hello');
    print("========== API DEBUG ==========");
    print("Calling URL: $url");
    print("Base URL: $baseUrl");
    print("===============================");

    try {
      setState(() {
        _message = "Sedang memanggil API...";
      });

      final response = await http.get(url).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print("ERROR: Request timeout setelah 10 detik");
          return http.Response('Timeout', 408);
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // Parse data JSON
        final data = json.decode(response.body);
        setState(() {
          _message = data['message'];
        });
        print("SUCCESS: ${data['message']}");
      } else {
        setState(() {
          _message = "Gagal: Status ${response.statusCode} - ${response.body}";
        });
        print("ERROR: Status Code ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("EXCEPTION: $e");
      print("StackTrace: $stackTrace");
      setState(() {
        _message = "Error: $e";
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