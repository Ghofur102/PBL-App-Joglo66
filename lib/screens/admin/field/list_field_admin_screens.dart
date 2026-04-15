import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/services/dashboard_service.dart';

class ListFieldAdminScreens extends StatefulWidget {
  const ListFieldAdminScreens({super.key});

  @override
  State<ListFieldAdminScreens> createState() => _ListFieldAdminScreensState();
}

class _ListFieldAdminScreensState extends State<ListFieldAdminScreens> {
  // State variables
  List<Map<String, dynamic>> fields = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFieldData();
  }

  /// Fetch field data dari API
  Future<void> _loadFieldData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Fetch FIELDS (lapangan), not bookings!
      final fieldList = await DashboardService.fetchFields();
      
      setState(() {
        fields = fieldList;
        isLoading = false;
      });

      print('[ListField] ${fieldList.length} fields loaded successfully');
    } catch (e) {
      print('[ListField] Error loading data: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget fieldCard(BuildContext context, Map<String, dynamic> field) {
    // Safe type casting
    final int fieldId = field['id'] is int 
        ? field['id'] as int 
        : int.tryParse(field['id'].toString()) ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          Icons.sports_soccer,
          color: const Color(0xFF406093),
          size: 32,
        ),
        title: Text(
          field['name']?.toString() ?? 'Lapangan',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Kategori: ${field['category']?.toString() ?? 'N/A'} • Harga: Rp${field['price']?.toString() ?? '0'}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // Navigate to field details with fieldId
          context.push('/admin/field-details/$fieldId');
        },
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
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data lapangan...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // Error message jika ada
                  if (errorMessage != null)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peringatan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            errorMessage ?? '',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _loadFieldData,
                            icon: Icon(Icons.refresh, size: 16),
                            label: Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Fields List Section
                  if (fields.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Lapangan (${fields.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...fields.map((field) => fieldCard(context, field)),
                      ],
                    ),

                  // Empty state
                  if (fields.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.sports_soccer,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada data lapangan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}