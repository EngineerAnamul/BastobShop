import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../api/api_service.dart';
import '../app_color.dart';
import '../cart/cart_controller.dart';
import '../cart/cart_screen.dart';
import '../main_wrapper.dart';
import '../models/model.dart';
import '../products/products_cart.dart';
import '../products/product_details.dart';
import '../products/search_screen.dart';
import '../products/seller_profile_sheet.dart';
import '../service/ui_helper.dart';
import '../utils/common_shimmer.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onClose;
  final bool isDrawerOpen;
  final VoidCallback onCartTap;

  const HomeScreen({
    super.key,
    required this.onMenuTap,
    required this.isDrawerOpen,
    required this.onClose,
    required this.onCartTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🔹 ভেরিয়েবলটি
  bool _isUserScrolling = false;
  final ScrollController _scrollController = ScrollController();
  List<Product> _allProducts = [];
  int _currentPage = 1;
  bool _isLoading = false;

  // final isLoading = snapshot.connectionState == ConnectionState.waiting;
  bool _hasMore = true;
  bool _isOffline = false;

  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.phone_android, "name": "Electronics"},
    {"icon": Icons.checkroom, "name": "Fashion"},
    {"icon": Icons.chair, "name": "Furniture"},
    {"icon": Icons.fastfood, "name": "Grocery"},
    {"icon": Icons.watch, "name": "Accessories"},
    {"icon": Icons.sports_esports, "name": "Gaming"},
  ];

  /*
  @override
  void initState() {
    super.initState();
    _loadMoreProducts(); // শুরুতে ডাটা লোড

    _mainScrollController.addListener(() {
      // যদি স্ক্রল একদম নিচে চলে আসে (৯০% এর বেশি), তবে নতুন পেজ লোড হবে
      if (_mainScrollController.position.pixels >=
          _mainScrollController.position.maxScrollExtent * 0.9) {
        _loadMoreProducts();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());


  }
*/

  @override
  void initState() {
    super.initState();

    _checkConnectivity();
    _loadMoreProducts();

    // ২. রিয়েল-টাইম ইন্টারনেট মনিটর (List<ConnectivityResult> হ্যান্ডেল করা)
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // যদি লিস্টে .none থাকে, তবে ইউজার অফলাইন
      if (results.contains(ConnectivityResult.none)) {
        if (mounted) setState(() => _isOffline = true);
      } else {
        if (mounted) {
          setState(() {
            _isOffline = false;
            if (_allProducts.isEmpty) _loadMoreProducts();
          });
        }
      }
    });

    _mainScrollController.addListener(() {
      if (_mainScrollController.position.pixels >=
          _mainScrollController.position.maxScrollExtent * 0.9) {
        // অফলাইন না থাকলে এবং বর্তমানে লোড না চললে তবেই কল হবে
        if (!_isOffline && !_isLoading) _loadMoreProducts();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  Future<void> _checkConnectivity() async {
    var results = await (Connectivity().checkConnectivity());
    if (mounted) {
      setState(() {
        _isOffline = results.contains(ConnectivityResult.none);
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      // ১. লিস্ট খালি থাকলে lastId = 0, নাহলে লাস্ট আইটেমের ID নিবে
      int lastId = _allProducts.isEmpty ? 0 : _allProducts.last.id;

      // ২. ApiService এ lastId পাঠিয়ে ডাটা আনা
      final newProducts = await ApiService().fetchProducts(lastId);

      setState(() {
        _isLoading = false;
        if (newProducts.isEmpty) {
          _hasMore = false;
        } else {
          _allProducts.addAll(newProducts);
          // এখানে _currentPage++ এর আর দরকার নেই
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(milliseconds: 30), () {
      if (_scrollController.hasClients && !_isUserScrolling) {
        // 🔹 চেক করবে ইউজার হাত দিয়েছে কি না
        double currentScroll = _scrollController.offset;
        _scrollController.jumpTo(currentScroll + 1);

        if (currentScroll >= _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(0);
        }
      }
      _startAutoScroll(); // লুপ চলতে থাকবে
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // মেমোরি খালি করার জন্য জরুরি
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    // লজিক: স্ক্রিন যত বড় হবে, কার্ডের ম্যাক্সিমাম সাইজও তত বাড়বে
    double dynamicMaxExtent = screenWidth < 600
        ? 180 // ফোনের জন্য ১৮০ পিক্সেল (পারফেক্ট ২ কলাম)
        : (screenWidth < 1100
        ? 220 // ট্যাবলেটের জন্য ২২০ পিক্সেল
        : 260); // ল্যাপটপ বা বড় কম্পিউটারের জন্য ২৬০ পিক্সেল

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      extendBody: true,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), // ইমেজের মতো হাইট
        child: Container(
          padding: const EdgeInsets.only(top: 10), // স্ট্যাটাস বার থেকে গ্যাপ
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 75,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                // ইমেজের মতো রাউন্ডেড কার্ভ
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  // গ্লাস ব্লার ইফেক্ট
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      // ইমেজের মতো ট্রান্সপারেন্ট সাদা
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        // চিকন সাদা বর্ডার (Inner Glow)
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // leading এরর ফিক্স: widget. যোগ করা হয়েছে
                          _buildGlassCircleIcon(
                            widget.isDrawerOpen
                                ? Icons.arrow_back_ios_new
                                : Icons.grid_view_rounded,
                            widget.isDrawerOpen
                                ? widget.onClose
                                : widget.onMenuTap,
                          ),

                          _buildLogoTitle(),

                          Row(
                            children: [
                              _buildGlassCircleIcon(
                                Icons.search_rounded,
                                () {
                                  // সার্চ স্ক্রিনে নিয়ে যাবে
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildGlassCartIcon(widget.onCartTap),
                              // এটি ঠিক আছে কারণ widget. আগেই ছিল
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _mainScrollController,
        slivers: [
          // ২. অ্যাপবারের সমান উচ্চতার একটি ফাঁকা জায়গা রাখা যাতে প্রথম কন্টেন্ট অ্যাপবারের নিচে চাপা না পড়ে
          const SliverToBoxAdapter(
            child: SizedBox(height: 110), // অ্যাপবার + মার্জিন এর সমান হাইট
          ),

          // ১. ব্যানার সেকশন
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
              ),
              child: const Center(
                child: Text(
                  "Big Sale Up To 50%\nShop Now",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // ২. ক্যাটাগরি টাইটেল
          SliverToBoxAdapter(child: sectionTitle("Categories")),
          // _buildTitle(),

          // ৩. ক্যাটাগরি লিস্ট (অটো স্ক্রল সহ)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: Listener(
                onPointerDown: (_) {
                  setState(() {
                    _isUserScrolling = true;
                  });
                },
                onPointerUp: (_) {
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _isUserScrolling = false;
                      });
                    }
                  });
                },
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: 10000,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final category = categories[index % categories.length];
                    return categoryItem(
                      category["icon"] as IconData,
                      category["name"] as String,
                      () => print("${category["name"]} clicked"),
                    );
                  },
                ),
              ),
            ),
          ),

          // ৪. প্রোডাক্ট টাইটেল
          SliverToBoxAdapter(child: sectionTitle("Featured Products")),

          // ৫. ডাইনামিক প্রোডাক্ট গ্রিড
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
              sliver: SliverGrid(
                // এখানে পরিবর্তন করা হয়েছে
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: dynamicMaxExtent, // একটি কার্ড সর্বোচ্চ ১৮০ পিক্সেল চওড়া হবে
                  childAspectRatio: 0.70,  // কার্ডের সাইজ রেশিও
                  crossAxisSpacing: 16,    // পাশাপাশি গ্যাপ
                  mainAxisSpacing: 16,     // ওপর-নিচ গ্যাপ
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(product: _allProducts[index]),
                  childCount: _allProducts.length,
                ),
              ),
            ),
          ),

          /*
          // ৬. লোডিং ইন্ডিকেটর
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
*/

          /*
          // ৫. ডাইনামিক প্রোডাক্ট গ্রিড অথবা শিমার লোডিং
          (_isLoading && _allProducts.isEmpty)
              ? const ProductGridShimmer() // ডাটা আসার আগ পর্যন্ত এটি দেখাবে
              : SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 900
                          ? 4
                          : 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return ProductCard(product: _allProducts[index]);
                    }, childCount: _allProducts.length),
                  ),
                ),
*/
/*
          // ৫. প্রোডাক্ট গ্রিড সেকশন
          _isOffline && _allProducts.isEmpty
              ? _buildOfflineShimmerState() // অফলাইন থাকলে শিমার + নোটিশ
              : (_isLoading && _allProducts.isEmpty)
              ? const ProductGridShimmer() // অনলাইনে লোডিং হলে শিমার
              : SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 900
                          ? 4
                          : 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          ProductCard(product: _allProducts[index]),
                      childCount: _allProducts.length,
                    ),
                  ),
                ),*/

          // ৬. ইনফিনিটি স্ক্রলিং লোডিং (নিচে আরও ডাটা লোড হওয়ার সময়)
          if (_isLoading && _allProducts.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          // ৭. ফ্ল্যাশ সেল, ভেন্ডর এবং ফুটার সেকশন
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitle("Flash Sale"),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Limited Time Offer",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        "02:15:30",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                sectionTitle("Top Vendors"),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      vendorCard("Vendor A"),
                      vendorCard("Vendor B"),
                      vendorCard("Vendor C"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                CommonShimmer(width: 300, height: 100, borderRadius: 12),
                sectionTitle("Why Choose Us"),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.lock, color: Colors.green),
                        title: Text("Secure Payment"),
                      ),
                      ListTile(
                        leading: Icon(Icons.local_shipping, color: Colors.blue),
                        title: Text("Fast Delivery"),
                      ),
                      ListTile(
                        leading: Icon(Icons.refresh, color: Colors.orange),
                        title: Text("Easy Return"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: AppColors.primary,
                  child: const Column(
                    children: [
                      Text(
                        "© 2026 AIH Company",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Secure | Trusted | Fast",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineShimmerState() {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.orange),
                SizedBox(width: 10),
                Text("You are offline."),
              ],
            ),
          ),
        ),
        const ProductGridShimmer(), // আপনার তৈরি করা সেই চমৎকার শিমার
      ],
    );
  }

  //show product details
  /*
  Widget productCard(Product product) {
    return GestureDetector(
      // onTap: () => _showProductDetails(context, product),
      onTap: () => // সেলার প্রোফাইল দেখানোর ম্যাজিক লাইন
      // SellerProfileSheet.show(context, product.vendorId);
      //   ProductDetailsSheet.show(context, myProductObject);
        ProductDetailsSheet.show(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child; // ইমেজ লোড হয়ে গেলে আসল ইমেজ দেখাবে
                      }
                      return // ১. ব্যানারের জন্য শিমার (উপরে রাউন্ডেড ৩০)
                      const CommonShimmer(
                        width: double.infinity,
                        height: 180,
                        borderRadius: 30,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      // এরর হলে আইকন দেখাবে
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // আপনার প্রোডাক্টের নাম এবং দামের অংশ
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "৳ ${product.price}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }*/

  /*
  void _showProductDetails(BuildContext context, Product initialProduct) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FutureBuilder<Product>(
        future: ApiService().fetchProductDetails(initialProduct.id),
        // ডাটাবেস থেকে ভারী ডাটা আনছে
        initialData: initialProduct,
        // হোমের ডাটা সাথে সাথে দেখাবে
        builder: (context, snapshot) {
          // snapshot.data তে এখন ফুল ডিটেইলস আছে (যদি লোড শেষ হয়)
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
                          ? CommonShimmer(
                              width: 80,
                              height: 35,
                              borderRadius: 20,
                            )
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
  /* _showSellerFullProfile(
                                      context,
                                      product.id,
                                    ),*/

  /*

                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: AppColors.primary,
                                      ),
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
      ),
    );
  }
*/

  /*
  Widget productCard(Product product) {
    return GestureDetector(
      onTap: () => _showProductDetails(context, product),
      // 👈 ক্লিক করলে ডিটেইলস দেখাবে
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "৳ ${product.price}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }*/

  /*
  void _showSellerFullProfile(BuildContext context, int vendorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // ১. ড্র্যাগিং এনাবেল করা হলো
      enableDrag: true,
      isDismissible: true,
      builder: (context) => TweenAnimationBuilder(
        duration: const Duration(milliseconds: 400),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: FutureBuilder<Vendor>(
            future: ApiService().fetchVendorDetails(vendorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // শিমারের সময়ও যাতে হ্যান্ডেলবার দেখা যায়
                return Column(
                  children: [
                    _buildHandle(),
                    const CommonShimmer(
                      width: double.infinity,
                      height: 180,
                      borderRadius: 0,
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return _buildErrorState(context, snapshot.error.toString());
              }

              final vendor = snapshot.data!;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    child: CustomScrollView(
                      // ২. AlwaysScrollableScrollPhysics নিশ্চিত করে যাতে লিস্ট ছোট হলেও সোয়াইপ কাজ করে
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        // ৩. হ্যান্ডেলবারটি সবার উপরে রাখা হলো যাতে ইউজার বুঝে এটি নামানো যায়
                        SliverToBoxAdapter(child: _buildHandle()),
                        SliverToBoxAdapter(child: _buildPremiumHeader(vendor)),
                        SliverToBoxAdapter(child: _buildStoreStats(vendor)),
                        SliverToBoxAdapter(child: _buildDynamicAbout(vendor)),
                        SliverPadding(
                          padding: const EdgeInsets.all(15),
                          sliver: _buildTopProductsGrid(vendor.id),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 150)),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildStickyFooter(context, vendor),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
*/

  Widget _buildTopProductsGrid(int vendorId) {
    return FutureBuilder<List<Product>>(
      future: ApiService().fetchVendorProducts(vendorId, limit: 5),
      // ৫টি প্রোডাক্ট রিকোয়েস্ট করুন
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );

        final products = snapshot.data!;
        final bool hasMore = products.length > 4; // যদি ৪ এর বেশি থাকে
        final displayProducts = hasMore ? products.take(4).toList() : products;

        return SliverMainAxisGroup(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Text(
                  "Top Selling Products",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                // (context, index) => productCard(displayProducts[index]),
                (context, index) => ProductCard(product: _allProducts[index]),
                // আপনার আগের তৈরি করা প্রফেশনাল কার্ড
                childCount: displayProducts.length,
              ),
            ),
            if (hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: TextButton(
                    onPressed: () {
                      // এখানে নতুন একটি স্ক্রিনে এই ভেন্ডরের সব প্রোডাক্ট দেখাবেন
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "See More Products",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

//seller full profile

// --- হেল্পার উইজেটস (এগুলো ক্লাসের নিচে যোগ করুন) ---

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

Widget _buildDynamicHeader(Vendor vendor) {
  return Column(
    children: [
      CircleAvatar(radius: 45, backgroundImage: NetworkImage(vendor.logoUrl)),
      const SizedBox(height: 10),
      Text(
        vendor.storeName,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      Text(
        "Member since ${vendor.memberSince}",
        style: const TextStyle(color: Colors.grey),
      ),
    ],
  );
}

Widget _buildDynamicTrustBar(Vendor vendor) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statItem(vendor.rating.toString(), "Rating"),
        _statItem(vendor.responseRate, "Response"),
        _statItem("Verified", vendor.isVerified ? "Yes" : "No"),
      ],
    ),
  );
}

Widget _statItem(String value, String label) {
  return Column(
    children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );
}

Widget _buildDynamicAbout(Vendor vendor) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(vendor.about, textAlign: TextAlign.center),
  );
}

// --- UI COMPONENTS ---

Widget _buildStoreHeader() {
  return Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  "https://cdn-icons-png.flaticon.com/512/606/606543.png",
                ), // Store Logo
              ),
            ),
            const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.blue,
              child: Icon(Icons.verified, size: 16, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "Bastob Electronics",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        Text(
          "Official Flagship Store",
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

Widget _buildTrustBar() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _sellerStat("4.9", "Rating", Icons.star_rounded, Colors.orange),
        _verticalDivider(),
        _sellerStat(
          "99%",
          "Shipping",
          Icons.local_shipping_rounded,
          Colors.green,
        ),
        _verticalDivider(),
        _sellerStat("10m", "Response", Icons.chat_bubble_rounded, Colors.blue),
      ],
    ),
  );
}

