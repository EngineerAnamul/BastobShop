class Product {
  final String id;
  final String name;
  final String price;
  final String imageUrl;

  Product({required this.id, required this.name, required this.price, required this.imageUrl});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'],
      price: json['price'],
      imageUrl: json['image_url'],
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


