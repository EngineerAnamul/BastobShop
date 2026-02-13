import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/model.dart';
import '../utils/common_shimmer.dart';
import '../products/products_cart.dart';

class SellerProfileSheet {
  static void show(BuildContext context, int vendorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.1),
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

                      SizedBox(height: 15),
                      if (!isLoading)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                          child: Text(
                            "Curated Collection",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
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

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildStickyFooter(context, vendor, isLoading),
              ),

              // ড্র্যাগ হ্যান্ডেল
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget _buildSliverAppBar(
  //   BuildContext context,
  //   Vendor? vendor,
  //   bool isLoading,
  // ) {
  //   return SliverAppBar(
  //     expandedHeight: 280,
  //     automaticallyImplyLeading: false,
  //     backgroundColor: Colors.white,
  //     elevation: 0,
  //     pinned: true,
  //     stretch: true,
  //     // এই LayoutBuilder টি স্ক্রল পজিশন চেক করে টাইটেল দেখাবে
  //     title: isLoading
  //         ? null
  //         : LayoutBuilder(
  //             builder: (context, constraints) {
  //               // যখন AppBar সংকুচিত হবে (Pinned state), তখন এটি ট্রু হবে
  //               final isCollapsed =
  //                   constraints.biggest.height <= kToolbarHeight + 50;
  //               return AnimatedOpacity(
  //                 duration: const Duration(milliseconds: 200),
  //                 opacity: isCollapsed ? 1.0 : 0.0,
  //                 child: Row(
  //                   children: [
  //                     CircleAvatar(
  //                       radius: 16,
  //                       backgroundImage: NetworkImage(vendor!.logoUrl),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     Text(
  //                       vendor.storeName,
  //                       style: const TextStyle(
  //                         color: Colors.black,
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.w900,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           ),
  //     flexibleSpace: FlexibleSpaceBar(
  //       background: Stack(
  //         fit: StackFit.expand,
  //         children: [
  //           isLoading
  //               ? const CommonShimmer(
  //                   width: double.infinity,
  //                   height: 280,
  //                   borderRadius: 0,
  //                 )
  //               : Image.network(vendor!.bannerUrl, fit: BoxFit.cover),

  //           const DecoratedBox(
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 begin: Alignment.topCenter,
  //                 end: Alignment.bottomCenter,
  //                 colors: [Colors.black26, Colors.transparent, Colors.black87],
  //               ),
  //             ),
  //           ),