Widget _buildAboutSection() {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "About Shop",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Trusted by 50k+ customers. We specialize in bringing the latest 3D-integrated electronic gadgets to your doorstep.",
          style: TextStyle(color: Colors.grey.shade600, height: 1.4),
        ),
      ],
    ),
  );
}

Widget _buildTopProducts() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Top Selling Products",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          itemCount: 4,
          itemBuilder: (context, index) => Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "https://m.media-amazon.com/images/I/71p-f7mS24L._AC_SL1500_.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Smart Watch",
                    maxLines: 1,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildStickyFooter(BuildContext context, Vendor vendor) {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
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
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // চ্যাট লজিক এখানে হবে
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.body,
              minimumSize: const Size(0, 50),
              // আপনার আগের রাউন্ডেড ডিজাইন ঠিক রাখা হয়েছে
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade400),
              padding: EdgeInsets.zero, // আইকনটি একদম মাঝখানে রাখার জন্য
            ),
            child: const Icon(
              Icons.chat_outlined,
              color: Colors.black87, // আইকন কালার
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              // টেক্সট এবং আইকন কালার
              minimumSize: const Size(0, 50),
              elevation: 0,
              // মডার্ন ডিজাইনে শ্যাডো কম রাখা হয়
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // এখানে সঠিক ব্যবহার
              ),
            ),
            child: const Text(
              "Follow Store",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _sellerStat(String value, String label, IconData icon, Color color) {
  return Column(
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
    ],
  );
}

