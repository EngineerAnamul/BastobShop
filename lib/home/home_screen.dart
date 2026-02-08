import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_service.dart';
import '../app_color.dart';
import '../cart/cart_controller.dart';
import '../models/model.dart';
import '../products/products_cart.dart';
import '../products/search_screen.dart';
import '../utils/common_shimmer.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onClose;
  final bool isDrawerOpen;
  final VoidCallback onCartTap;
  final VoidCallback onSearchTap;

  const HomeScreen({
    super.key,
    required this.onMenuTap,
    required this.isDrawerOpen,
    required this.onClose,
    required this.onCartTap,
    required this.onSearchTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🔹 ভেরিয়েবলটি
  bool _isUserScrolling = false;
  final ScrollController _scrollController = ScrollController();
  final List<Product> _allProducts = [];
  final int _currentPage = 1;
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
        ? 200 // ফোনের জন্য ১৮০ পিক্সেল (পারফেক্ট ২ কলাম)
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

                          // Row(
                          //   children: [
                          //     _buildGlassCircleIcon(Icons.search_rounded, () {
                          //       // সার্চ স্ক্রিনে নিয়ে যাবে
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => const SearchScreen(),
                          //         ),
                          //       );
                          //     }),
                          //     const SizedBox(width: 8),
                          //     _buildGlassCartIcon(widget.onCartTap),
                          //     // এটি ঠিক আছে কারণ widget. আগেই ছিল
                          //   ],
                          // ),
                          Row(
                            children: [
                              _buildGlassCircleIcon(Icons.search_rounded, () {
                                // Navigator.push সরিয়ে দিয়ে নিচের লাইনটি লিখুন
                                widget.onSearchTap();
                              }),
                              const SizedBox(width: 8),
                              _buildGlassCartIcon(widget.onCartTap),
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
            padding: const EdgeInsets.all(0),
            sliver: SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
              sliver: SliverGrid(
                // এখানে পরিবর্তন করা হয়েছে
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent:
                      dynamicMaxExtent, // একটি কার্ড সর্বোচ্চ ১৮০ পিক্সেল চওড়া হবে
                  childAspectRatio: 0.70, // কার্ডের সাইজ রেশিও
                  crossAxisSpacing: 6, // পাশাপাশি গ্যাপ
                  mainAxisSpacing: 6, // ওপর-নিচ গ্যাপ
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(product: _allProducts[index]),
                  childCount: _allProducts.length,
                ),
              ),
            ),
          ),

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

  Widget _buildTopProductsGrid(int vendorId) {
    return FutureBuilder<List<Product>>(
      future: ApiService().fetchVendorProducts(vendorId, limit: 5),
      // ৫টি প্রোডাক্ট রিকোয়েস্ট করুন
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

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
            child: SizedBox(
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
