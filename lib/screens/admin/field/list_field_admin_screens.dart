import 'package:flutter/material.dart';

class DaftarLapanganPage extends StatelessWidget {
  const DaftarLapanganPage({super.key});

  final List<Map<String, String>> dataLapangan = const [
    {
      'nama': 'Mini Soccer',
      'status': 'Buka',
      'jam': '08.00 - 23.00',
    },
    {
      'nama': 'Futsal',
      'status': 'Maintenance',
      'jam': '08.00 - 23.00',
    },
    {
      'nama': 'Mini Soccer',
      'status': 'Tutup',
      'jam': '08.00 - 23.00',
    },
  ];


  Widget cardLapangan(BuildContext context, Map<String, String> data) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/field_details');
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
          Text(data['nama']!, style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 6),

          Text('Status'),
          Text(data['status']!),

          const SizedBox(height: 6),

          Text('Jam ketersediaan'),
          Text(data['jam']!),

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
        title: const Text('Daftar Lapangan'),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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