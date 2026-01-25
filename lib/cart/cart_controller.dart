import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  // ১. প্রাইভেট লিস্ট
  final List<Product> _items = [];

  // ২. গেটার - বাইরে থেকে ডাটা দেখার জন্য
  List<Product> get items => _items;

  // ৩. কার্টে আইটেম সংখ্যা
  int get itemCount => _items.length;

  /*  // ৪. টোটাল প্রাইজ হিসাব
  double get totalAmount {
    double priceValue = double.tryParse(item.price.toString()) ?? 0.0;
    return _items.fold(0.0, (sum, item) => sum + item.price);
  }*/
/*  double get totalAmount {
    return _items.fold(0.0, (sum, item) {
      // যদি price স্ট্রিং হয়, তবে সেটিকে double-এ রূপান্তর করছি
      double priceValue = double.tryParse(item.price.toString()) ?? 0.0;
      return sum + priceValue;
    });
  }*/
  double get totalAmount {
    return _items.fold(0.0, (sum, item) {
      // ১. String price কে double-এ রূপান্তর (যাতে এরর না আসে)
      double priceValue = double.tryParse(item.price.toString()) ?? 0.0;

      // ২. প্রাইসের সাথে কোয়ান্টিটি গুণ করে টোটাল যোগ করা
      return sum + (priceValue * item.quantity);
    });
  }

  // ৫. আইটেম যোগ করা
  void addToCart(Product product) {
    _items.add(product);
    notifyListeners(); // এটিই ম্যাজিক! এটি সব স্ক্রিনকে অটোমেটিক আপডেট করে দিবে।
  }

  // ৬. আইটেম রিমুভ করা
  void removeItem(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  // ৭. কার্ট ক্লিয়ার করা
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // আপনার CartProvider ক্লাসের ভেতরে এগুলো বসান
  void incrementQuantity(Product product) {
    product.quantity++; // নিশ্চিত করুন Product মডেল এ quantity ফিল্ড আছে
    notifyListeners();
  }

  void decrementQuantity(Product product) {
    if (product.quantity > 1) {
      product.quantity--;
    } else {
      removeItem(product); // ১ এর নিচে গেলে রিমুভ করে দিবে
    }
    notifyListeners();
  }
}

/*

import 'dart:ui';

import '../models/product_model.dart';

List<CartItem> myCart = [];

// কার্টে অ্যাড করার ফাংশন
void addToCart(Product product, {VoidCallback? onUpdate}) {
  int index = myCart.indexWhere((item) => item.product.name == product.name);

  if (index != -1) {
    myCart[index].quantity++;
  } else {
    myCart.add(CartItem(product: product));
  }
  // যদি কোনো Callback ফাংশন পাঠানো হয়, তবে সেটি রান হবে
  if (onUpdate != null) {
    onUpdate();
  }

  print("Cart Length: ${myCart.length}");
}


// কার্টের টোটাল প্রাইজ বের করার ফাংশন (ভবিষ্যতের জন্য)
double get totalCartPrice {
  return myCart.fold(0, (sum, item) => sum + (double.parse(item.product.price) * item.quantity));
}*/