Widget _verticalDivider() =>
    Container(height: 30, width: 1, color: Colors.grey.shade200);

Widget sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

Widget categoryItem(IconData icon, String name, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: 100,
      // 🔹 চারদিকে মার্জিন দিলে আইটেমগুলো আর মিশে থাকবে না এবং শ্যাডো দেখা যাবে
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // 🔹 ভাসমান শ্যাডো ইফেক্ট
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget vendorCard(String name) {
  return Container(
    width: 120,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}

/*Widget _sellerStat(String value, String label) {
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
}*/

Widget _trustIcon(IconData icon, String text) {
  return Column(
    children: [
      Icon(icon, color: Colors.blueGrey, size: 24),
      const SizedBox(height: 5),
      Text(text, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
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

Widget _buildTitle() {
  return ShaderMask(
    shaderCallback: (bounds) => AppColors.logoShader(bounds),
    child: const Text(
      "Categories",
      style: TextStyle(
        fontSize: 22,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    ),
  );
}

// ১. সাধারণ গোল আইকন বাটন
Widget _buildGlassCircleIcon(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // ইমেজের মতো হালকা সাদা
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

// ২. কার্ট আইকন (ইমেজের মতো লাল নোটিফিকেশন ব্যাজ সহ)
Widget _buildGlassCartIcon(VoidCallback onTap) {
  return Consumer<CartProvider>(
    builder: (context, cart, child) {
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (cart.itemCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent, // ইমেজের মতো লাল ব্যাজ
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

Widget _buildPremiumHeader(Vendor vendor) {
  return Column(
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          // ১. ব্যানার ইমেজ ক্লিপিং ফিক্স
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            // মেইন কার্ডের সাথে মিল রাখা হয়েছে
            child: Container(
              height: 230,
              width: double.infinity,
              child: Image.network(
                vendor.bannerUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.blueGrey[100],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
          ),

          // ২. গোল লোগো (Overlapping)
          Positioned(
            bottom: -40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(vendor.logoUrl),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 50), // লোগোর জন্য গ্যাপ
    ],
  );
}

Widget _buildStoreStats(Vendor vendor) {
  return Container(
    // margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem("Rating", "${vendor.rating}", Icons.star, Colors.orange),
        _buildStatItem(
          "Followers",
          "${vendor.followers}",
          Icons.people,
          Colors.blue,
        ),
        _buildStatItem(
          "Response",
          vendor.responseRate,
          Icons.chat,
          Colors.green,
        ),
      ],
    ),
  );
}

Widget _buildStatItem(String label, String value, IconData icon, Color color) {
  return Column(
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 5),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
    ],
  );
}

Widget _buildErrorState(BuildContext context, String error) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ১. আইকনিক ইলাস্ট্রেশন বা অ্যানিমেশন
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront_outlined,
              size: 80,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 25),

          // ২. ইউজার ফ্রেন্ডলি মেসেজ
          const Text(
            "Oops! Store is taking a nap",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff2D3436),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Our servers are a bit busy handling millions of shoppers. Please give it another shot!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),

          // ৩. রিট্রাই বাটন (স্মুথ এনিমেশন সহ)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                // এটি কল করলে ফিউচার বিল্ডার আবার ডেটা লোড করার চেষ্টা করবে
                (context as Element).markNeedsBuild();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Try Reconnecting"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),

          // ৪. কারিগরি এরর ডিটেইলস (ডেভেলপারের জন্য ছোট করে রাখা)
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              // এখানে এরর ডিটেইলস পপআপে দেখানো যেতে পারে
            },
            child: Text(
              "Error Code: $error",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
            ),
          ),
        ],
      ),
    ),
  );
}

