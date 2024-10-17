// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Shop'),
      ),
      child: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No products available'));
            }

            final products = snapshot.data!.docs;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: CustomScrollView(
                slivers: [
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        final productName = product['productname'] ?? 'Unknown';
                        final productImageUrl = product['image_url'] ?? '';
                        final productDescription = product['description'] ?? 'No description';
                        final productPrice = product['price'] ?? '0';

                        return GestureDetector(
                          onTap: () => _showProductDetails(context, productName, productImageUrl, productDescription, productPrice),
                          child: Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    child: Image.network(
                                      productImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(CupertinoIcons.photo, size: 50),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  child: Text(
                                    '\$${productPrice.toString()}',
                                    style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, String name, String imageUrl, String description, dynamic price) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(imageUrl, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text(description),
            const SizedBox(height: 5),
            Text('Price: ₹ ${price.toString()}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              sendRequestToAdmin('buy', name);
              Navigator.pop(context);
            },
            child: const Text('Buy Now'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              sendRequestToAdmin('rent', name);
              Navigator.pop(context);
            },
            child: const Text('Rent'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void sendRequestToAdmin(String action, String productName) {
    // Replace this with your logic to send a call request to the admin
    print('Request to $action product: $productName');
  }
}