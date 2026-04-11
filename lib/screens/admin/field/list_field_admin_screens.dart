import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ListFieldAdminScreens extends StatelessWidget {
  const ListFieldAdminScreens({super.key});

  final List<Map<String, String>> dataLapangan = const [
    {
      'id': '1',
      'fieldName': 'Mini Soccer',
      'status': 'Buka',
      'hours': '08.00 - 23.00',
    },
    {
      'id': '2',
      'fieldName': 'Futsal',
      'status': 'Maintenance',
      'hours': '08.00 - 23.00',
    },
  ];


  Widget cardLapangan(BuildContext context, Map<String, String> data) {
    return GestureDetector(
      onTap: () {
        context.push('/admin/field-details/${data['id']}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(

        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nama Lapangan'),
          Text(data['fieldName']!, style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 6),

          Text('Status'),
          Text(data['status']!),

          const SizedBox(height: 6),

          Text('Jam ketersediaan'),
          Text(data['hours']!),

          const SizedBox(height: 12),

          // Placeholder gambar
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 40),
            ),
          )
        ],
      ),
    ),
  );

  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/'); 
            }
          },
        ),
        title: Text(
          'Daftar Lapangan', 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: dataLapangan.length,
          itemBuilder: (context, index) {
            return cardLapangan(context, dataLapangan[index]);
          },
        ),
      ),
    );
  }
}