import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminProductPage extends StatefulWidget {
  const AdminProductPage({super.key});

  @override
  State<AdminProductPage> createState() => _AdminProductPageState();
}

class _AdminProductPageState extends State<AdminProductPage> {
  List<dynamic> products = [];
  List<dynamic> allproducts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        allproducts = data['products'];
        products = allproducts;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load products')));
    }
  }

  Future<void> addProduct() async {
    final _formKey = GlobalKey<FormState>();
    String title = "", description = '', category = '', thumbnail = '';
    int price = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New product'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  onChanged: (val) => title = val,
                  validator: (val) => val!.isEmpty ? 'Enter title' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => price = int.tryParse(val) ?? 0,
                  validator: (val) => val!.isEmpty ? 'Enter price' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onChanged: (val) => description = val,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Category'),
                  onChanged: (val) => category = val,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Thumbnail URL'),
                  onChanged: (val) => thumbnail = val,
                  enableInteractiveSelection: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final response = await http.post(
                  Uri.parse('https://dummyjson.com/products/add'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'title': title,
                    'price': price,
                    'description': description,
                    'category': category,
                    'thumbnail': thumbnail,
                  }),
                );
                if (response.statusCode == 200 || response.statusCode == 201) {
                  final data = jsonDecode(response.body);
                  setState(() => products.insert(0, data));
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add product')),
                  );
                }
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> updateProduct(int id) async {
    final product = products.firstWhere((p) => p['id'] == id);
    final _formKey = GlobalKey<FormState>();
    String title = product['title'] ?? '';
    String description = product['description'] ?? '';
    String category = product['category'] ?? '';
    String thumbnail = product['thumbnail'] ?? '';
    double price = product['price'] ?? 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Product'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (val) => val!.isEmpty ? 'Enter title' : null,
                onChanged: (val) => title = val,
              ),
              TextFormField(
                initialValue: price.toString(),
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Enter price' : null,
                onChanged: (val) => price = double.tryParse(val) ?? 0,
              ),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (val) => description = val,
              ),
              TextFormField(
                initialValue: category,
                decoration: InputDecoration(labelText: 'Category'),
                onChanged: (val) => category = val,
              ),
              TextFormField(
                initialValue: thumbnail,
                decoration: InputDecoration(labelText: 'Thumbnail URL'),
                onChanged: (val) => thumbnail = val,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            child: Text('Update'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final response = await http.put(
                  Uri.parse('https://dummyjson.com/products/$id'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'title': title,
                    'price': price,
                    'description': description,
                    'category': category,
                    'thumbnail': thumbnail,
                  }),
                );

                if (response.statusCode == 200) {
                  final updated = jsonDecode(response.body);
                  setState(() {
                    final index = products.indexWhere((p) => p['id'] == id);
                    if (index != -1) {
                      products[index] = updated;
                    }
                  });
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://dummyjson.com/products/$id'),
      );
      setState(() => products.removeWhere((p) => p['id'] == id));
      if (response.statusCode == 200) {
        print("Deleted from server (simulated).");
      } else {
        print("Deleted locally, but API did not return 200.");
      }
    } catch (e) {
      print("Error while deleting: $e");
      setState(() => products.removeWhere((p) => p['id'] == id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Manage Products'),
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
                      final filtered = allproducts.where((product) {
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
                      IconButton(onPressed: addProduct, icon: Icon(Icons.add),
                      tooltip: 'Add Product'
                     ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            product['thumbnail'] ?? '',
                          ),
                        ),
                        title: Text(product['title']),
                        subtitle: Text('₹ ${product['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => updateProduct(product['id']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Confirm Delete'),
                                  content: Text(
                                    'Are you sure you want to delete this product?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        deleteProduct(product['id']);
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
