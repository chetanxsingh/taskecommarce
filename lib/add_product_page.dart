import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _image;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> addProduct(String name, String price, String? imageBase64) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> products = prefs.getStringList('products') ?? [];

    // Check for duplicates
    if (products.any((e) => jsonDecode(e)['name'] == name)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Product already exists')));
      return;
    }

    products.add(jsonEncode({
      'name': name,
      'price': price,
      'image': imageBase64,
    }));
    prefs.setStringList('products', products);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: _image != null
                    ? Image.file(
                  _image!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 150,
                  width: 150,
                  color: Colors.grey[300],
                  child: Icon(Icons.camera_alt, color: Colors.grey),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a product name' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a price' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final imageBase64 =
                    _image != null ? base64Encode(_image!.readAsBytesSync()) : null;
                    addProduct(nameController.text, priceController.text, imageBase64);
                  }
                },
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}