  //           // বড় প্রোফাইল ডিজাইন (স্ক্রল করলে এটি ভ্যানিশ হয়ে যাবে)
  //           Positioned(
  //             bottom: 25,
  //             left: 20,
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               children: [
  //                 Container(
  //                   padding: const EdgeInsets.all(4),
  //                   decoration: const BoxDecoration(
  //                     color: Colors.white,
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: CircleAvatar(
  //                     radius: 40,
  //                     backgroundImage: NetworkImage(vendor?.logoUrl ?? ""),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 15),
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text(
  //                       vendor?.storeName ?? "",
  //                       style: const TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 26,
  //                         fontWeight: FontWeight.w900,
  //                       ),
  //                     ),
  //                     const Text(
  //                       "Premium Verified Store",
  //                       style: TextStyle(color: Colors.white70, fontSize: 13),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSliverAppBar(
    BuildContext context,
    Vendor? vendor,
    bool isLoading,
  ) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      title: (isLoading || vendor == null)
          ? null
          : LayoutBuilder(
              builder: (context, constraints) {
                final isCollapsed =
                    constraints.biggest.height <= kToolbarHeight + 50;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isCollapsed ? 1.0 : 0.0,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        // Null check এবং fallback image
                        backgroundImage: NetworkImage(vendor.logoUrl ?? ""),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        vendor.storeName ?? "Store",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
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
            isLoading || vendor == null
                ? const CommonShimmer(
                    width: double.infinity,
                    height: 280,
                    borderRadius: 0,
                  )
                : Image.network(vendor.bannerUrl ?? "", fit: BoxFit.cover),
            // ... gradient code
            Positioned(
              bottom: 25,
              left: 20,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(vendor?.logoUrl ?? ""),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor?.storeName ?? "Loading...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        "Premium Verified Store",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- অন্যান্য মেথডগুলো অপরিবর্তিত থাকবে ---
  /*   Widget _buildStoreStats(Vendor? vendor, bool isLoading) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            "Rating",
            isLoading ? "..." : vendor!.rating.toString(),
            Icons.star_rounded,
            Colors.amber,
          ),
          _divider(),
          _statItem(
            "Followers",
            isLoading ? "..." : "${vendor?.followers ?? 0}",
            Icons.favorite_rounded,
            Colors.pink,
          ),
          _divider(),
          _statItem(
            "Response",
            isLoading ? "..." : (vendor?.responseRate ?? "95%"),
            Icons.chat_bubble_rounded,
            Colors.indigoAccent,
          ),
        ],
      ),
    );
  }
 */

  Widget _buildStoreStats(Vendor? vendor, bool isLoading) {
    return Container(
      // ... styling code
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            "Rating",
            (isLoading || vendor == null) ? "0.0" : "${vendor.rating ?? 0.0}",
            Icons.star_rounded,
            Colors.amber,
          ),
          _divider(),
          _statItem(
            "Followers",
            (isLoading || vendor == null) ? "0" : "${vendor.followers ?? 0}",
            Icons.favorite_rounded,
            Colors.pink,
          ),
          _divider(),
          _statItem(
            "Response",
            (isLoading || vendor == null)
                ? "N/A"
                : (vendor.responseRate ?? "95%"),
            Icons.chat_bubble_rounded,
            Colors.indigoAccent,
          ),
        ],
      ),
    );
  }

  // Widget _buildAboutSection(Vendor? vendor, bool isLoading) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 28),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           "Store Narrative",
  //           style: TextStyle(
  //             fontWeight: FontWeight.w800,
  //             color: Colors.black,
  //             fontSize: 16,
  //           ),
  //         ),
  //         const SizedBox(height: 10),
  //         isLoading
  //             ? const CommonShimmer(
  //                 width: double.infinity,
  //                 height: 40,
  //                 borderRadius: 8,
  //               )
  //             : Text(
  //                 vendor!.about,
  //                 style: TextStyle(
  //                   color: Colors.blueGrey[600],
  //                   height: 1.6,
  //                   fontSize: 14,
  //                 ),
  //               ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAboutSection(Vendor? vendor, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Store Narrative",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          isLoading || vendor == null
              ? const CommonShimmer(
                  width: double.infinity,
                  height: 40,
                  borderRadius: 8,
                )
              : Text(
                  vendor.about ??
                      "No description available.", // Null হলে ডিফল্ট মেসেজ
                  style: TextStyle(
                    color: Colors.blueGrey[600],
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(int vendorId, bool isLoading) {
    if (isLoading) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (c, i) => const CommonShimmer(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 24,
          ),
          childCount: 4,
        ),
      );
    }
    return FutureBuilder<List<Product>>(
      future: ApiService().fetchVendorProducts(vendorId, limit: 4),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(child: SizedBox());
        }

        // ডাটা না থাকলে বা খালি থাকলে একটি মেসেজ দেখান
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text("No products found.")),
          );
        }

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          delegate: SliverChildBuilderDelegate(
            (c, i) => ProductCard(product: snapshot.data![i]),
            childCount: snapshot.data!.length,
          ),
        );
      },
    );
  }

  Widget _buildStickyFooter(
    BuildContext context,
    Vendor? vendor,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Follow Store",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _divider() => Container(height: 30, width: 1, color: Colors.grey[200]);

  Widget _circleActionBtn(IconData icon, Color color) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