//show product details
/*
  Widget productCard(Product product) {
    return GestureDetector(
      // onTap: () => _showProductDetails(context, product),
      onTap: () => // সেলার প্রোফাইল দেখানোর ম্যাজিক লাইন
      // SellerProfileSheet.show(context, product.vendorId);
      //   ProductDetailsSheet.show(context, myProductObject);
        ProductDetailsSheet.show(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child; // ইমেজ লোড হয়ে গেলে আসল ইমেজ দেখাবে
                      }
                      return // ১. ব্যানারের জন্য শিমার (উপরে রাউন্ডেড ৩০)
                      const CommonShimmer(
                        width: double.infinity,
                        height: 180,
                        borderRadius: 30,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      // এরর হলে আইকন দেখাবে
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // আপনার প্রোডাক্টের নাম এবং দামের অংশ
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "৳ ${product.price}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }*/

/*
  void _showProductDetails(BuildContext context, Product initialProduct) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FutureBuilder<Product>(
        future: ApiService().fetchProductDetails(initialProduct.id),
        // ডাটাবেস থেকে ভারী ডাটা আনছে
        initialData: initialProduct,
        // হোমের ডাটা সাথে সাথে দেখাবে
        builder: (context, snapshot) {
          // snapshot.data তে এখন ফুল ডিটেইলস আছে (যদি লোড শেষ হয়)
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
                          ? CommonShimmer(
                              width: 80,
                              height: 35,
                              borderRadius: 20,
                            )
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
/* _showSellerFullProfile(
                                      context,
                                      product.id,
                                    ),*/

