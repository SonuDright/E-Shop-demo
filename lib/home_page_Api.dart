import 'dart:convert';
import 'package:e_shop_demo/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'e_shop_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<ProductModel?> getData() async {
    var url = Uri.parse("https://dummyjson.com/products");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var user = jsonDecode(response.body);
      var users = ProductModel.fromJson(user);
      return users;
    } else {
      return ProductModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreenSignUp(),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          "Home Screen",
          style: TextStyle(
              color: Colors.blue, fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<ProductModel?>(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var items = snapshot.data?.products ?? [];
              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,  // Number of columns
                  crossAxisSpacing: 10.0,  // Space between columns
                  mainAxisSpacing: 10.0,  // Space between rows
                  childAspectRatio: 0.7,  // Aspect ratio of each grid item
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var product = items[index];

                  // Calculate new price after discount
                  double? originalPrice = product.price;
                  double? discountPercentage = product.discountPercentage;
                  double discountedPrice =
                      originalPrice! * (1 - (discountPercentage! / 100));

                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: Image.network(
                                product.thumbnail.toString(),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Product Details
                          Text(
                            product.title.toString(),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 2,  // Limit title text to 2 lines
                            overflow: TextOverflow.ellipsis,  // Handle overflow with ellipsis
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Old Price: Rs. ${originalPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.lineThrough, // Strikethrough for old price
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "New Price: Rs. ${discountedPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red, // Highlight new price
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Discount: ${discountPercentage.toString()}%",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
