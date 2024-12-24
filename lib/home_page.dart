import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskecommarce/add_product_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> productStrings = prefs.getStringList('products') ?? [];
    setState(() {
      products = productStrings
          .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
          .toList();
      filteredProducts = products;
    });
  }

  void deleteProduct(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    products.removeAt(index);
    prefs.setStringList(
        'products', products.map((e) => jsonEncode(e)).toList());
    setState(() {
      filteredProducts = products;
    });
  }

  void searchProduct(String query) {
    setState(() {
      filteredProducts = products
          .where((product) =>
          product['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Map<String, List<Map<String, dynamic>>> groupProductsByCategory() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var product in filteredProducts) {
      String category = product['category'] ?? 'Products';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(product);
    }
    return grouped;
  }

  Widget buildCategorySection(String category, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$category ${items.length}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Show all'),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final product = items[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        child: product['image'] != null
                            ? Image.memory(
                          base64Decode(product['image']),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          height: 140,
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '\$${product['price']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete_outline, size: 20),
                        onPressed: () => deleteProduct(index),
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedProducts = groupProductsByCategory();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Go back action
          },
        ),

      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi-Fi Shop & Service',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tech accessories shop on Bhopal',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'This shop offers both products and services',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: searchProduct,
              ),
            ),
            ...groupedProducts.entries.map(
                  (entry) => buildCategorySection(entry.key, entry.value),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          ).then((_) => loadProducts());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}