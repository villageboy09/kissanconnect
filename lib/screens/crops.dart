import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CropDetailsPage extends StatelessWidget {
  final String cropName;
  final String userId;

  const CropDetailsPage({super.key, required this.cropName, required this.userId, required Map userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$cropName Details')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('crops').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data available'));
          }

          final cropsData = snapshot.data!.data() as Map<String, dynamic>;
          final specificCropData = cropsData[cropName] as Map<String, dynamic>;

          return ListView(
            children: [
              _buildSection('Diseases', specificCropData['diseases']),
              _buildSection('Pests', specificCropData['pests']),
              _buildSection('Weeds', specificCropData['weeds']),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String sectionName, List<dynamic> images) {
    return ExpansionTile(
      title: Text(sectionName),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Card(
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Image not available'));
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
