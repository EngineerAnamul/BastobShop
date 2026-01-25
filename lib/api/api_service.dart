// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = "https://aihcompany.threestarambulance.com/bastobshop";


  Future<List<Product>> fetchProducts(int page) async {
    final response = await http.get(Uri.parse("$baseUrl/get_products.php?page=$page"));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Product.fromJson(data)).toList();
    } else {
      return [];
    }
  }
}