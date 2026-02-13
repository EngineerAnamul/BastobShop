// lib/services/api_service.dart
import 'dart:convert';
import 'package:bastoopshop/api/device_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/model.dart';

class ApiService {
  // comment for server test
  static const String baseUrl =
      "https://aihcompany.threestarambulance.com/bastobshop";

  // static const String baseUrl =
  //     "https://cabbagy-linsey-presophomore.ngrok-free.dev";

  static const String _categoryCacheKey = 'cached_categories_v2';
  static const String _lastFetchKey = 'last_category_fetch_v2';

  //commend for test server
  // lastId প্যারামিটার হিসেবে নিবে
  // Future<List<Product>> fetchProducts(int lastId) async {
  //   final response = await http.get(
  //     Uri.parse("$baseUrl/get_products.php?last_id=$lastId"),
  //   );

  //   if (response.statusCode == 200) {
  //     List jsonResponse = json.decode(response.body);
  //     return jsonResponse.map((data) => Product.fromJson(data)).toList();
  //   } else {
  //     return [];
  //   }
  // }

  // lib/services/api_service.dart

  // lib/services/api_service.dart

  Future<List<Product>> fetchProducts(int lastId) async {
    try {
      final response = await http
          .get(
            Uri.parse("https://cabbagy-linsey-presophomore.ngrok-free.dev/get_products?last_id=$lastId"),
            headers: {
              "Accept": "application/json",
              "Connection":
                  "keep-alive", // ১০ লাখ ইউজারের জন্য কানেকশন রিইউজ করা জরুরি
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // ডাটা বড় হলে compute ফাংশন ব্যবহার করা ভালো, তবে ২০টির জন্য এটিই যথেষ্ট
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Product.fromJson(data)).toList();
      } else {
        debugPrint("API Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Network Error: $e");
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

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint("Suggestion Error: $e");
    }
    return []; // এরর হলে খালি লিস্ট দিবে যাতে অ্যাপ না আটকায়
  }

  Future<List<Map<String, dynamic>>> getCategoriesWithCache() async {
    final prefs = await SharedPreferences.getInstance();

    String? cachedData = prefs.getString('cached_categories');
    int? lastFetch = prefs.getInt('last_category_fetch');
    int now = DateTime.now().millisecondsSinceEpoch;

    // ক্যাশ ভ্যালিডেশন (এখানে ক্যাশ থাকলে সেটি রিটার্ন করবে)
    if (cachedData != null &&
        lastFetch != null &&
        (now - lastFetch < 86400000)) {
      List<dynamic> decoded = json.decode(cachedData);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/get_categories.php'));
      if (response.statusCode == 200) {
        // লোকাল স্টোরেজে নতুন ডাটা সেভ
        await prefs.setString('cached_categories', response.body);
        await prefs.setInt('last_category_fetch', now);

        List<dynamic> data = json.decode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print("Network Error: $e");
      // যদি নেটওয়ার্ক ফেইল করে কিন্তু আগে ক্যাশ করা ডাটা থাকে, তবে সেটিই দেখাবে
      if (cachedData != null) {
        return (json.decode(cachedData) as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return [];
  }

  Future<List<Product>> fetchRecommendations(int productId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/recommendations.php?product_id=$productId"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Recommendation Error: $e");
      return [];
    }
  }

  Future<void> trackUserInteraction(int productId) async {
    try {
      // ডিভাইস আইডি সংগ্রহ করা হচ্ছে
      String deviceId = await DeviceService.getDeviceId();

      final response = await http.post(
        Uri.parse("$baseUrl/track_interaction.php"),
        body: {
          "user_id": deviceId, // এখন আর ০ না, আসল ডিভাইস আইডি যাবে
          "product_id": productId.toString(),
          "type": "view",
        },
      );

      print("Tracking Status: ${response.body}");
    } catch (e) {
      print("Tracking error: $e");
    }
  }
}