/*

                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: AppColors.primary,
                                      ),
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
      ),
    );
  }
*/

/*
  Widget productCard(Product product) {
    return GestureDetector(
      onTap: () => _showProductDetails(context, product),
      // 👈 ক্লিক করলে ডিটেইলস দেখাবে
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "৳ ${product.price}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }*/

/*
  void _showSellerFullProfile(BuildContext context, int vendorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // ১. ড্র্যাগিং এনাবেল করা হলো
      enableDrag: true,
      isDismissible: true,
      builder: (context) => TweenAnimationBuilder(
        duration: const Duration(milliseconds: 400),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: FutureBuilder<Vendor>(
            future: ApiService().fetchVendorDetails(vendorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // শিমারের সময়ও যাতে হ্যান্ডেলবার দেখা যায়
                return Column(
                  children: [
                    _buildHandle(),
                    const CommonShimmer(
                      width: double.infinity,
                      height: 180,
                      borderRadius: 0,
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return _buildErrorState(context, snapshot.error.toString());
              }

              final vendor = snapshot.data!;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    child: CustomScrollView(
                      // ২. AlwaysScrollableScrollPhysics নিশ্চিত করে যাতে লিস্ট ছোট হলেও সোয়াইপ কাজ করে
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        // ৩. হ্যান্ডেলবারটি সবার উপরে রাখা হলো যাতে ইউজার বুঝে এটি নামানো যায়
                        SliverToBoxAdapter(child: _buildHandle()),
                        SliverToBoxAdapter(child: _buildPremiumHeader(vendor)),
                        SliverToBoxAdapter(child: _buildStoreStats(vendor)),
                        SliverToBoxAdapter(child: _buildDynamicAbout(vendor)),
                        SliverPadding(
                          padding: const EdgeInsets.all(15),
                          sliver: _buildTopProductsGrid(vendor.id),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 150)),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildStickyFooter(context, vendor),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
*/
