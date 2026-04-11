import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pbl_app_joglo66/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await initializeDateFormatting('id_ID', null);
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