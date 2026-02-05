import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // প্রোভাইডার ইমপোর্ট
import '../app_color.dart';
import '../cart/cart_controller.dart'; // আপনার CartProvider ক্লাস
import '../models/model.dart';
import '../service/ui_helper.dart';

class ProfileScreen extends StatelessWidget { // StatefulWidget এর আর দরকার নেই
  final VoidCallback onMenuTap;
  final VoidCallback onClose;
  final bool isDrawerOpen;

  const ProfileScreen({
    super.key,
    required this.onMenuTap,
    required this.onClose,
    required this.isDrawerOpen
  });

  @override
  Widget build(BuildContext context) {
    // প্রোভাইডার লিসেনার
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // ১. এটি বডিকে অ্যাপবারের নিচ থেকে শুরু করতে বাধ্য করবে
      // extendBodyBehindAppBar: true,


      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  leading: _buildLeadingIcon(
                    isDrawerOpen: isDrawerOpen,
                    onClose: onClose,
                    onMenuTap: onMenuTap,
                  ),
                  title: _buildLogoTitle(),
                  actions: [
                    _buildActionIcon(Icons.search_rounded, () {}),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),


      // ১. কন্টেন্টকে মাঝখানে রাখার জন্য Center ব্যবহার
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : Center(
        child: ConstrainedBox(
          // ২. এখানে আমরা স্ক্রিনের সর্বোচ্চ চওড়া ৮০০ পিক্সেল সেট করে দিচ্ছি
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final product = cart.items[index];
                    return _buildCartItem(context, product, cart);
                  },
                ),
              ),
              _buildPriceSummary(cart),
            ],
          ),
        ),
      ),
    );
  }




  Widget _buildCartItem(BuildContext context, Product product, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // আরও রাউন্ডেড
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showProductDetails(context, product),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // ১. ইমেজ সেকশন (Soft Background সহ)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    product.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ২. কন্টেন্ট সেকশন
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        // ডিলিট বাটনটি এখন ছোট এবং ক্লিন
                        GestureDetector(
                          onTap: () => cart.removeItem(product),
                          child: Icon(Icons.close_rounded, color: Colors.grey[400], size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Premium Quality", // অথবা সাব-ক্যাটেগরি
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 12),

                    // ৩. প্রাইস এবং কাউন্টার (নিচের অংশ)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "৳${product.price}",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),

                        // প্রফেশনাল কাউন্টার বাটন (এনিমেশন সহ)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              _buildCounterButton(Icons.remove, () {
                                cart.decrementQuantity(product);
                              }),

                              // এনিমেটেড সংখ্যা
                              SizedBox(
                                width: 30,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return ScaleTransition(scale: animation, child: child);
                                  },
                                  child: Text(
                                    '${product.quantity}',
                                    key: ValueKey<int>(product.quantity), // Key জরুরি এনিমেশনের জন্য
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),

                              _buildCounterButton(Icons.add, () {
                                cart.incrementQuantity(product);
                              }, isPrimary: true),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// কাউন্টার বাটনের হেল্পার মেথড
  Widget _buildCounterButton(IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isPrimary ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPriceSummary(CartProvider cart) {
    double deliveryCharge = 50.0;
    double total = cart.totalAmount + deliveryCharge;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)), // আরও মডার্ন কার্ভ
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // কুপন কোড সেকশন (বড় কোম্পানিতে এটি থাকেই)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                const Text("Apply Promo Code", style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // প্রাইজ ডিটেইলস
          _priceRow("Subtotal", "৳ ${cart.totalAmount}"),
          _priceRow("Delivery Charge", "৳ $deliveryCharge"),

          // ড্যাশড ডিভাইডার (এটি দেখতে খুব স্মার্ট লাগে)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: List.generate(30, (index) => Expanded(
                child: Container(
                  color: index % 2 == 0 ? Colors.transparent : Colors.grey[200],
                  height: 1.5,
                ),
              )),
            ),
          ),

          // গ্র্যান্ড টোটাল
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
                child: Text("৳ $total"),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // প্রিমিয়াম চেকআউট বাটন
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // এখানে আপনার চেকআউট লজিক বসবে
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Proceed to Checkout",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          // নিচের সেফ এরিয়া স্পেস
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? Colors.black : Colors.grey[600], fontSize: isTotal ? 18 : 14)),

          // এনিমেটেড প্রাইজ
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isTotal ? 22 : 16,
              color: isTotal ? AppColors.primary : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Your cart is empty!", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // উপরে ড্র্যাগ করার হ্যান্ডেল
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 15),
                  // ১. ইমেজ স্লাইডার (প্রফেশনাল লুক)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          product.imageUrl,
                          height: 350,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 15,
                        right: 15,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ২. নাম এবং রেটিং
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 16,
                            ),
                            Text(
                              " 4.5",
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "124 Reviews",
                        style: TextStyle(
                          color: Colors.grey[600],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "In Stock",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 35),

                  // ৩. দাম সেকশন (৳)
                  Row(
                    children: [
                      Text(
                        "৳ ${product.price}",
                        style: TextStyle(
                          fontSize: 26,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "৳ ${product.price}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          "20% OFF",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ৪. মাল্টি-ভেন্ডার স্পেশাল: সেলার ইনফো (Professional Style)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blueGrey.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.store, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Sold by: Bastob Vendor Ltd.",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "Positive Seller Ratings: 92%",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                // আগের প্রোডাক্ট ডিটেইলস শিটটি বন্ধ করে সেলার শিটটি খুলবে
                                // Navigator.pop(context);
                                _showSellerFullProfile(
                                  context,
                                  product,
                                ); // নতুন এই ফাংশনটি কল হবে
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primary),
                              ),
                              child: const Text(
                                "Visit Store",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ৫. ডেসক্রিপশন
                  const Text(
                    "Product Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "High quality premium material used in this product to ensure durability. Authentic and verified by our QC team.",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ৬. ট্রাস্ট ব্যাজ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _trustIcon(
                        Icons.local_shipping_outlined,
                        "Fast Delivery",
                      ),
                      _trustIcon(Icons.verified_outlined, "100% Original"),
                      _trustIcon(
                        Icons.assignment_return_outlined,
                        "7 Days Return",
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                  // নিচের বাটনের জন্য জায়গা
                ],
              ),
            ),

            // ৭. বটম অ্যাকশন বার (Buy Now & Add to Cart)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // চ্যাট বাটন (মাল্টি ভেন্ডার এর জন্য জরুরি)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_outlined, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // কার্ট বাটন
/*                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      */
                  /*                      onPressed: () {
                        //  কার্টে অ্যাড
                        addToCart(
                          product,
                          onUpdate: () {
                            // এটি হোম স্ক্রিনকে রিফ্রেশ করবে
                            setState(() {});
                          },
                        );
                        //  পপ-আপ বন্ধ করুন
                        Navigator.pop(context);

                        // আগের সব স্নাকবার আগে ক্লিয়ার করুন
                        ScaffoldMessenger.of(context).clearSnackBars();

                        //  স্নাকবারটি
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${product.name} added to cart!"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3), // ৩ সেকেন্ড
                          ),
                        );

                        // ৩. একটি ফোর্স টাইমার  (অ্যান্ড্রয়েডের জন্য)
                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) {
                            // চেক করে নেওয়া হচ্ছে ইউজার ওই স্ক্রিনে আছে কি না
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          }
                        });
                      },*/
                  /*
                      onPressed: () {
                        // প্রোভাইডার কল করা
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).addToCart(product);

                        Navigator.pop(context);
                        UIService.showSuccessSnackBar(
                          context,
                          "${product.name} added to cart!",
                        );
                      },


*/
/*                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),*//*
                    ),
                  ),*/
                  const SizedBox(width: 12),
                  // বাই নাও বাটন
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Buy Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
void _showSellerFullProfile(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    // এটি জরুরি যাতে কিবোর্ড বা বড় কন্টেন্টে ঝামেলা না হয়
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height:
      MediaQuery.of(context).size.height *
          0.80, // উচ্চতা একটু বাড়িয়ে ৮০% করলাম
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // ১. ফিক্সড উপরের অংশ (Drag Handle)
          const SizedBox(height: 15),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // ২. স্ক্রোলযোগ্য মাঝখানের অংশ
          Expanded(
            child: SingleChildScrollView(
              // এটিই আপনার স্ক্রিনকে স্ক্রোলযোগ্য করবে
              physics: const BouncingScrollPhysics(),
              // স্মুথ স্ক্রোলিং এর জন্য
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.store, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Bastob Vendor Ltd.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Member since 2023",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // সেলার স্ট্যাটাস কার্ড
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _sellerStat("4.8/5", "Rating"),
                      _sellerStat("98%", "Response"),
                      _sellerStat("1.2k", "Products"),
                    ],
                  ),
                  const Divider(height: 40),

                  // সেলার সম্পর্কে তথ্য
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "About Shop",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "This store provides authentic gadgets and electronic items with official warranty. Customer satisfaction is our priority. "
                        "We have been serving quality products for over 5 years in the local market.",
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),

                  // এখানে আপনি আরও অনেক কিছু যোগ করতে পারেন, স্ক্রিন অটো বড় হবে
                ],
              ),
            ),
          ),

          // ৩. ফিক্সড নিচের বাটন (যাতে ইউজার সবসময় বাটনটি দেখতে পায়)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  label: Text(
                    "Back to ${product.name}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 10), // সেফ এরিয়া বা মার্জিন
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _sellerStat(String value, String label) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ],
  );
}

