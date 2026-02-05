import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/model.dart';
import '../utils/common_shimmer.dart';
import 'products_cart.dart';

class SellerProfileSheet {
  static void show(BuildContext context, int vendorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black87,
      builder: (context) => _SellerContent(vendorId: vendorId),
    );
  }
}

class _SellerContent extends StatelessWidget {
  final int vendorId;
  const _SellerContent({required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: FutureBuilder<Vendor>(
        future: ApiService().fetchVendorDetails(vendorId),
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final vendor = snapshot.data;

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ডাইনামিক স্টিকি হেডার
                  _buildSliverAppBar(context, vendor, isLoading),

                  SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStoreStats(vendor, isLoading),
                      _buildAboutSection(vendor, isLoading),

                      SizedBox(height: 15,),
                      if (!isLoading)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                          child: Text("Curated Collection",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                        ),

                    ]),

                  ),


                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: _buildProductsGrid(vendorId, isLoading),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),

              Positioned(bottom: 0, left: 0, right: 0, child: _buildStickyFooter(context, vendor, isLoading)),

              // ড্র্যাগ হ্যান্ডেল
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Vendor? vendor, bool isLoading) {
    return SliverAppBar(
      expandedHeight: 280,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      stretch: true,
      // এই LayoutBuilder টি স্ক্রল পজিশন চেক করে টাইটেল দেখাবে
      title: isLoading ? null : LayoutBuilder(
        builder: (context, constraints) {
          // যখন AppBar সংকুচিত হবে (Pinned state), তখন এটি ট্রু হবে
          final isCollapsed = constraints.biggest.height <= kToolbarHeight + 50;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isCollapsed ? 1.0 : 0.0,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(vendor!.logoUrl),
                ),
                const SizedBox(width: 12),
                Text(
                  vendor.storeName,
                  style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          );
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            isLoading
                ? const CommonShimmer(width: double.infinity, height: 280, borderRadius: 0)
                : Image.network(vendor!.bannerUrl, fit: BoxFit.cover),

            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.transparent, Colors.black87],
                ),
              ),
            ),

            // বড় প্রোফাইল ডিজাইন (স্ক্রল করলে এটি ভ্যানিশ হয়ে যাবে)
            Positioned(
              bottom: 25,
              left: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(radius: 40, backgroundImage: NetworkImage(vendor?.logoUrl ?? "")),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vendor?.storeName ?? "",
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                      const Text("Premium Verified Store", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- অন্যান্য মেথডগুলো অপরিবর্তিত থাকবে ---
  Widget _buildStoreStats(Vendor? vendor, bool isLoading) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Rating", isLoading ? "..." : vendor!.rating.toString(), Icons.star_rounded, Colors.amber),
          _divider(),
          _statItem("Followers", isLoading ? "..." : "${vendor?.followers ?? 0}", Icons.favorite_rounded, Colors.pink),
          _divider(),
          _statItem("Response", isLoading ? "..." : (vendor?.responseRate ?? "95%"), Icons.chat_bubble_rounded, Colors.indigoAccent),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Vendor? vendor, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Store Narrative", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 16)),
          const SizedBox(height: 10),
          isLoading
              ? const CommonShimmer(width: double.infinity, height: 40, borderRadius: 8)
              : Text(vendor!.about, style: TextStyle(color: Colors.blueGrey[600], height: 1.6, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(int vendorId, bool isLoading) {
    if (isLoading) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.7),
        delegate: SliverChildBuilderDelegate((c, i) => const CommonShimmer(width: double.infinity, height: double.infinity, borderRadius: 24), childCount: 4),
      );
    }
    return FutureBuilder<List<Product>>(
      future: ApiService().fetchVendorProducts(vendorId, limit: 4),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SliverToBoxAdapter(child: SizedBox());
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.7),
          delegate: SliverChildBuilderDelegate((c, i) => ProductCard(product: snapshot.data![i]), childCount: snapshot.data!.length),
        );
      },
    );
  }

  Widget _buildStickyFooter(BuildContext context, Vendor? vendor, bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          _circleActionBtn(Icons.chat_bubble_outline_rounded, Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text("Follow Store", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
    ]);
  }

  Widget _divider() => Container(height: 30, width: 1, color: Colors.grey[200]);

  Widget _circleActionBtn(IconData icon, Color color) {
    return Container(
      height: 60, width: 60,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(20)),
      child: Icon(icon, color: color, size: 24),
    );
  }
}







