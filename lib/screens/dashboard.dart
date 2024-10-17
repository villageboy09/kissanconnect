import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, this.userData});

  final Map<String, dynamic>? userData;

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const Center(
          child: Text('No user data available.'),
        ),
      );
    }

    List<String> cropsCultivated = 
      (userData!['cropsCultivated'] as List<dynamic>?)?.cast<String>() ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(userData!['profileImageUrl'] ?? ''),
                  radius: 60,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoCard(Icons.person, 'Name', userData!['name'] ?? 'N/A'),
              _buildInfoCard(Icons.landscape, 'Area Sown', userData!['areaSown']?.toString() ?? 'N/A'),
              _buildInfoCard(Icons.calendar_today, 'Date of Sowing', _formatDate(userData!['dateOfSowing'])),
              const SizedBox(height: 20),
              const Text('Crops Cultivated:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildCropsList(cropsCultivated),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Implement weather forecast or crop recommendations
                  },
                  icon: const Icon(Icons.insights),
                  label: const Text('Get Crop Recommendations'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildCropsList(List<String> crops) {
    if (crops.isEmpty) {
      return const Text('No crops cultivated.', style: TextStyle(fontSize: 16));
    }

    return Column(
      children: crops.map((crop) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Card(
          elevation: 2,
          child: ListTile(
            title: Text(crop, style: const TextStyle(fontSize: 16)),
          ),
        ),
      )).toList(),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateFormat('dd-MM-yyyy').parse(dateString);
      return DateFormat('MMMM d, y').format(date);
    } catch (e) {
      return dateString;
    }
  }
}