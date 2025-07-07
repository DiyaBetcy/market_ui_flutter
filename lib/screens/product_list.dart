import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_page.dart';
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
  double maxPrice = 0;
  List<Map<String, double>> priceRanges = [];
  int? selectedRangeIndex;
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
      final prices = fetchedProducts
          .map((p) => (p['price'] as num).toDouble())
          .toList();
      final double min = prices.reduce((a, b) => a < b ? a : b);
      final double max = prices.reduce((a, b) => a > b ? a : b);
      final Set<String> categorySet = fetchedProducts
          .map<String>((p) => p['category'])
          .toSet();

      setState(() {
        allProducts = fetchedProducts;
        products = allProducts;
        categories = ['All', ...categorySet];
        isLoading = false;
        minPrice = min;
        maxPrice = max;
        generatePriceRanges();
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

  void generatePriceRanges() {
    priceRanges.clear();
    double rangeStart = (minPrice ~/ 500) * 500;
    double rangeEnd = ((maxPrice / 500).ceil()) * 500;

    for (double start = rangeStart; start < rangeEnd; start += 500) {
      priceRanges.add({'min': start, 'max': start + 499});
    }
    // Final range for "max and above"
    priceRanges.add({'min': rangeEnd, 'max': double.infinity});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Confirm Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx); // close dialog
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                          (route) => false,
                        );
                      },
                      child: Text('Logout'),
                    ),
                  ],
                ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (context) => buildFilterSheet(),
                          );
                        },
                        icon: Icon(Icons.filter_list),
                        label: Text('Filter'),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsPage(product: product),
                            ),
                          );
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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              height: 100,
                                              color: Colors.grey[300],
                                              alignment: Alignment.center,
                                              child: Text('No Image'),
                                            ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['title'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
                                  maxLines: 1,
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
    String tempCategory = selectedCategory;
    int? tempRangeIndex = selectedRangeIndex;

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tempCategory,
                  items: categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) {
                    setSheetState(() => tempCategory = value!);
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Text('Price Range'),
                Column(
                  children: List.generate(priceRanges.length, (index) {
                    final range = priceRanges[index];
                    final isLast = range['max'] == double.infinity;
                    final label = isLast
                        ? '₹${range['min']!.round()} and above'
                        : '₹${range['min']!.round()} - ₹${range['max']!.round()}';

                    return CheckboxListTile(
                      title: Text(label),
                      value: tempRangeIndex == index,
                      onChanged: (val) {
                        setSheetState(() {
                          tempRangeIndex = val == true ? index : null;
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = 'All';
                          selectedRangeIndex = null;
                          products = allProducts;
                        });
                        Navigator.pop(context);
                      },
                      child: Text('Clear Filters'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // ✅ Update main state here
                        setState(() {
                          selectedCategory = tempCategory;
                          selectedRangeIndex = tempRangeIndex;

                          double selectedMin = 0;
                          double selectedMax = double.infinity;

                          if (selectedRangeIndex != null &&
                              selectedRangeIndex! >= 0 &&
                              selectedRangeIndex! < priceRanges.length) {
                            selectedMin =
                                priceRanges[selectedRangeIndex!]['min']!;
                            selectedMax =
                                priceRanges[selectedRangeIndex!]['max']!;
                          }

                          products = allProducts.where((product) {
                            final price = (product['price'] as num).toDouble();
                            final categoryMatch =
                                selectedCategory == 'All' ||
                                product['category'] == selectedCategory;
                            final priceMatch =
                                price >= selectedMin && price <= selectedMax;
                            return categoryMatch && priceMatch;
                          }).toList();
                        });

                        Navigator.pop(context);
                      },
                      child: Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
