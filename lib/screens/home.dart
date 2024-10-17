import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kissanconnect/screens/crops.dart';
import 'package:kissanconnect/screens/dashboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required Map userData});

  @override
  Widget build(BuildContext context) {
    final userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String userId = userData['userId'] ?? '';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Crops Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.chart_bar_square),
              onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => DashboardPage(userData: userData),
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.square_arrow_right),
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            ),
          ],
        ),
      ),
      child: CropsList(userId: userId),
    );
  }
}

class CropsList extends StatelessWidget {
  final String userId;

  const CropsList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('crops').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No crops available'));
        }

        final cropsData = snapshot.data!.data() as Map<String, dynamic>;
        final cropNames = cropsData.keys.toList();

        return Padding(
          padding: const EdgeInsets.all(16.0), // Add padding around the list
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: cropNames.length,
            itemBuilder: (context, index) {
              final cropName = cropNames[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => CropDetailsPage(
                        cropName: cropName,
                        userId: userId,
                        userData: const {},
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CupertinoColors.systemGreen.withOpacity(0.7),
                          CupertinoColors.systemTeal.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.asset(
                              'assets/images/${cropName.toLowerCase()}.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              cropName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}