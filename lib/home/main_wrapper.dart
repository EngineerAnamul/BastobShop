import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_color.dart';
import 'home_screen.dart';

class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            isDrawerOpen ? Icons.arrow_back_ios : Icons.menu,
            color: Colors.black,
          ),
          onPressed: isDrawerOpen ? onClose : onMenuTap,
        ),
        title: const Text(
          "BastoobShop",
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 HERO / BANNER SECTION
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

            // 🔹 CATEGORY SECTION
            sectionTitle("Categories"),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // categoryItem(Icons.phone_android, "Electronics", ),

/*
                  categoryItem(Icons.checkroom, "Fashion"),
                  categoryItem(Icons.chair, "Furniture"),
                  categoryItem(Icons.fastfood, "Grocery"),
                  categoryItem(Icons.watch, "Accessories"),*/

                  // categoryItem(আইকন, নাম, ফাংশন)
                  categoryItem(Icons.phone_android, "Electronics", () {
                    print("Electronics Clicked");
                  }),

                  categoryItem(Icons.phone_android, "Electronics", () {
/*                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ElectronicsPage()), // আপনার তৈরি করা পেজ
                    );*/

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Electronics Category Loading...")),
                    );

                  }),
                  categoryItem(Icons.checkroom, "Fashion", () {
                    print("Fashion Clicked");
                  }),

                  categoryItem(Icons.chair, "Furniture", () {
                    print("Furniture Clicked");
                  }),

                  categoryItem(Icons.fastfood, "Grocery", () {
                    print("Grocery Clicked");
                  }),

                  categoryItem(Icons.watch, "Accessories", () {
                    print("Accessories Clicked");
                  }),

                ],
              ),
            ),

            // 🔹 FEATURED PRODUCTS
            sectionTitle("Featured Products"),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return productCard();
              },
            ),

            // 🔹 FLASH SALE
            sectionTitle("Flash Sal"),
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
                    "© 2026 BastoobShop",
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
    );
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

/*  Widget categoryItem(IconData icon, String name) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }*/

  Widget productCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Center(child: Icon(Icons.image, size: 50)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Product Name",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text("৳ 1200", style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ],
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
}









/*
import 'package:flutter/material.dart';
import 'package:bastoopshop/app_color.dart'; // কালার ইমপোর্ট ঠিক রাখুন

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      body: Stack(
        children: [
          // ১. ড্রয়ার পেজ
          buildDrawer(),

          // ২. অ্যানিমেটেড হোম স্ক্রিন
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0.0),
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
          ),
        ],
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
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text("user@email.com", style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 40),
            drawerTile(Icons.home, "Home", DrawerItems.home),
            drawerTile(Icons.person, "Profile", DrawerItems.profile),
            drawerTile(Icons.shopping_bag, "Orders", DrawerItems.orders),
            drawerTile(Icons.settings, "Settings", DrawerItems.settings),
            const Spacer(),
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
            Icon(icon, color: selectedItem == item ? Colors.blue : Colors.white, size: 28),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: selectedItem == item ? Colors.blue : Colors.white,
                fontSize: 16,
                fontWeight: selectedItem == item ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- আপনার মডিফাইড হোম স্ক্রিন ----------------
class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(isDrawerOpen ? Icons.arrow_back_ios : Icons.menu, color: Colors.black),
          onPressed: isDrawerOpen ? onClose : onMenuTap,
        ),
        title: const Text(
          "BastoobShop",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔹 HERO / BANNER SECTION
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

            // 🔹 CATEGORY SECTION
            sectionTitle("Categories"),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  categoryItem(Icons.phone_android, "Electronics"),
                  categoryItem(Icons.checkroom, "Fashion"),
                  categoryItem(Icons.chair, "Furniture"),
                  categoryItem(Icons.fastfood, "Grocery"),
                  categoryItem(Icons.watch, "Accessories"),
                ],
              ),
            ),

            // 🔹 FEATURED PRODUCTS
            sectionTitle("Featured Products"),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return productCard();
              },
            ),

            // 🔹 FLASH SALE
            sectionTitle("Flash Sal"),
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
                        fontWeight: FontWeight.bold),
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
                    "© 2026 BastoobShop",
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
    );
  }

  // --- Reusable Widgets (HomeScreen এর ভেতরে থাকতে হবে) ---
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget categoryItem(IconData icon, String name) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget productCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(child: Icon(Icons.image, size: 50)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Product Name", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("৳ 1200", style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget vendorCard(String name) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Center(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
    );
  }
}
*/








/*
import 'package:flutter/material.dart';
// আপনার প্রজেক্টের কালার ইমপোর্টটি ঠিক রাখুন
// import 'package:bastoopshop/app_color.dart'; 

// ড্রয়ারের অপশনগুলো চেনার জন্য একটি Enum
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F), // ড্রয়ারের ব্যাকগ্রাউন্ড কালার
      body: Stack(
        children: [
          // ১. ড্রয়ার পেজ (নিচে থাকে)
          buildDrawer(),

          // ২. মেইন হোম স্ক্রিন (উপরে থাকে যা স্লাইড হবে)
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0.0),
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
          ),
        ],
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
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text("user@email.com", style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 40),
            drawerTile(Icons.home, "Home", DrawerItems.home),
            drawerTile(Icons.person, "Profile", DrawerItems.profile),
            drawerTile(Icons.shopping_bag, "Orders", DrawerItems.orders),
            drawerTile(Icons.settings, "Settings", DrawerItems.settings),
            const Spacer(),
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
            Icon(icon, color: selectedItem == item ? Colors.blue : Colors.white, size: 28),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: selectedItem == item ? Colors.blue : Colors.white,
                fontSize: 16,
                fontWeight: selectedItem == item ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- আপনার মডিফাইড হোম স্ক্রিন ----------------
class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(isDrawerOpen ? Icons.arrow_back_ios : Icons.menu, color: Colors.black),
          onPressed: isDrawerOpen ? onClose : onMenuTap,
        ),
        title: const Text(
          "BastobShop",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body:


      */
/*SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 HERO BANNER
            Container(
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

            sectionTitle("Categories"),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  categoryItem(Icons.phone_android, "Electronics"),
                  categoryItem(Icons.checkroom, "Fashion"),
                  categoryItem(Icons.chair, "Furniture"),
                  categoryItem(Icons.fastfood, "Grocery"),
                  categoryItem(Icons.watch, "Accessories"),
                ],
              ),
            ),

            sectionTitle("Featured Products"),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => productCard(),
            ),

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

            const SizedBox(height: 20),
            // Footer (কালার না পেলে Colors.blue দিন)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.blue, // AppColor.primary এর জায়গায় আপাতত নীল দিলাম
              child: const Column(
                children: [
                  Text("© 2026 BastoobShop", style: TextStyle(color: Colors.white)),
                  Text("Secure | Trusted | Fast", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),*//*

    );
  }

  // --- Reusable Widgets ---
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget categoryItem(IconData icon, String name) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget productCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
              child: const Center(child: Icon(Icons.image, size: 50)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Product Name", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("৳ 1200", style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