/*import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/model.dart';
import '../utils/common_shimmer.dart';
import 'products_cart.dart';

class SellerProfileSheet {
  static void show(BuildContext context, int vendorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black87,
      builder: (context) => _SellerContent(vendorId: vendorId),
    );
  }
}

class _SellerContent extends StatelessWidget {
  final int vendorId;
  const _SellerContent({required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: FutureBuilder<Vendor>(
        future: ApiService().fetchVendorDetails(vendorId),
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final vendor = snapshot.data;

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ১. প্রিমিয়াম স্লভার হেডার (এটি স্ক্রলিং ওভাররাইড এরর ফিক্স করবে)
                  _buildSliverAppBar(context, vendor, isLoading),

                  SliverList(
                    delegate: SliverChildListDelegate([
                      // ২. স্টোর স্ট্যাটস (Rating, Followers)
                      _buildStoreStats(vendor, isLoading),

                      // ৩. স্টোর ডেসক্রিপশন
                      _buildAboutSection(vendor, isLoading),

                      if (!isLoading)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                          child: Text("Curated Collection",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                        ),

                      SizedBox(height: 10,)
                    ]),
                  ),

                  // ৪. প্রোডাক্ট গ্রিড
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: _buildProductsGrid(vendorId, isLoading),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),

              // ৫. স্টিকি অ্যাকশন বাটন
              Positioned(bottom: 0, left: 0, right: 0, child: _buildStickyFooter(context, vendor, isLoading)),

              // ড্র্যাগ হ্যান্ডেল (সবার উপরে)
              _buildHandle(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Vendor? vendor, bool isLoading) {
    return SliverAppBar(
      expandedHeight: 280,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      stretch: true,
      centerTitle: false, // বাম দিকে রাখার জন্য false

      // ১. স্টিকি টাইটেল (লোগো + নাম) যা স্ক্রল করলে ভেসে উঠবে
      title: isLoading
          ? null
          : Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(vendor!.logoUrl),
          ),
          const SizedBox(width: 10),
          Text(
            vendor.storeName,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5
            ),
          ),
        ],
      ),

      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // মেইন ব্যানার ইমেজ
            isLoading
                ? const CommonShimmer(width: double.infinity, height: 280, borderRadius: 0)
                : Image.network(vendor!.bannerUrl, fit: BoxFit.cover),

            // গ্রেডিয়েন্ট লেয়ার
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black38, Colors.transparent, Colors.black87],
                ),
              ),
            ),

            // ২. বড় প্রোফাইল ডিজাইন (ব্যানারের ওপর)
            Positioned(
              bottom: 25,
              left: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]
                    ),
                    child: isLoading
                        ? const CommonShimmer.circular(width: 70, height: 70)
                        : CircleAvatar(radius: 40, backgroundImage: NetworkImage(vendor!.logoUrl)),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isLoading)
                        Text(
                          vendor!.storeName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              shadows: [Shadow(blurRadius: 15, color: Colors.black)]
                          ),
                        ),
                      const Text(
                          "Premium Verified Store",
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)
                      ),
                      const SizedBox(height: 5),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  // স্ট্যাটস সেকশন (কার্ড ডিজাইন)
  Widget _buildStoreStats(Vendor? vendor, bool isLoading) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Rating", isLoading ? "..." : vendor!.rating.toString(), Icons.star_rounded, Colors.amber),
          _divider(),
          _statItem("Followers", isLoading ? "..." : "${vendor?.followers ?? 0}", Icons.favorite_rounded, Colors.pink),
          _divider(),
          _statItem("Response", isLoading ? "..." : (vendor?.responseRate ?? "95%"), Icons.chat_bubble_rounded, Colors.indigoAccent),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Vendor? vendor, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Store Narrative", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 16)),
          const SizedBox(height: 10),
          isLoading
              ? const CommonShimmer(width: double.infinity, height: 40, borderRadius: 8)
              : Text(vendor!.about, style: TextStyle(color: Colors.blueGrey[600], height: 1.6, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(int vendorId, bool isLoading) {
    if (isLoading) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.7),
        delegate: SliverChildBuilderDelegate((c, i) => const CommonShimmer(width: double.infinity, height: double.infinity, borderRadius: 24), childCount: 4),
      );
    }
    return FutureBuilder<List<Product>>(
      future: ApiService().fetchVendorProducts(vendorId, limit: 4),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SliverToBoxAdapter(child: SizedBox());
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.7),
          delegate: SliverChildBuilderDelegate((c, i) => ProductCard(product: snapshot.data![i]), childCount: snapshot.data!.length),
        );
      },
    );
  }

  Widget _buildStickyFooter(BuildContext context, Vendor? vendor, bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -5))]
      ),
      child: Row(
        children: [
          _circleActionBtn(Icons.chat_bubble_outline_rounded, Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 60),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
              ),
              child: const Text("Follow Store", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _divider() => Container(height: 30, width: 1, color: Colors.grey[200]);

  Widget _circleActionBtn(IconData icon, Color color) {
    return Container(
      height: 60, width: 60,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20)
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildHandle() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40, height: 4,
        decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}*/




