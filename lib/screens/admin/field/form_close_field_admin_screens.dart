import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import 'package:pbl_app_joglo66/components/button.dart';

class FormCloseFieldAdminScreens extends StatefulWidget {
  final String fieldId;

  const FormCloseFieldAdminScreens({
    super.key,
    required this.fieldId,
  });

  @override
  State<FormCloseFieldAdminScreens> createState() => _FormCloseFieldAdminScreensState();
}

class _FormCloseFieldAdminScreensState extends State<FormCloseFieldAdminScreens> {
  late TextEditingController _startDateController;
  late TextEditingController _startTime1Controller;
  late TextEditingController _endTime1Controller;
  late TextEditingController _endDateController;
  late TextEditingController _startTime2Controller;
  late TextEditingController _endTime2Controller;
  
  late TextEditingController _reasonController;

  String _fieldName = '';

  // 3. Simulasi ambil data dari Database/API
  Map<String, dynamic> _fetchDummyData(String id) {
    final db = {
      '1': {'fieldName': 'Joglo66 Field 1'},
      '2': {'fieldName': 'Futsal Field A'},
    };
    return db[id] ?? {'fieldName': 'Unknown Field'};
  }

  @override
  void initState() {
    super.initState();

    final data = _fetchDummyData(widget.fieldId);
    _fieldName = data['fieldName'];

    _startDateController = TextEditingController();
    _startTime1Controller = TextEditingController();
    _endTime1Controller = TextEditingController();
    _endDateController = TextEditingController();
    _startTime2Controller = TextEditingController();
    _endTime2Controller = TextEditingController();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _startTime1Controller.dispose();
    _endTime1Controller.dispose();
    _endDateController.dispose();
    _startTime2Controller.dispose();
    _endTime2Controller.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null && context.mounted) {
      setState(() {
        controller.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && context.mounted) {
      setState(() {
        controller.text = pickedTime.format(context);
      });
    }
  }

  Widget inputField(String hint, {TextEditingController? controller, bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget textArea(String hint, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget dateField(String hint, {TextEditingController? controller, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      readOnly: true, // Mencegah keyboard muncul
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF406093),
      appBar: AppBar(
        title: const Text(
          "Temporarily Close Field", // Translasi
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF406093),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.block, size: 50, color: Colors.redAccent),
                    const SizedBox(height: 8),
                    const Text(
                      "Temporarily Close Field",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Menampilkan field mana yang sedang diedit
                    Text(
                      _fieldName,
                      style: const TextStyle(
                        color: Color(0xFF406093),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- FORM TANGGAL AWAL ---
              const Text(
                "Start Date",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              dateField(
                "Select start date", 
                controller: _startDateController,
                onTap: () => _selectDate(_startDateController),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: inputField(
                      "Start Time", 
                      controller: _startTime1Controller,
                      readOnly: true,
                      onTap: () => _selectTime(_startTime1Controller),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: inputField(
                      "End Time", 
                      controller: _endTime1Controller,
                      readOnly: true,
                      onTap: () => _selectTime(_endTime1Controller),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                "End Date",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              dateField(
                "Select end date", 
                controller: _endDateController,
                onTap: () => _selectDate(_endDateController),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: inputField(
                      "Start Time", 
                      controller: _startTime2Controller,
                      readOnly: true,
                      onTap: () => _selectTime(_startTime2Controller),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: inputField(
                      "End Time", 
                      controller: _endTime2Controller,
                      readOnly: true,
                      onTap: () => _selectTime(_endTime2Controller),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "If closing for only one day, leave the End Date empty.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),

              const SizedBox(height: 24),

              const Text(
                "Reason for Closing",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              textArea(
                "Write the reason for the sudden closure...",
                controller: _reasonController,
              ),

              const SizedBox(height: 32),

              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Button(
                    label: "Save Changes",
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Field closure scheduled successfully!')),
                      );
                      context.pop();
                    },
                    backgroundColor: const Color(0xFF406093),
                    textColor: Colors.white,
                    padding: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Button(
                    label: "View Closed Bookings",
                    onPressed: () {
                      context.push('/admin/list-closed-booking');
                    },
                    backgroundColor: const Color(0xFFE57373), // Merah pastel
                    textColor: Colors.white,
                    padding: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}