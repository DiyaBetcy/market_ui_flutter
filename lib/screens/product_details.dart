import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final images = product['images'] ?? [];
    final title = product['title'] ?? '';
    final description = product['description'] ?? '';
    final price = product['price'] ?? '';
    final brand = product['brand'] ?? '';
    final category = product['category'] ?? '';
    final availability = product['availabilityStatus'] ?? 'Available';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Center(child: Text('Image not found')),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Brand: $brand'),
            Text('Category: $category'),
            Text('Status: $availability'),
            const SizedBox(height: 8),
            Text(
              '₹ $price',
              style: TextStyle(fontSize: 18, color: Colors.green[700]),
            ),
            const SizedBox(height: 12),
            Text(description),
          ],
        ),
      ),
    );
  }
}