/*
import 'package:bastoopshop/products/products_cart.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../app_color.dart';
import '../models/model.dart';
import '../utils/common_shimmer.dart';

class SellerProfileSheet {
  static void show(BuildContext context, int vendorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.7), // ফোকাস বাড়াতে ডার্ক ব্যারিয়ার
      builder: (context) => _SellerContent(vendorId: vendorId),
    );
  }
}

class _SellerContent extends StatelessWidget {
  final int vendorId;
  const _SellerContent({required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB), // হালকা অফ-হোয়াইট ব্যাকগ্রাউন্ড
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: FutureBuilder<Vendor>(
        future: ApiService().fetchVendorDetails(vendorId),
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final vendor = snapshot.data;

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHandle()),

                  // ১. ব্যানার ও লোগো (মিনিমালিস্ট স্পেসিং)
                  SliverToBoxAdapter(child: _buildHeader(vendor, isLoading)),

                  // ২. সেলার টাইটেল ও স্ট্যাটাস ব্যাজ
                  SliverToBoxAdapter(child: _buildTitleSection(vendor, isLoading)),

                  // ৩. স্টোর স্ট্যাটস (গ্লাস-মর্ফিজম লুক)
                  SliverToBoxAdapter(child: _buildStoreStats(vendor, isLoading)),

                  // ৪. স্টোর ডেসক্রিপশন
                  SliverToBoxAdapter(child: _buildAboutSection(vendor, isLoading)),

                  // ৫. টপ প্রোডাক্টস হেডলাইন
                  if (!isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                        child: Text("Curated Collection",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      ),
                    ),

                  // ৬. প্রোডাক্ট গ্রিড
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: _buildProductsGrid(vendorId, isLoading),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),

              // ৭. ফ্লোটিং স্টিকি অ্যাকশন বাটন
              Positioned(bottom: 0, left: 0, right: 0, child: _buildStickyFooter(context, vendor, isLoading)),
            ],
          );
        },
      ),
    );
  }

  // --- প্রিমিয়াম উইজেটস ---

  Widget _buildHeader(Vendor? vendor, bool isLoading) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ব্যানার উইথ গ্রেডিয়েন্ট ওভারলে
        Container(
          height: 220,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: isLoading
                ? const CommonShimmer(width: double.infinity, height: 220, borderRadius: 24)
                : Image.network(vendor!.bannerUrl, fit: BoxFit.cover),
          ),
        ),
        // লোগো - হোয়াইট বর্ডার ও শ্যাডো
        Positioned(
          bottom: -35,
          left: 40,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))]
            ),
            child: isLoading
                ? const CommonShimmer.circular(width: 85, height: 85)
                : CircleAvatar(radius: 42, backgroundColor: Colors.white, backgroundImage: NetworkImage(vendor!.logoUrl)),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(Vendor? vendor, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 50, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isLoading
              ? const CommonShimmer(width: 180, height: 24, borderRadius: 6)
              : Row(
            children: [
              Text(vendor!.storeName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.verified, color: Colors.blue, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          isLoading
              ? const CommonShimmer(width: 120, height: 14, borderRadius: 4)
              : Text("PREMIUM PARTNER • SINCE 2024", style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildStoreStats(Vendor? vendor, bool isLoading) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Rating", isLoading ? "..." : vendor!.rating.toString(), Icons.star_rounded, Colors.amber),
          _divider(),
          _statItem("Followers", isLoading ? "..." : "${vendor?.followers ?? 0}", Icons.favorite_rounded, Colors.redAccent),
          _divider(),
          _statItem("Response", isLoading ? "..." : vendor!.responseRate, Icons.chat_bubble_rounded, Colors.indigoAccent),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Vendor? vendor, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("About the Store", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 8),
          isLoading
              ? Column(children: List.generate(2, (i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: CommonShimmer(width: double.infinity, height: 12, borderRadius: 4))))
              : Text(vendor!.about, style: TextStyle(color: Colors.grey[600], height: 1.6, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(int vendorId, bool isLoading) {
    if (isLoading) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.7),
        delegate: SliverChildBuilderDelegate((c, i) => const CommonShimmer(width: double.infinity, height: double.infinity, borderRadius: 20), childCount: 4),
      );
    }
    return FutureBuilder<List<Product>>(
      future: ApiService().fetchVendorProducts(vendorId, limit: 4),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SliverToBoxAdapter(child: SizedBox());
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.7),
          delegate: SliverChildBuilderDelegate((c, i) => ProductCard(product: snapshot.data![i]), childCount: snapshot.data!.length),
        );
      },
    );
  }

  Widget _buildStickyFooter(BuildContext context, Vendor? vendor, bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, -10))]
      ),
      child: Row(
        children: [
          _circleActionBtn(Icons.chat_bubble_outline_rounded, Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // বড় কোম্পানিগুলো ব্ল্যাক বা ডার্ক থিম ইউজ করে
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 60),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
              ),
              child: const Text("Follow Store", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // --- হেল্পারস ---
  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.5)),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _divider() => Container(height: 40, width: 1, color: Colors.grey[100]);

  Widget _circleActionBtn(IconData icon, Color color) {
    return Container(
      height: 60, width: 60,
      decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(18)
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildHandle() => Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 16), width: 45, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))));
}

*/