Widget _trustIcon(IconData icon, String text) {
  return Column(
    children: [
      Icon(icon, color: Colors.blueGrey, size: 24),
      const SizedBox(height: 5),
      Text(text, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
    ],
  );
}

Widget _buildLeadingIcon({
  required bool isDrawerOpen,
  required VoidCallback onClose,
  required VoidCallback onMenuTap,
}) {
  return IconButton(
    icon: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isDrawerOpen ? Icons.arrow_back_ios_new : Icons.grid_view_rounded,
        color: AppColors.textDark,
        size: 18,
      ),
    ),
    onPressed: isDrawerOpen ? onClose : onMenuTap,
  );
}
Widget _buildLogoTitle() {
  return ShaderMask(
    shaderCallback: (bounds) => AppColors.logoShader(bounds),
    child: const Text(
      "Profile",
      style: TextStyle(
        fontSize: 22,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    ),
  );
}

Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
  return IconButton(
    icon: Icon(icon, color: AppColors.textDark, size: 26),
    onPressed: onTap,
    splashRadius: 25,
  );
}











/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // প্রোভাইডার ইমপোর্ট
import '../app_color.dart';
import '../cart/cart_controller.dart'; // আপনার CartProvider ক্লাস
import '../models/model.dart';
import '../service/ui_helper.dart';

