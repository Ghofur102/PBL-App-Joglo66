import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pbl_app_joglo66/router/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await initializeDateFormatting('id_ID', null);
  try {
    await dotenv.load(fileName: ".env");
    print("Berhasil memuat file .env");
  } catch (e) {
    print("GAGAL MEMUAT .env: $e");
    // Walau gagal, aplikasi tidak akan macet di layar logo
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Joglo66 App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF406093)), 
      ),
      routerConfig: appRouter, 
    );
  }
}