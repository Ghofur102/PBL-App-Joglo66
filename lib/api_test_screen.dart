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
  String _message = "Pilih endpoint untuk di-test";
  String _endpoint = "";

  Future<void> fetchData(String endpointPath, String endpointName) async {
    String baseUrl = dotenv.env['API_BASE_URL'] ?? "http://10.28.239.114:8000";
    String token = dotenv.env['API_TOKEN'] ?? "";
    final url = Uri.parse('$baseUrl$endpointPath');
    
    print("\n========== API TEST: $endpointName ==========");
    print("URL: $url");
    print("Token: ${token.substring(0, 20)}...");

    try {
      setState(() {
        _message = "Sedang memanggil $endpointName...";
        _endpoint = endpointName;
      });

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print("ERROR: Request timeout");
          return http.Response('Timeout', 408);
        },
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _message = "✅ ${data['message'] ?? 'Success'}";
        });
        print("SUCCESS ✅");
      } else {
        setState(() {
          _message = "❌ Error ${response.statusCode}";
        });
      }
    } catch (e) {
      print("EXCEPTION: $e");
      setState(() {
        _message = "❌ Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('API Test - Zami')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Endpoint: $_endpoint', style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 10),
            Text(_message, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => fetchData('/api/admin/dashboard', 'Dashboard'),
              child: Text('Test Dashboard'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => fetchData('/api/admin/list-field', 'List Field'),
              child: Text('Test List Field'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => fetchData('/api/admin/list-booking', 'List Booking'),
              child: Text('Test List Booking'),
            ),
          ],
        ),
      ),
    );
  }
}