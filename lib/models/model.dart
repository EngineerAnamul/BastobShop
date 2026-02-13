

//Product models
class Product {
  final int id;
  final String name;
  final String price;
  final String? discountPrice;
  final String imageUrl;

  // নতুন ফিল্ডগুলো
  final String? description;
  final String? stockCount;
  final String? vendorName;
  final double? sellerRating;
  final int? reviewsCount;
  final double? avgRating;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    this.description,
    this.stockCount,
    this.vendorName,
    this.sellerRating,
    this.reviewsCount,
    this.avgRating,
    this.quantity = 1,
  });



  // ১ কোটি ডেটার সময় JSON কী (Key) মিসিং থাকলে অ্যাপ যেন ক্রাশ না করে
  // factory Product.fromJson(Map<String, dynamic> json) {
  //   return Product(
  //     id: int.tryParse(json['id'].toString()) ?? 0,
  //     name: json['name']?.toString() ?? "Unnamed Product",
  //     price: json['price']?.toString() ?? "0.0",
  //     discountPrice: json['discount_price']?.toString(),
  //     imageUrl: json['image_url']?.toString() ?? "",
  //     description: json['description']?.toString(),
  //     stockCount: json['stock_count']?.toString(),
  //     vendorName: json['store_name']?.toString(),
  //     sellerRating: double.tryParse(json['seller_rating']?.toString() ?? "0"),
  //     reviewsCount: int.tryParse(json['reviews_count']?.toString() ?? "0"),
  //     avgRating: double.tryParse(json['avg_rating']?.toString() ?? "0"),
  //   );
  // }



factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // ১. ID হ্যান্ডেলিং (১০ লাখ ইউজারের জন্য টাইপ সেফটি জরুরি)
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,

      // ২. নাম
      name: json['name']?.toString() ?? "Unnamed Product",

      // ৩. প্রাইস (Go থেকে float আসে, তাই string এ কনভার্ট করুন)
      price: json['price']?.toString() ?? "0.0",

      // ৪. ইমেজ ইউআরএল (সবচেয়ে গুরুত্বপূর্ণ: সার্ভার পাঠায় image_url)
      imageUrl: json['image_url']?.toString() ?? "",

      // ৫. ডিসকাউন্ট প্রাইস (যদি সার্ভার না পাঠায় তবে null)
      discountPrice: json['discount_price']?.toString(),

      // ৬. এই ফিল্ডগুলো Go সার্ভার এখনো পাঠাচ্ছে না, তাই ডিফল্ট ভ্যালু দিন
      description: json['description']?.toString() ?? "",
      stockCount: json['stock_count']?.toString() ?? "In Stock",
      vendorName:
          json['vendor_name']?.toString() ??
          json['store_name']?.toString() ??
          "Bastob Seller",

      // ৭. রেটিং (সার্ভার থেকে না আসলে ডিফল্ট ০.০)
      sellerRating:
          double.tryParse(json['seller_rating']?.toString() ?? "0.0") ?? 0.0,
      reviewsCount: int.tryParse(json['reviews_count']?.toString() ?? "0") ?? 0,
      avgRating:
          double.tryParse(json['avg_rating']?.toString() ?? "0.0") ?? 0.0,

      quantity: 1,
    );
  }



// ApiService এর জন্য আলাদা fromMap (সহজ ম্যাপ করার জন্য)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: int.tryParse(map['id'].toString()) ?? 0,
      name: map['name']?.toString() ?? "",
      price: map['price']?.toString() ?? "0",
      discountPrice: map['discount_price']?.toString(),
      imageUrl: map['image_url']?.toString() ?? "",
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// এটি হবে আপনার গ্লোবাল কার্ট লিস্ট
List<CartItem> myCart = [];


class Vendor {
  final int id;
  final String storeName;
  final double rating;
  final bool isVerified;
  final String logoUrl; // String? এর বদলে String দিন অথবা default value সেট করুন
  final String bannerUrl;
  final String about;
  final String responseRate;
  final String memberSince; // এই ফিল্ডটি নিশ্চিত করুন
  final double followers;

  Vendor({
    required this.id,
    required this.storeName,
    required this.rating,
    required this.isVerified,
    required this.logoUrl,
    required this.bannerUrl,
    required this.about,
    required this.responseRate,
    required this.memberSince,
    required this.followers
  });



  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      storeName: json['store_name']?.toString() ?? 'Bastob Seller',
      // String কে double এ কনভার্ট করা (নিরাপদ উপায়)
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      isVerified: json['is_verified'].toString() == "1",
      // লোগো ইউআরএল হ্যান্ডলিং
      logoUrl:
          (json['logo_url'] != null && json['logo_url'].toString().isNotEmpty)
          ? json['logo_url'].toString()
          : "http://aihcompany.threestarambulance.com/bastobshop/uploads/bastobshop_logo.png",

      // ব্যানার ইউআরএল হ্যান্ডলিং (এটিই আপনি চাচ্ছিলেন)
      bannerUrl:
          (json['banner_url'] != null &&
              json['banner_url'].toString().isNotEmpty)
          ? json['banner_url'].toString()
          : "http://aihcompany.threestarambulance.com/bastobshop/uploads/bastobshop_logo.png",
      about: json['description']?.toString() ?? "No description available.",

      responseRate: "${json['response_rate'] ?? '0'}%",
      // ব্রাউজারে joining_date আছে, তাই এখানেও joining_date হবে
      memberSince: json['joining_date'] != null
          ? json['joining_date'].toString().split(' ')[0]
          : "2026",
      followers: double.tryParse(json['total_followers'].toString()) ?? 0.0,
    );
  }


}
