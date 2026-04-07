import 'package:flutter/material.dart';

class CustomBottomNavPage extends StatefulWidget {
  const CustomBottomNavPage({super.key});

  @override
  State<CustomBottomNavPage> createState() => _CustomBottomNavPageState();      
}

class _CustomBottomNavPageState extends State<CustomBottomNavPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text("Home")),
    Center(child: Text("Jadwal")),
    Center(child: Text("Booking")),
    Center(child: Text("Riwayat")),
    Center(child: Text("Profil")),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(Icons.home, "Home", 0),
              _item(Icons.calendar_today, "Jadwal", 1),

              const SizedBox(width: 40),

              _item(Icons.history, "Riwayat", 3),
              _item(Icons.person, "Profil", 4),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _onTap(2),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,  
    );
  }

  Widget _item(IconData icon, String label, int index) {
    final active = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.blue : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: active ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
