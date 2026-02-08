// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/model.dart';

class ApiService {
  static const String baseUrl =
      "https://aihcompany.threestarambulance.com/bastobshop";

  // lastId প্যারামিটার হিসেবে নিবে
  Future<List<Product>> fetchProducts(int lastId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_products.php?last_id=$lastId"),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Product.fromJson(data)).toList();
    } else {
      return [];
    }
  }

  Future<Product> fetchProductDetails(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_product_details.php?id=$productId'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Product.fromJson(
        data['data'],
      ); // এটি আপনার নতুন বড় মডেল অনুযায়ী ডাটা ম্যাপ করবে
    } else {
      throw Exception('Failed to load details');
    }
  }

  // হাই-ট্রাফিক হ্যান্ডেল করার জন্য সিঙ্গেলটন প্যাটার্ন
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Vendor> fetchVendorDetails(int vendorId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/get_vendor_details.php?id=$vendorId'),
            headers: {
              "Accept": "application/json",
              "Connection":
                  "keep-alive", // ১০ লাখ ইউজারের জন্য কানেকশন ধরে রাখা জরুরি
            },
          )
          .timeout(const Duration(seconds: 10)); // টাইমআউট সেট করা

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('error')) {
          throw Exception(data['error']);
        }
        return Vendor.fromJson(data);
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network logic error: $e');
    }
  }

  // lib/services/api_service.dart এর ভেতরে
  Future<List<Product>> fetchVendorProducts(
    int vendorId, {
    int limit = 5,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_vendor_top_products.php?vendor_id=$vendorId&limit=$limit',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List list = data['data'];
        return list.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching vendor products: $e");
      return [];
    }
  }

  Future<List<Product>> searchProducts(Map<String, dynamic> params) async {
    try {
      // এখানে ফাংশনের প্যারামিটার 'params' ব্যবহার করে 'uri' তৈরি হচ্ছে
      final uri = Uri.parse("$baseUrl/search.php").replace(
        queryParameters: params.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      // uri সরাসরি পাস করুন
      final response = await http.get(uri).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromMap(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Search API Error: $e");
      return [];
    }
  }

  // সাজেশনের জন্য এই ফাংশনটি ব্যবহার করুন
  Future<List<Object>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      // ১ কোটি ডেটার ক্ষেত্রে সাজেশনের জন্য ৫ সেকেন্ডের বেশি সময় দেওয়া ঠিক নয়
      final response = await http
          .get(Uri.parse("$baseUrl/suggestions.php?q=$query"))
          .timeout(const Duration(seconds: 5));

      // if (response.statusCode == 200) {
      //   List<dynamic> data = json.decode(response.body);
      //   // শুধুমাত্র স্ট্রিং লিস্ট রিটার্ন করবে
      //   return data.map((item) => item.toString()).toList();
      // }

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint("Suggestion Error: $e");
    }
    return []; // এরর হলে খালি লিস্ট দিবে যাতে অ্যাপ না আটকায়
  }
}
