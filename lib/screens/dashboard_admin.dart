import 'package:flutter/material.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Stack(
          children: [
            // CONTENT
            Column(
              children: [
                _header(),
                const SizedBox(height: 16),
                _menuSection(),
                const SizedBox(height: 16),
                _bookingSection(),
              ],
            ),

            // FLOAT BUTTON
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6FA5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),

            // BOTTOM NAV
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _bottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF4A6FA5),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Dashboard Mini Soccer",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Ringkasan Hari Ini",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem("4", "Total Booking"),
              _StatItem("7/17", "Slot Terisi"),
              _StatItem("10/17", "Slot Kosong"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MenuItem(Icons.settings, "Kelola\nLapangan"),
            _MenuItem(Icons.sports_soccer, "Lihat\nLapangan"),
            _MenuItem(Icons.calendar_today, "Kalender"),
          ],
        ),
      ),
    );
  }

  Widget _bookingSection() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: const [
            Text(
              "Booking Terdekat",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            Text("Hari ini"),
            SizedBox(height: 8),

            _BookingCard(),
            SizedBox(height: 10),
            _BookingCard(),

            SizedBox(height: 12),
            Text("Besok"),
            SizedBox(height: 8),

            _BookingCard(),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF4A6FA5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.dashboard, color: Colors.white),
          SizedBox(width: 40),
          Icon(Icons.history, color: Colors.white),
        ],
      ),
    );
  }
}

//COMPONENT 

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // DATE
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "06 Mar\n2026",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),

          const SizedBox(width: 12),

          // INFO
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Putra Zeus", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  "13.00 - 15.00",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}