/*
import 'package:bastoopshop/products/products_cart.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../app_color.dart';
import '../models/model.dart';
import '../utils/common_shimmer.dart';

class SellerProfileSheet {
  static void show(BuildContext context, int vendorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SellerContent(vendorId: vendorId),
    );
  }
}

class _SellerContent extends StatelessWidget {
  final int vendorId;
  const _SellerContent({required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: FutureBuilder<Vendor>(
        future: ApiService().fetchVendorDetails(vendorId),
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final vendor = snapshot.data;

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHandle()),

                  // ১. ব্যানার ও লোগো সেকশন
                  SliverToBoxAdapter(child: _buildHeader(vendor, isLoading)),

                  // ২. সেলারের নাম ও ভেরিফাইড ব্যাজ
                  SliverToBoxAdapter(child: _buildTitleSection(vendor, isLoading)),

                  // ৩. স্টোর স্ট্যাটস (Rating, Followers)
                  SliverToBoxAdapter(child: _buildStoreStats(vendor, isLoading)),

                  // ৪. স্টোর ডেসক্রিপশন
                  SliverToBoxAdapter(child: _buildAboutSection(vendor, isLoading)),

                  // ৫. টপ প্রোডাক্টস হেডলাইন
                  if (!isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Text("Top Products", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),

                  // ৬. প্রোডাক্ট গ্রিড (শিমার সহ)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    sliver: _buildProductsGrid(vendorId, isLoading),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),

              // ৭. স্টিকি অ্যাকশন বাটন
              Positioned(bottom: 0, left: 0, right: 0, child: _buildStickyFooter(context, vendor, isLoading)),
            ],
          );
        },
      ),
    );
  }

  // --- প্রিমিয়াম উইজেটস ---

  Widget _buildHeader(Vendor? vendor, bool isLoading) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ব্যানার শিমার বা ইমেজ
        isLoading
            ? const CommonShimmer(width: double.infinity, height: 200, borderRadius: 0)
            : Container(
          height: 200,
          width: double.infinity,
          child: Image.network(vendor!.bannerUrl, fit: BoxFit.cover),
        ),
        // লোগো শিমার বা ইমেজ
        Positioned(
          bottom: -45,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: isLoading
                ? const CommonShimmer.circular(width: 90, height: 90)
                : CircleAvatar(radius: 45, backgroundImage: NetworkImage(vendor!.logoUrl)),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(Vendor? vendor, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(120, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isLoading
              ? const CommonShimmer(width: 150, height: 20, borderRadius: 4)
              : Row(
            children: [
              Text(vendor!.storeName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 5),
              const Icon(Icons.verified, color: Colors.blue, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          isLoading
              ? const CommonShimmer(width: 100, height: 12, borderRadius: 4)
              : Text("Level 4 Top Rated Seller", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStoreStats(Vendor? vendor, bool isLoading) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Rating", isLoading ? "..." : vendor!.rating.toString(), Icons.star_rounded, Colors.orange),
          _divider(),
          _statItem("Followers", isLoading ? "..." : "${vendor?.followers ?? 0}", Icons.favorite_rounded, Colors.pink),
          _divider(),
          _statItem("Response", isLoading ? "..." : vendor!.responseRate, Icons.chat_bubble_rounded, Colors.green),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Vendor? vendor, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: isLoading
          ? Column(children: List.generate(2, (i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: CommonShimmer(width: double.infinity, height: 12, borderRadius: 4))))
          : Text(vendor!.about, style: TextStyle(color: Colors.grey[700], height: 1.5)),
    );
  }

  Widget _buildProductsGrid(int vendorId, bool isLoading) {
    if (isLoading) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.75),
        delegate: SliverChildBuilderDelegate((c, i) => const CommonShimmer(width: double.infinity, height: double.infinity, borderRadius: 12), childCount: 4),
      );
    }
    return FutureBuilder<List<Product>>(
      future: ApiService().fetchVendorProducts(vendorId, limit: 4),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SliverToBoxAdapter(child: SizedBox());
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.75),
          delegate: SliverChildBuilderDelegate((c, i) => ProductCard(product: snapshot.data![i]), childCount: snapshot.data!.length),
        );
      },
    );
  }

  Widget _buildStickyFooter(BuildContext context, Vendor? vendor, bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          _circleActionBtn(Icons.chat_outlined, Colors.blue),
          const SizedBox(width: 12),
          _circleActionBtn(Icons.share_outlined, Colors.grey[800]!),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(0, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text("Follow Store", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // --- ছোট হেল্পারস ---
  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
    ]);
  }

  Widget _divider() => Container(height: 30, width: 1, color: Colors.grey[300]);

  Widget _circleActionBtn(IconData icon, Color color) {
    return Container(
      height: 54, width: 54,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(15)),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildHandle() => Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))));
}
*/



