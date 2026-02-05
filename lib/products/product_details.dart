import 'package:bastoopshop/products/seller_profile_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_service.dart';
import '../app_color.dart';
import '../cart/cart_controller.dart';
import '../models/model.dart';
import '../service/ui_helper.dart';
import '../utils/common_shimmer.dart';

class ProductDetailsSheet {
  static void show(BuildContext context, Product initialProduct) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailsContent(initialProduct: initialProduct),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  final Product initialProduct;

  const _DetailsContent({required this.initialProduct});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
      future: ApiService().fetchProductDetails(initialProduct.id),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final product = snapshot.data ?? initialProduct;

        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              _buildHandle(), // উপরে ড্র্যাগ হ্যান্ডেল

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 15),

                    // ১. ইমেজ সেকশন (ইমেজ লোড হওয়ার সময় শিমার)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: isLoading
                              ? const CommonShimmer(
                                  width: double.infinity,
                                  height: 350,
                                  borderRadius: 20,
                                )
                              : Image.network(
                                  product.imageUrl,
                                  height: 350,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        if (!isLoading)
                          Positioned(
                            top: 15,
                            right: 15,
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.8),
                              child: const Icon(
                                Icons.favorite_border,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ২. নাম (শিমার যখন লোড হচ্ছে)
                    isLoading
                        ? const CommonShimmer(
                            width: 250,
                            height: 28,
                            borderRadius: 5,
                          )
                        : Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                    const SizedBox(height: 12),

                    // ৩. রেটিং এবং স্টোক স্ট্যাটাস (শিমার)
                    Row(
                      children: [
                        isLoading
                            ? const CommonShimmer(
                                width: 60,
                                height: 20,
                                borderRadius: 5,
                              )
                            : _buildRatingBadge(
                                product.avgRating?.toString() ?? "0.0",
                              ),
                        const SizedBox(width: 10),
                        isLoading
                            ? const CommonShimmer(
                                width: 100,
                                height: 20,
                                borderRadius: 5,
                              )
                            : Text(
                                "${product.reviewsCount ?? '0'} Reviews",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                        const Spacer(),
                        isLoading
                            ? const CommonShimmer(
                                width: 80,
                                height: 20,
                                borderRadius: 5,
                              )
                            : _buildStockStatus(product.stockCount),
                      ],
                    ),

                    const Divider(height: 40),

                    // ৪. দাম সেকশন (শিমার)
                    isLoading
                        ? const CommonShimmer(
                            width: 150,
                            height: 35,
                            borderRadius: 5,
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "৳ ${product.discountPrice}",
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.blue,
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
                            ],
                          ),

                    const SizedBox(height: 25),

                    // ৫. সেলার কার্ড (শিমার)
                    isLoading
                        ? const CommonShimmer(
                            width: double.infinity,
                            height: 80,
                            borderRadius: 15,
                          )
                        : _buildSellerCard(context, product),

                    const SizedBox(height: 25),

                    // ৬. ডেসক্রিপশন (মাল্টি-লাইন শিমার)
                    const Text(
                      "Product Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    isLoading
                        ? Column(
                            children: List.generate(
                              3,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: CommonShimmer(
                                  width: double.infinity,
                                  height: 12,
                                  borderRadius: 5,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            product.description ?? "No description available.",
                            style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
/*

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
*/




                  // ৬. ট্রাস্ট ব্যাজ সেকশন (রেসপন্সিভ ও শিমার যুক্ত)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: isLoading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        3,
                            (index) => Column(
                          children: [
                            CommonShimmer.circular(width: 45, height: 45), // আইকনের জন্য গোল শিমার
                            const SizedBox(height: 10),
                            CommonShimmer(width: 60, height: 10, borderRadius: 4), // টেক্সটের জন্য শিমার
                          ],
                        ),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _trustIcon(Icons.local_shipping_rounded, "Fast Delivery"),
                        _trustIcon(Icons.verified_user_rounded, "100% Original"),
                        _trustIcon(Icons.assignment_return_rounded, "7 Days Return"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),

                  ],
                ),
              ),

              // ৭. ফিক্সড বটম বাটন (লোডিং হলেও এটি দেখাবে কিন্তু ডিজেবল থাকবে)
              _buildBottomActions(context, product, isLoading),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- ছোট ছোট উইজেট ফাংশনগুলো নিচে ---

  Widget _buildRatingBadge(String? rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.orange, size: 14),
          Text(
            " ${rating ?? '4.5'}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatus(String? stock) {
    bool inStock = stock != null && int.parse(stock) > 0;
    return Text(
      inStock ? "In Stock" : "Out of Stock",
      style: TextStyle(
        color: inStock ? Colors.green : Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.store, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Sold by: ${product.vendorName ?? 'BastobShop'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              SellerProfileSheet.show(context, product.id);
            },
            child: const Text("Visit Store"),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    Product product,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
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
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: isLoading ? null : () => Navigator.pop(context),
              // লোডিং অবস্থায় অফ
              child: const Text(
                "Add to Cart",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: isLoading ? null : () {},
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
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
//
// Widget _trustIcon(IconData icon, String text) {
//   return Column(
//     children: [
//       Icon(icon, color: Colors.blueGrey, size: 24),
//       const SizedBox(height: 5),
//       Text(
//         text,
//         style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
//       ),
//     ],
//   );
// }


// --- রেসপন্সিভ ট্রাস্ট আইকন উইজেট ---
Widget _trustIcon(IconData icon, String text) {
  return Builder(
    builder: (context) {
      // স্ক্রিন উইডথ অনুযায়ী আইকন ও ফন্ট সাইজ অ্যাডজাস্ট
      double screenWidth = MediaQuery.of(context).size.width;
      double iconSize = (screenWidth * 0.06).clamp(20.0, 26.0);
      double fontSize = (screenWidth * 0.03).clamp(10.0, 12.0);

      return Container(
        constraints: BoxConstraints(maxWidth: screenWidth / 3.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.05), // হালকা ব্যাকগ্রাউন্ড প্রিমিয়াম লুক দেয়
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.blueGrey[800], size: iconSize),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2, // লম্বা টেক্সট হলে ২ লাইনে যাবে কিন্তু ডিজাইন ভাঙবে না
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[600],
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      );
    },
  );
}
/*
import 'package:bastoopshop/products/seller_profile_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_service.dart';
import '../app_color.dart';
import '../cart/cart_controller.dart';
import '../models/model.dart';
import '../service/ui_helper.dart';
import '../utils/common_shimmer.dart';

class ProductDetailsSheet {
  static void show(BuildContext context, Product initialProduct) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailsContent(initialProduct: initialProduct),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  final Product initialProduct;

  const _DetailsContent({required this.initialProduct});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
      future: ApiService().fetchProductDetails(initialProduct.id),
      initialData: initialProduct,
      builder: (context, snapshot) {
        final product = snapshot.data ?? initialProduct;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
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
                    // ১. ইমেজ স্লাইডার (সবচেয়ে ফাস্ট লোডিং)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            product.imageUrl,
                            height: 350,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            // হাই-স্কেল ইউজারদের জন্য ক্যাশিং ইমেজ ব্যবহার জরুরি
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

                    // ২. নাম এবং রেটিং (ডাইনামিক)
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
                        isLoading
                            ? CommonShimmer(
                                width: 80,
                                height: 35,
                                borderRadius: 30,
                              )
                            : Container(
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
                                      " ${product.avgRating ?? '4.5'}",
                                      // এপিআই থেকে আসা রেটিং
                                      style: TextStyle(
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(width: 10),
                        isLoading
                            ? CommonShimmer(
                                width: 80,
                                height: 30,
                                borderRadius: 20,
                              )
                            : Text(
                                "${product.reviewsCount ?? '0'} Reviews",
                                // ডাইনামিক রিভিউ
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                        const Spacer(),
                        isLoading
                            ? CommonShimmer(
                                width: 80,
                                height: 30,
                                borderRadius: 40,
                              )
                            : Text(
                                (product.stockCount != null &&
                                        int.parse(product.stockCount!) > 0)
                                    ? "In Stock"
                                    : "Out of Stock",
                                style: TextStyle(
                                  color:
                                      (product.stockCount != null &&
                                          int.parse(product.stockCount!) > 0)
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ],
                    ),

                    const Divider(height: 35),

                    // ৩. দাম সেকশন (৳)
                    isLoading
                        ? CommonShimmer(width: 80, height: 35, borderRadius: 20)
                        : Row(
                            children: [
                              Text(
                                "৳ ${product.discountPrice}",
                                style: TextStyle(
                                  fontSize: 26,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (product.discountPrice != null)
                                Text(
                                  "৳ ${product.price}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              const SizedBox(width: 10),
                              if (product.discountPrice != null)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    "OFFER",
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

                    //
                    // // ৪. মাল্টি-ভেন্ডার স্পেশাল: সেলার ইনফো (Lazy Loaded)
                    // isLoading
                    //     ? Shimmer.fromColors(
                    //         // ডাটা আসার আগ পর্যন্ত শিমার দেখাবে
                    //         baseColor: Colors.grey[300]!,
                    //         highlightColor: Colors.grey[100]!,
                    //         child: Container(height: 80, color: Colors.white),
                    //       )
                    //     :
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blueGrey.shade100),
                      ),
                      child: Row(
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
                                isLoading
                                    ? CommonShimmer(
                                        width: 100,
                                        height: 30,
                                        borderRadius: 20,
                                      )
                                    : Text(
                                        "Sold by: ${product.vendorName ?? 'Bastob Shop'}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                isLoading
                                    ? CommonShimmer(
                                        width: 80,
                                        height: 25,
                                        borderRadius: 20,
                                      )
                                    : Text(
                                        "Seller Ratings: ${product.sellerRating ?? '0'}%",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          isLoading
                              ? CommonShimmer(
                                  width: 60,
                                  height: 40,
                                  borderRadius: 15,
                                )
                              : OutlinedButton(
                                  // এখানে product এর বদলে product.vendorId (বা আপনার মডেলে থাকা আইডি) দিন
                                  onPressed: () =>
                                      // সেলার প্রোফাইল দেখানোর ম্যাজিক লাইন
                                      SellerProfileSheet.show(
                                        context,
                                        product.id,
                                      ),

                                  */
/*                                _showSellerFullProfile(
                              context,
                              product.id,
                            ),*/ /*

                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.primary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ), // আগের শেপ এরর ফিক্স
                                  ),
                                  child: const Text(
                                    "Visit Store",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ৫. ডেসক্রিপশন (ডাইনামিক)
                    const Text(
                      "Product Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    isLoading
                        ? const LinearProgressIndicator()
                        : Text(
                            product.description ??
                                "No description available for this product.",
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
                  ],
                ),
              ),

              // ৭. বটম অ্যাকশন বার (সবসময় ফিক্সড এবং এক্টিভ)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
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
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.chat_outlined,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
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
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
        );
      },
    );
  }

  // এখানে আপনার আগের তৈরি করা সব ছোট ছোট উইজেট ফাংশন (_buildImage, _buildPrice ইত্যাদি)
  // এই ক্লাসের ভেতরে থাকবে। কোড ছোট করার জন্য আমি শুধু স্ট্রাকচার দেখালাম।
  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _trustIcon(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey, size: 24),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildLogoTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.logoShader(bounds),
      child: const Text(
        "BastobShop",
        style: TextStyle(
          fontSize: 22,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
*/
