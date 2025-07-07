import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminProductPage extends StatefulWidget {
  const AdminProductPage({super.key});

  @override
  State<AdminProductPage> createState() => _AdminProductPageState();
}

class _AdminProductPageState extends State<AdminProductPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    final response = await http.get(Uri.parse('https://dummyjson.com/products'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        products = data['products'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch products")));
    }
  }

  Future<void> deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete")),
        ],
      ),
    );

    if (confirm ?? false) {
      // You can replace the below URL with your own DELETE API endpoint
      final response = await http.delete(Uri.parse('https://dummyjson.com/products/$id'));
      if (response.statusCode == 200) {
        fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted Successfully")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete")));
      }
    }
  }

  void showProductForm({Map<String, dynamic>? product}) {
    final titleController = TextEditingController(text: product?['title'] ?? '');
    final priceController = TextEditingController(text: product?['price']?.toString() ?? '');
    final descController = TextEditingController(text: product?['description'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
              TextField(controller: priceController, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
              TextField(controller: descController, decoration: InputDecoration(labelText: "Description")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text;
              final price = double.tryParse(priceController.text) ?? 0;
              final desc = descController.text;

              if (title.isEmpty || desc.isEmpty || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All fields are required")));
                return;
              }

              final body = jsonEncode({
                "title": title,
                "price": price,
                "description": desc,
              });

              final url = product == null
                  ? Uri.parse('https://dummyjson.com/products/add')
                  : Uri.parse('https://dummyjson.com/products/${product['id']}');

              final response = product == null
                  ? await http.post(url, body: body, headers: {'Content-Type': 'application/json'})
                  : await http.put(url, body: body, headers: {'Content-Type': 'application/json'});

              if (response.statusCode == 200 || response.statusCode == 201) {
                Navigator.pop(context);
                fetchProducts();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(product == null ? "Added!" : "Updated!")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to submit")));
              }
            },
            child: Text(product == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Product Manager"),
        actions: [
          IconButton(onPressed: () => showProductForm(), icon: Icon(Icons.add)),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return ListTile(
                  title: Text(p['title']),
                  subtitle: Text("₹${p['price']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => showProductForm(product: p)),
                      IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => deleteProduct(p['id'])),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