class ProfileScreen extends StatelessWidget { // StatefulWidget এর আর দরকার নেই

  final VoidCallback onMenuTap;
  final VoidCallback onClose;
  final bool isDrawerOpen;

  const ProfileScreen({
    super.key,
    required this.onMenuTap,
    required this.onClose,
    required this.isDrawerOpen
  });

  @override
  Widget build(BuildContext context) {
    // প্রোভাইডার লিসেনার
    final cart = Provider.of<CartProvider>(context);
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    Map<String, dynamic>? admin;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // ১. এটি বডিকে অ্যাপবারের নিচ থেকে শুরু করতে বাধ্য করবে
      // extendBodyBehindAppBar: true,


      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  leading: _buildLeadingIcon(
                    isDrawerOpen: isDrawerOpen,
                    onClose: onClose,
                    onMenuTap: onMenuTap,
                  ),
                  title: _buildLogoTitle(),
                  actions: [
                    _buildActionIcon(Icons.search_rounded, () {}),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),


      body:  SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ================= PROFILE HEADER =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 58,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage:
                            (admin!["profile_image"] != null &&
                                admin!["profile_image"] != "")
                                ? NetworkImage(admin!["profile_image"])
                                : null,
                            child:
                            (admin!["profile_image"] == null ||
                                admin!["profile_image"] == "")
                                ? Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.primary,
                            )
                                : null,
                          ),
                        ),


                        const SizedBox(height: 16),

                        Text(
                          admin!["fullname"] ?? "Unknown",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: admin!["status"] == "approved"
                                ? Colors.green
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            admin!["status"].toString().toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= DETAILS CARD =================
                  Card(
                    elevation: 8,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _modernInfoRow(
                            Icons.badge,
                            "Admin ID",
                            "#${admin!["id"]}",
                            isMobile,
                          ),
                          _modernInfoRow(
                            Icons.person_outline,
                            "Username",
                            admin!["username"] ?? "N/A",
                            isMobile,
                          ),
                          _modernInfoRow(
                            Icons.email_outlined,
                            "Email",
                            admin!["email"] ?? "N/A",
                            isMobile,
                          ),
                          _modernInfoRow(
                            Icons.phone_outlined,
                            "Phone",
                            admin!["phone"] ?? "N/A",
                            isMobile,
                          ),
                          _modernInfoRow(
                            Icons.smartphone,
                            "Mobile",
                            admin!["mobile"] ?? "N/A",
                            isMobile,
                          ),
                          _modernInfoRow(
                            Icons.calendar_month_outlined,
                            "Date of Birth",
                            admin!["dob"] ?? "N/A",
                            isMobile,
                          ),
                          _modernInfoRow(
                            Icons.history,
                            "Joined At",
                            admin!["created_at"] ?? "N/A",
                            isMobile,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),


    );

  }

  Widget _modernInfoRow(
      IconData icon,
      String label,
      String value,
      bool isMobile,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCartItem(BuildContext context, Product product, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // আরও রাউন্ডেড
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showProductDetails(context, product),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // ১. ইমেজ সেকশন (Soft Background সহ)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    product.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ২. কন্টেন্ট সেকশন
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        // ডিলিট বাটনটি এখন ছোট এবং ক্লিন
                        GestureDetector(
                          onTap: () => cart.removeItem(product),
                          child: Icon(Icons.close_rounded, color: Colors.grey[400], size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Premium Quality", // অথবা সাব-ক্যাটেগরি
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 12),

                    // ৩. প্রাইস এবং কাউন্টার (নিচের অংশ)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "৳${product.price}",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),

                        // প্রফেশনাল কাউন্টার বাটন (এনিমেশন সহ)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              _buildCounterButton(Icons.remove, () {
                                cart.decrementQuantity(product);
                              }),

                              // এনিমেটেড সংখ্যা
                              SizedBox(
                                width: 30,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return ScaleTransition(scale: animation, child: child);
                                  },
                                  child: Text(
                                    '${product.quantity}',
                                    key: ValueKey<int>(product.quantity), // Key জরুরি এনিমেশনের জন্য
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),

                              _buildCounterButton(Icons.add, () {
                                cart.incrementQuantity(product);
                              }, isPrimary: true),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// কাউন্টার বাটনের হেল্পার মেথড
  Widget _buildCounterButton(IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isPrimary ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPriceSummary(CartProvider cart) {
    double deliveryCharge = 50.0;
    double total = cart.totalAmount + deliveryCharge;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)), // আরও মডার্ন কার্ভ
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // কুপন কোড সেকশন (বড় কোম্পানিতে এটি থাকেই)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                const Text("Apply Promo Code", style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // প্রাইজ ডিটেইলস
          _priceRow("Subtotal", "৳ ${cart.totalAmount}"),
          _priceRow("Delivery Charge", "৳ $deliveryCharge"),

          // ড্যাশড ডিভাইডার (এটি দেখতে খুব স্মার্ট লাগে)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: List.generate(30, (index) => Expanded(
                child: Container(
                  color: index % 2 == 0 ? Colors.transparent : Colors.grey[200],
                  height: 1.5,
                ),
              )),
            ),
          ),

          // গ্র্যান্ড টোটাল
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
                child: Text("৳ $total"),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // প্রিমিয়াম চেকআউট বাটন
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // এখানে আপনার চেকআউট লজিক বসবে
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Proceed to Checkout",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          // নিচের সেফ এরিয়া স্পেস
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? Colors.black : Colors.grey[600], fontSize: isTotal ? 18 : 14)),

          // এনিমেটেড প্রাইজ
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isTotal ? 22 : 16,
              color: isTotal ? AppColors.primary : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Your cart is empty!", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // উপরে ড্র্যাগ করার হ্যান্ডেল
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 15),
                  // ১. ইমেজ স্লাইডার (প্রফেশনাল লুক)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          product.imageUrl,
                          height: 350,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 15,
                        right: 15,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ২. নাম এবং রেটিং
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 16,
                            ),
                            Text(
                              " 4.5",
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "124 Reviews",
                        style: TextStyle(
                          color: Colors.grey[600],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "In Stock",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 35),

                  // ৩. দাম সেকশন (৳)
                  Row(
                    children: [
                      Text(
                        "৳ ${product.price}",
                        style: TextStyle(
                          fontSize: 26,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "৳ ${product.price}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          "20% OFF",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ৪. মাল্টি-ভেন্ডার স্পেশাল: সেলার ইনফো (Professional Style)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blueGrey.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.store, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Sold by: Bastob Vendor Ltd.",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "Positive Seller Ratings: 92%",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                // আগের প্রোডাক্ট ডিটেইলস শিটটি বন্ধ করে সেলার শিটটি খুলবে
                                // Navigator.pop(context);
                                _showSellerFullProfile(
                                  context,
                                  product,
                                ); // নতুন এই ফাংশনটি কল হবে
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primary),
                              ),
                              child: const Text(
                                "Visit Store",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ৫. ডেসক্রিপশন
                  const Text(
                    "Product Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "High quality premium material used in this product to ensure durability. Authentic and verified by our QC team.",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ৬. ট্রাস্ট ব্যাজ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _trustIcon(
                        Icons.local_shipping_outlined,
                        "Fast Delivery",
                      ),
                      _trustIcon(Icons.verified_outlined, "100% Original"),
                      _trustIcon(
                        Icons.assignment_return_outlined,
                        "7 Days Return",
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                  // নিচের বাটনের জন্য জায়গা
                ],
              ),
            ),

            // ৭. বটম অ্যাকশন বার (Buy Now & Add to Cart)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // চ্যাট বাটন (মাল্টি ভেন্ডার এর জন্য জরুরি)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_outlined, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // কার্ট বাটন
/*                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      */
                  /*                      onPressed: () {
                        //  কার্টে অ্যাড
                        addToCart(
                          product,
                          onUpdate: () {
                            // এটি হোম স্ক্রিনকে রিফ্রেশ করবে
                            setState(() {});
                          },
                        );
                        //  পপ-আপ বন্ধ করুন
                        Navigator.pop(context);

                        // আগের সব স্নাকবার আগে ক্লিয়ার করুন
                        ScaffoldMessenger.of(context).clearSnackBars();

                        //  স্নাকবারটি
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${product.name} added to cart!"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3), // ৩ সেকেন্ড
                          ),
                        );

                        // ৩. একটি ফোর্স টাইমার  (অ্যান্ড্রয়েডের জন্য)
                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) {
                            // চেক করে নেওয়া হচ্ছে ইউজার ওই স্ক্রিনে আছে কি না
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          }
                        });
                      },*/
                  /*
                      onPressed: () {
                        // প্রোভাইডার কল করা
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).addToCart(product);

                        Navigator.pop(context);
                        UIService.showSuccessSnackBar(
                          context,
                          "${product.name} added to cart!",
                        );
                      },


*/
/*                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),*//*
                    ),
                  ),*/
                  const SizedBox(width: 12),
                  // বাই নাও বাটন
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Buy Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
void _showSellerFullProfile(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    // এটি জরুরি যাতে কিবোর্ড বা বড় কন্টেন্টে ঝামেলা না হয়
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height:
      MediaQuery.of(context).size.height *
          0.80, // উচ্চতা একটু বাড়িয়ে ৮০% করলাম
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // ১. ফিক্সড উপরের অংশ (Drag Handle)
          const SizedBox(height: 15),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // ২. স্ক্রোলযোগ্য মাঝখানের অংশ
          Expanded(
            child: SingleChildScrollView(
              // এটিই আপনার স্ক্রিনকে স্ক্রোলযোগ্য করবে
              physics: const BouncingScrollPhysics(),
              // স্মুথ স্ক্রোলিং এর জন্য
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.store, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Bastob Vendor Ltd.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Member since 2023",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // সেলার স্ট্যাটাস কার্ড
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _sellerStat("4.8/5", "Rating"),
                      _sellerStat("98%", "Response"),
                      _sellerStat("1.2k", "Products"),
                    ],
                  ),
                  const Divider(height: 40),

                  // সেলার সম্পর্কে তথ্য
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "About Shop",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "This store provides authentic gadgets and electronic items with official warranty. Customer satisfaction is our priority. "
                        "We have been serving quality products for over 5 years in the local market.",
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),

                  // এখানে আপনি আরও অনেক কিছু যোগ করতে পারেন, স্ক্রিন অটো বড় হবে
                ],
              ),
            ),
          ),

          // ৩. ফিক্সড নিচের বাটন (যাতে ইউজার সবসময় বাটনটি দেখতে পায়)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  label: Text(
                    "Back to ${product.name}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 10), // সেফ এরিয়া বা মার্জিন
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _sellerStat(String value, String label) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ],
  );
}

