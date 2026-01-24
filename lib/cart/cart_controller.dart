
// গ্লোবাল কার্ট লিস্ট
import '../models/product_model.dart';

List<CartItem> myCart = [];

// কার্টে অ্যাড করার ফাংশন
void addToCart(Product product) {
  int index = myCart.indexWhere((item) => item.product.name == product.name);

  if (index != -1) {
    myCart[index].quantity++;
  } else {
    myCart.add(CartItem(product: product));
  }
}

// কার্টের টোটাল প্রাইজ বের করার ফাংশন (ভবিষ্যতের জন্য)
double get totalCartPrice {
  return myCart.fold(0, (sum, item) => sum + (double.parse(item.product.price) * item.quantity));
}