/*
import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../app_color.dart';
import '../models/model.dart';
import '../utils/common_shimmer.dart';
import 'products_cart.dart';

class SellerProfileSheet {
  static void show(BuildContext context, int vendorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => _SellerContent(vendorId: vendorId),
    );
  }
}

class _SellerContent extends StatelessWidget {
  final int vendorId;
  const _SellerContent({required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
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
              return Column(
                children: [
                  _buildHandle(),
                  const CommonShimmer(width: double.infinity, height: 180, borderRadius: 0),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final vendor = snapshot.data!;
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
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
                  bottom: 0, left: 0, right: 0,
                  child: _buildStickyFooter(context, vendor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Helper Widgets (আপনার আগের সব লজিক এখানে আসবে) ---

  static Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 50, height: 5,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildTopProductsGrid(int vendorId) {
    return FutureBuilder<List<Product>>(
      future: ApiService().fetchVendorProducts(vendorId, limit: 5),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SliverToBoxAdapter(child: LinearProgressIndicator());

        final products = snapshot.data!;
        final displayList = products.length > 4 ? products.take(4).toList() : products;

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.75,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) => ProductCard(product: displayList[index]), // Reusable Card!
            childCount: displayList.length,
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

  Widget _buildDynamicAbout(Vendor vendor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(vendor.about, textAlign: TextAlign.center),
    );
  }

// ... অন্যান্য হেল্পার ফাংশন যেমন _buildPremiumHeader, _buildStickyFooter ইত্যাদি এখানে থাকবে
}*/