Widget _trustIcon(IconData icon, String text) {
  return Column(
    children: [
      Icon(icon, color: Colors.blueGrey, size: 24),
      const SizedBox(height: 5),
      Text(text, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
    ],
  );
}

Widget _buildLeadingIcon({
  required bool isDrawerOpen,
  required VoidCallback onClose,
  required VoidCallback onMenuTap,
}) {
  return IconButton(
    icon: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isDrawerOpen ? Icons.arrow_back_ios_new : Icons.grid_view_rounded,
        color: AppColors.textDark,
        size: 18,
      ),
    ),
    onPressed: isDrawerOpen ? onClose : onMenuTap,
  );
}
Widget _buildLogoTitle() {
  return ShaderMask(
    shaderCallback: (bounds) => AppColors.logoShader(bounds),
    child: const Text(
      "Profile",
      style: TextStyle(
        fontSize: 22,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    ),
  );
}

Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
  return IconButton(
    icon: Icon(icon, color: AppColors.textDark, size: 26),
    onPressed: onTap,
    splashRadius: 25,
  );
}



/*

import 'package:bastob3d/app_color.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';

class AdminProfileScreen extends StatefulWidget {
  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {

  bool _loading = true;
  final ApiService api = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  */
/*  Future<void> _fetchProfileData() async {
    try {
      String? adminId = await api.getSavedAdminId();

      if (adminId != null) {
        final response = await api.getProfileById(adminId);
        if (mounted) {
          setState(() {
            admin = response['admin'];
            _loading = false;
          });
        }
      } else {
        _showError("No login session found.");
        setState(() => _loading = false);
      }
    } catch (e) {
      _showError("Error loading profile");
      setState(() => _loading = false);
    }
  }*//*


  Future<void> _fetchProfileData() async {
    try {
      String? adminId = await api.getSavedAdminId();

      if (adminId == null) {
        if (!mounted) return;
        _showError("No login session found.");
        setState(() => _loading = false);
        return;
      }

      final response = await api.getProfileById(adminId);

      // ✅ SAFE CHECK
      if (response == null || response['admin'] == null) {
        if (!mounted) return;
        _showError("Profile data not found");
        setState(() => _loading = false);
        return;
      }

      if (!mounted) return;
      setState(() {
        admin = response['admin'];
        _loading = false;
      });
    } catch (e) {
      debugPrint("PROFILE ERROR: $e");
      if (!mounted) return;
      _showError("Error loading profile");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (admin == null) {
      return const Scaffold(
        body: Center(child: Text('Admin profile data missing')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Admin Profile"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body:
    );
  }



  void _showError(String msg) {
    final bottomInset = MediaQuery.of(
      context,
    ).viewInsets.bottom; // keyboard height
    final marginBottom = bottomInset > 0 ? bottomInset + 16.0 : 16.0;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: marginBottom, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

*/
*/

