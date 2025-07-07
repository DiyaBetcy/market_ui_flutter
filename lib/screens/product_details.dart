import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final images = product['images'] ?? [];
    final title = product['title'] ?? '';
    final description = product['description'] ?? '';
    final price = product['price']?.toDouble() ?? 0;
    final brand = product['brand'] ?? '';
    final category = product['category'] ?? '';
    final availability = product['availabilityStatus'] ?? 'Available';
    final discount = product['discountPercentage']?.toDouble() ?? 0;
    final tags = product['tags'] ?? [];
    final sku = product['sku'] ?? '';
    final weight = product['weight'] ?? '';
    final dimensions = product['dimensions'] ?? {};
    final warranty = product['warrantyInformation'] ?? '';
    final shipping = product['shippingInformation'] ?? '';
    final minOrder = product['minimumOrderQuantity'] ?? '';
    final barcode = product['meta']?['barcode'] ?? '';
    final qr = product['meta']?['qrCode'];
    final reviews = product['reviews'] ?? [];

    final actualprice = (discount > 0) ? (price / (1 - discount / 100)) : price;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return ClipRect(
                    child: Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          Center(child: Text('Image not found')),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  '₹${price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, color: Colors.green[700]),
                ),
                if (discount > 0) ...[
                  const SizedBox(width: 10),
                  Text(
                    '₹${actualprice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '-${discount.toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 6,
              children: [
                Chip(label: Text(category)),
                ...tags.map((tag) => Chip(label: Text(tag))).toList(),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  availability,
                  style: TextStyle(
                    color: availability.toLowerCase() == 'in stock'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Specifications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Divider(),
            buildSpecRow('Brand', brand),
            buildSpecRow('SKU', sku),
            buildSpecRow('Weight', '$weight g'),
            buildSpecRow(
              'Dimensions',
              '${dimensions['width']} x ${dimensions['height']} x ${dimensions['depth']} cm',
            ),
            buildSpecRow('Warranty', warranty),
            buildSpecRow('Shipping', shipping),
            buildSpecRow('Minimum Order', '$minOrder'),
            buildSpecRow('Barcode', barcode),

            if (qr != null) ...[
              SizedBox(height: 12),
              Text('QR Code'),
              SizedBox(height: 8),
              Image.network(qr, height: 80),
            ],

            const SizedBox(height: 16),

            Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(description),
            SizedBox(height: 20),
            if (reviews.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Customer Reviews',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...reviews.map((review) {
                int rating = review['rating'] ?? 0;
                String comment = review['comment'] ?? '';
                String reviewer = review['reviewerName'] ?? 'Anonymous';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"$comment"',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    Text(
                      '- $reviewer',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const Divider(height: 24),
                  ],
                );
              }).toList(),
            ] else ...[
              const SizedBox(height: 24),
              Text('No reviews yet.', style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('$label:')),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }
}
