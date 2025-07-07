import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/product_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<dynamic> products = [];
  bool isLoading = true;
  List<dynamic> allProducts = [];
  TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All';
  double minPrice = 0;
  double maxPrice = 200000;

  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('https://dummyjson.com/products');
    final response = await http.get(url);

    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> fetchedProducts = data['products'];
      final Set<String> categorySet = fetchedProducts
          .map<String>((p) => p['category'])
          .toSet();

      setState(() {
        allProducts = data['products'];
        products = allProducts;
        categories = ['All', ...categorySet];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load products')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product List'),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => buildFilterSheet(),
            );
          },
        ),
      ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      final filtered = allProducts.where((product) {
                        final title = product['title'].toString().toLowerCase();
                        return title.contains(value.toLowerCase());
                      }).toList();

                      setState(() {
                        products = filtered;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by product name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600
                          ? 3
                          : 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return InkWell(
                        onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductDetailsPage(product: product)));
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product['thumbnail'],
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          height: 100,
                                          color: Colors.grey[300],
                                          alignment: Alignment.center,
                                          child: Text('No Image'),
                                        ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  product['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '₹ ${product['price']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green[700],
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  product['description'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
    
  }
  Widget buildFilterSheet() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: selectedCategory,
          items: categories.map((cat) {
            return DropdownMenuItem(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (value) => setState(() => selectedCategory = value!),
          decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
        ),
        SizedBox(height: 16),

        Text('Price Range'),
        RangeSlider(
          values: RangeValues(minPrice, maxPrice),
          min: 0,
          max: 200000,
          divisions: 20,
          labels: RangeLabels('₹${minPrice.round()}', '₹${maxPrice.round()}'),
          onChanged: (values) {
            setState(() {
              minPrice = values.start;
              maxPrice = values.end;
            });
          },
        ),
        SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              child: Text('Clear'),
              onPressed: () {
                setState(() {
                  selectedCategory = 'All';
                  minPrice = 0;
                  maxPrice = 200000;
                  products = allProducts;
                });
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('Apply'),
              onPressed: () {
                final filtered = allProducts.where((product) {
                  final price = product['price'].toDouble();
                  final categoryMatch = selectedCategory == 'All' || product['category'] == selectedCategory;
                  final priceMatch = price >= minPrice && price <= maxPrice;
                  return categoryMatch && priceMatch;
                }).toList();

                setState(() => products = filtered);
                Navigator.pop(context);
              },
            ),
          ],
        )
      ],
    ),
  );
}

}
