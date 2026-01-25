import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cart/cart_screen.dart';
import 'utils/custom_cursor.dart';
import 'home/home_screen.dart';

enum DrawerItems { home, profile, orders, settings, logout, cart }

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> with SingleTickerProviderStateMixin {
  // ১. এনিমেশন কন্ট্রোলার (Smooth Performance এর জন্য)
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  bool isDrawerOpen = false;
  DrawerItems selectedItem = DrawerItems.home;
  double mouseX = 0;
  double mouseY = 0;

  @override
  void initState() {
    super.initState();
    // এটি নিচের নেভিগেশন বার এবং উপরের স্ট্যাটাস বার হাইড করবে (Immersive Mode)
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // শুধুমাত্র নিচের সিস্টেম নেভিগেশন বার হাইড করার জন্য
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top], // শুধু টপ বার বা স্ট্যাটাস বার দেখাবে
    );


    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 220.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleDrawer() {
    setState(() {
      isDrawerOpen ? _animationController.reverse() : _animationController.forward();
      isDrawerOpen = !isDrawerOpen;
    });
  }
  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Exit App?"),
        content: const Text("Are you sure you want to close BastobShop?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () => SystemNavigator.pop(), // অ্যাপ সরাসরি বন্ধ করার কমান্ড
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // এখানে PopScope যোগ করা হয়েছে যা ব্যাক বাটন কন্ট্রোল করবে
    return PopScope(
      canPop: false, // ডিফল্ট ব্যাক অ্যাকশন বন্ধ
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // লজিক ১: ড্রয়ার খোলা থাকলে বন্ধ করো
        if (isDrawerOpen) {
          toggleDrawer();
          return;
        }

        // লজিক ২: যদি অন্য পেজে থাকে, তবে হোমে নিয়ে আসো
        if (selectedItem != DrawerItems.home) {
          setState(() {
            selectedItem = DrawerItems.home;
          });
          return;
        }

        // লজিক ৩: হোমে থাকলে এক্সিট ডায়ালগ দেখাবে
        _showExitDialog(context);
      },
      child: MouseRegion(
        onHover: (event) => setState(() {
          mouseX = event.localPosition.dx;
          mouseY = event.localPosition.dy;
        }),
        child: Scaffold(
          extendBody: true, // বডি নিচের বার পর্যন্ত ছড়িয়ে যাবে
          extendBodyBehindAppBar: true,
          // resizeToAvoidBottomInset: false, // sharing screen between keyboard and screen
          backgroundColor: const Color(0xFF1B1B2F),
          body: GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx > 6 && !isDrawerOpen) toggleDrawer();
              if (details.delta.dx < -6 && isDrawerOpen) toggleDrawer();
            },
            child: Stack(
              children: [
                _buildDrawer(), // ড্রয়ার

                // এনিমেটেড মেইন কন্টেন্ট
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform(
                      transform: Matrix4.translationValues(_slideAnimation.value, _slideAnimation.value * 0.5, 0)
                        ..scale(_scaleAnimation.value)
                        ..rotateY(isDrawerOpen ? -0.3 : 0),
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0),
                    child: Stack(
                      children: [
                        IndexedStack(
                          index: selectedItem.index,
                          children: [
                            HomeScreen(
                              onMenuTap: toggleDrawer,
                              isDrawerOpen: isDrawerOpen,
                              onClose: toggleDrawer,
                              onCartTap: () => setState(() => selectedItem = DrawerItems.cart),
                            ),
                            const Center(child: Text("Profile", style: TextStyle(color: Colors.white))),
                            const Center(child: Text("Orders", style: TextStyle(color: Colors.white))),
                            const Center(child: Text("Settings", style: TextStyle(color: Colors.white))),
                            const Center(child: Text("Logout", style: TextStyle(color: Colors.white))),
                            CartScreen(
                              onMenuTap: toggleDrawer,
                              onClose: toggleDrawer,
                              isDrawerOpen: isDrawerOpen,
                            ),
                          ],
                        ),
                        if (isDrawerOpen)
                          GestureDetector(
                            onTap: toggleDrawer,
                            child: Container(color: Colors.transparent),
                          ),
                      ],
                    ),
                  ),
                ),

                CustomCursor(x: mouseX, y: mouseY), // কাস্টম কার্সার
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return SafeArea(
      child: Container(
        width: 230,
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
            const Text("User Name", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("user@email.com", style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 40),
            _drawerTile(Icons.home_rounded, "Home", DrawerItems.home),
            _drawerTile(Icons.person_rounded, "Profile", DrawerItems.profile),
            _drawerTile(Icons.shopping_bag_rounded, "Orders", DrawerItems.orders),
            _drawerTile(Icons.shopping_cart_rounded, "Cart", DrawerItems.cart),
            _drawerTile(Icons.settings_rounded, "Settings", DrawerItems.settings),
            const Spacer(),
            _drawerTile(Icons.logout_rounded, "Logout", DrawerItems.logout),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, DrawerItems item) {
    bool isSelected = selectedItem == item;
    return GestureDetector(
      onTap: () {
        setState(() => selectedItem = item);
        toggleDrawer();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.white70, size: 24),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(color: isSelected ? Colors.blue : Colors.white70, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
