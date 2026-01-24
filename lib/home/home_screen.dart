import 'package:flutter/material.dart';
import 'package:bastoopshop/app_color.dart';

import '../api/api_service.dart';
import '../cart/cart_controller.dart';
import '../models/product_model.dart';
import '../utils/custom_cursor.dart';

enum DrawerItems { home, profile, orders, settings, logout }

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;
  DrawerItems selectedItem = DrawerItems.home;

  // ড্রয়ার খোলার ফাংশন
  void openDrawer() {
    setState(() {
      xOffset = 230;
      yOffset = 150;
      scaleFactor = 0.6;
      isDrawerOpen = true;
    });
  }

  // ড্রয়ার বন্ধ করার ফাংশন
  void closeDrawer() {
    setState(() {
      xOffset = 0;
      yOffset = 0;
      scaleFactor = 1;
      isDrawerOpen = false;
    });
  }

  // মাউস নড়ালে পজিশন আপডেট হবে
  double mouseX = 0;
  double mouseY = 0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // cursor: SystemMouseCursors.none,

      // মাউস নড়ালে পজিশন আপডেট হবে
      onHover: (event) {
        setState(() {
          mouseX = event.localPosition.dx;
          mouseY = event.localPosition.dy;
        });
      },

      child: Scaffold(
        backgroundColor: const Color(0xFF1B1B2F),
        body: GestureDetector(
          // 🔹 সোয়াইপ লজিক এখানে যোগ করা হয়েছে
          onHorizontalDragUpdate: (details) {
            // বাম থেকে ডানে সোয়াইপ করলে ড্রয়ার খুলবে
            if (details.delta.dx > 6 && !isDrawerOpen) {
              openDrawer();
            }
            // ডান থেকে বামে সোয়াইপ করলে ড্রয়ার বন্ধ হবে
            if (details.delta.dx < -6 && isDrawerOpen) {
              closeDrawer();
            }
          },

          child: Stack(
            children: [
              //  ড্রয়ার পেজ
              buildDrawer(),

              // অ্যানিমেটেড হোম স্ক্রিন
              AnimatedContainer(
                transform: Matrix4.translationValues(xOffset, yOffset, 0)
                  ..scale(scaleFactor)
                  ..rotateY(isDrawerOpen ? -0.5 : 0),
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0.0),
                  boxShadow: [
                    if (isDrawerOpen)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        isDrawerOpen ? 40 : 0.0,
                      ),
                      child: HomeScreen(
                        onMenuTap: () {
                          setState(() {
                            xOffset = 230;
                            yOffset = 150;
                            scaleFactor = 0.6;
                            isDrawerOpen = true;
                          });
                        },
                        isDrawerOpen: isDrawerOpen,
                        onClose: () {
                          setState(() {
                            xOffset = 0;
                            yOffset = 0;
                            scaleFactor = 1;
                            isDrawerOpen = false;
                          });
                        },
                      ),
                    ),

                    // 🔹 এই অংশটি ড্রয়ার খোলা থাকলে হোম স্ক্রিনকে লক করে দেবে
                    if (isDrawerOpen)
                      GestureDetector(
                        onTap: closeDrawer, // ক্লিক করলেই ড্রয়ার বন্ধ হবে
                        child: Container(
                          color: Colors.transparent, // স্বচ্ছ লেয়ার
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                  ],
                ),
              ),

              // কার্সার ফাইল থেকে কল করা হচ্ছে
              CustomCursor(x: mouseX, y: mouseY),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDrawer() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF1B1B2F)),
            ),
            const SizedBox(height: 15),
            const Text(
              "User Name",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "user@email.com",
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 40),
            drawerTile(Icons.home, "Home", DrawerItems.home),
            drawerTile(Icons.person, "Profile", DrawerItems.profile),
            drawerTile(Icons.shopping_bag, "Orders", DrawerItems.orders),
            drawerTile(Icons.settings, "Settings", DrawerItems.settings),

            // const Spacer(),
            Spacer(),
            drawerTile(Icons.logout, "Logout", DrawerItems.logout),
          ],
        ),
      ),
    );
  }

  Widget drawerTile(IconData icon, String title, DrawerItems item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItem = item;
          xOffset = 0;
          yOffset = 0;
          scaleFactor = 1;
          isDrawerOpen = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: selectedItem == item ? Colors.blue : Colors.white,
              size: 28,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: selectedItem == item ? Colors.blue : Colors.white,
                fontSize: 16,
                fontWeight: selectedItem == item
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onClose;
  final bool isDrawerOpen;

  const HomeScreen({
    super.key,
    required this.onMenuTap,
    required this.isDrawerOpen,
    required this.onClose,
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
  bool _hasMore = true;

  final ScrollController _mainScrollController =
      ScrollController(); // মেইন স্ক্রল
  final ScrollController _categoryScrollController =
      ScrollController(); // ক্যাটাগরি স্ক্রল

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.phone_android, "name": "Electronics"},
    {"icon": Icons.checkroom, "name": "Fashion"},
    {"icon": Icons.chair, "name": "Furniture"},
    {"icon": Icons.fastfood, "name": "Grocery"},
    {"icon": Icons.watch, "name": "Accessories"},
    {"icon": Icons.sports_esports, "name": "Gaming"},
  ];


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

  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      // ApiService এ পেজ নম্বর পাঠিয়ে ডাটা আনা
      final newProducts = await ApiService().fetchProducts(_currentPage);

      setState(() {
        _isLoading = false;
        if (newProducts.isEmpty) {
          _hasMore = false; // আর কোনো ডাটা নেই
        } else {
          _allProducts.addAll(
            newProducts,
          ); // আগের লিস্টের সাথে নতুনগুলো যোগ করা
          _currentPage++; // পরের পেজের জন্য রেডি
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // 🔹 অটো স্ক্রল লজিক
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
                          color: AppColor.primary,
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
                                side: BorderSide(color: AppColor.primary),
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
                        //  কার্টে অ্যাড
                        addToCart(product);
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
                  // বাই নাও বাটন
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
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

  // ট্রাস্ট আইকন উইজেট
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            widget.isDrawerOpen ? Icons.arrow_back_ios : Icons.menu,
            color: Colors.black,
          ),
          onPressed: widget.isDrawerOpen ? widget.onClose : widget.onMenuTap,
        ),
        title: const Text(
          "BastobShop",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      /*      body: CustomScrollView(
        controller: _mainScrollController,
        slivers: [
              // 🔹 HERO / BANNER SECTION
*/
      /*
              Container(
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
*/
      /*



          // ১. ব্যানার সেকশন (SliverToBoxAdapter ব্যবহার করতে হবে)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
              ),
              child: const Center(
                child: Text(
                  "Big Sale Up To 50%\nShop Now",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),




          // ২. ক্যাটাগরি সেকশন
          SliverToBoxAdapter(child: sectionTitle("Categories")),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: Listener(
                onPointerDown: (_) => setState(() => _isUserScrolling = true),
                onPointerUp: (_) => Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) setState(() => _isUserScrolling = false);
                }),
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



          // ৩. প্রোডাক্ট সেকশন টাইটেল
          SliverToBoxAdapter(child: sectionTitle("Featured Products")),

          // ৪. ডাইনামিক প্রোডাক্ট গ্রিড (Infinite Scroll এর জন্য)
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => productCard(_allProducts[index]),
                childCount: _allProducts.length,
              ),
            ),
          ),

          // ৫. লোডিং ইন্ডিকেটর (নিচে ডাটা লোড হওয়ার সময় দেখাবে)
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          // ৬. বাকি সব সেকশন (Flash Sale, Vendors, Footer)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitle("Flash Sale"),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Limited Time Offer", style: TextStyle(color: Colors.white, fontSize: 16)),
                      Text("02:15:30", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                sectionTitle("Top Vendors"),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [vendorCard("Vendor A"), vendorCard("Vendor B"), vendorCard("Vendor C")],
                  ),
                ),
                sectionTitle("Why Choose Us"),
                const ListTile(leading: Icon(Icons.lock, color: Colors.green), title: Text("Secure Payment")),
                const ListTile(leading: Icon(Icons.local_shipping, color: Colors.blue), title: Text("Fast Delivery")),
                const ListTile(leading: Icon(Icons.refresh, color: Colors.orange), title: Text("Easy Return")),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: AppColor.primary,
                  child: const Column(
                    children: [
                      Text("© 2026 AIH Company", style: TextStyle(color: Colors.white)),
                      SizedBox(height: 8),
                      Text("Secure | Trusted | Fast", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),



              // 🔹 CATEGORY SECTION
*/
      /*
              sectionTitle("Categories"),

              SizedBox(
                height: 120,
                child: Listener(
                  onPointerDown: (_) {
                    setState(() {
                      _isUserScrolling = true; // হাত দিলেই সাথে সাথে বন্ধ
                    });
                  },
                  onPointerUp: (_) {
                    // 🔹 হাত সরানোর ৩ সেকেন্ড পর আবার শুরু হবে
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        // স্ক্রিন থেকে বেরিয়ে গেলে যেন এরর না দেয়
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
*/
      /*

              // 🔹 FEATURED PRODUCTS
              sectionTitle("Featured Products"),

              SliverPadding(
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
                    return productCard(_allProducts[index]);
                  }, childCount: _allProducts.length),
                ),
              ),

              // ৫. লোডিং ইনডিকেটর
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),

              */
      /*            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                // 🔹 স্ক্রিনের সাইজ অনুযায়ী কলাম সংখ্যা ঠিক করা
                crossAxisCount: MediaQuery.of(context).size.width > 1400
                    ? 7
                    : MediaQuery.of(context).size.width > 1300
                    ? 6
                    : MediaQuery.of(context).size.width > 1100
                    ? 5
                    : MediaQuery.of(context).size.width > 900
                    ? 4 // কম্পিউটারে ৪টি কার্ড
                    : MediaQuery.of(context).size.width > 750
                    ? 4
                    : MediaQuery.of(context).size.width > 600
                    ? 3 // ট্যাবলেটে ৩টি কার্ড
                    : 2, // মোবাইলে ২টি কার্ড
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 8,
              // টেস্ট করার জন্য আইটেম বাড়িয়ে দিন
              itemBuilder: (context, index) {
                return productCard();
              },
            ),*/
      /*

              */
      /*
              FutureBuilder<List<Product>>(
                future: ApiService().fetchProducts(), // API কল করা হচ্ছে
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Something is wrong"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No Products Found"));
                  }

                  // ডাটা চলে আসলে GridView দেখাবে
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      // 🔹 আপনার রেসপনসিভ লজিক এখানে যুক্ত করা হয়েছে
                      crossAxisCount: MediaQuery.of(context).size.width > 1400
                          ? 7
                          : MediaQuery.of(context).size.width > 1300
                          ? 6
                          : MediaQuery.of(context).size.width > 1100
                          ? 5
                          : MediaQuery.of(context).size.width > 900
                          ? 4 // কম্পিউটারে ৪টি কার্ড
                          : MediaQuery.of(context).size.width > 750
                          ? 4
                          : MediaQuery.of(context).size.width > 600
                          ? 3 // ট্যাবলেটে ৩টি কার্ড
                          : 2, // মোবাইলে ২টি কার্ড
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final product = snapshot.data![index];
                      return productCard(product); // 🔹 ডাইনামিক প্রোডাক্ট ডাটা পাঠানো হচ্ছে
                    },
                  );
                },
              ),
*/
      /*

              // HomeScreen এর GridView এর জায়গায় এটি ব্যবহার করুন
              */
      /*
            FutureBuilder<List<Product>>(
              future: ApiService().fetchProducts(), // API কল করা হচ্ছে
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // return Center(child: Text("Error: ${snapshot.error}"));
                  return Center(child: Text("Something is wrong "));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Products Found"));
                }

                // ডাটা চলে আসলে GridView দেখাবে
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // আপনার রেসপনসিভ লজিক এখানে রাখতে পারেন
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final product = snapshot.data![index];
                    return productCard(product); // আপনার প্রোডাক্ট কার্ড উইজেট
                  },
                );
              },
            ),
*/
      /*

              // 🔹 FLASH SALE
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

              // 🔹 TOP VENDORS
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

              // 🔹 WHY CHOOSE US
              sectionTitle("Why Choose Us"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: const [
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

              // 🔹 FOOTER
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: AppColor.primary,
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
      ),*/
      body: CustomScrollView(
        controller: _mainScrollController,
        slivers: [
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
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return productCard(_allProducts[index]);
              }, childCount: _allProducts.length),
            ),
          ),

          // ৬. লোডিং ইন্ডিকেটর
          if (_isLoading)
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
                  color: AppColor.primary,
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

  // --- Reusable Widgets (HomeScreen এর ভেতরে) ---
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

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
  }
}

// --- Reusable Widgets (HomeScreen এর ভেতরে থাকতে হবে) ---
Widget sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

// সেলার সেকশন উইজেট

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
                    backgroundColor: AppColor.primary,
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

// ছোট স্ট্যাট উইজেট
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

// ছোট ট্যাগ উইজেট
Widget _sellerInfoTag(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 14, color: Colors.grey[700]),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
    ],
  );
}
