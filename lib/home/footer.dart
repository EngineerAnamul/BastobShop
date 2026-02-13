import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // যদি স্ক্রিন উইডথ ৯০০ এর কম হয় তবে মোবাইল লেআউট দেখাবে
        bool isMobile = constraints.maxWidth < 900;

        return Container(
          width: double.infinity,
          color: const Color(0xFF0F1111), // ডার্ক প্রফেশনাল থিম
          padding: EdgeInsets.symmetric(
            vertical: 50, 
            horizontal: isMobile ? 20 : 80
          ),
          child: Column(
            children: [
              // উপরের মেইন কন্টেন্ট সেকশন
              isMobile 
                  ? _buildMobileLayout() 
                  : _buildDesktopLayout(),

              const SizedBox(height: 50),
              const Divider(color: Colors.white10),
              const SizedBox(height: 30),

              // নিচের কপিরাইট ও ট্রাস্ট ব্যাজ সেকশন
              _buildBottomSection(isMobile),
            ],
          ),
        );
      },
    );
  }

  // ডেস্কটপ লেআউট: ৪টি কলামে বিভক্ত
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _brandSection(),
        _footerLinkColumn("Customer Care", ["Help Center", "How to Buy", "Returns & Refunds", "Shipping & Delivery"]),
        _footerLinkColumn("Make Money", ["Sell on AIH", "Vendor Policy", "Affiliate Program", "Vendor Guide"]),
        _footerLinkColumn("Company", ["About Us", "Contact Us", "Privacy Policy", "Terms & Conditions"]),
      ],
    );
  }

  // মোবাইল লেআউট: কলামগুলো নিচে নিচে বসবে
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _brandSection(),
        const SizedBox(height: 40),
        _footerLinkColumn("Customer Care", ["Help Center", "Returns", "Shipping"]),
        const SizedBox(height: 30),
        _footerLinkColumn("Make Money", ["Become a Seller", "Vendor Login"]),
        const SizedBox(height: 30),
        _footerLinkColumn("Company", ["About Us", "Terms"]),
      ],
    );
  }

  // লোগো ও ব্র্যান্ড সেকশন
  Widget _brandSection() {
    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AIH COMPANY",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 15),
          Text(
            "Your trusted multi-vendor marketplace for quality products. Secure, Fast, and Reliable.",
            style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _socialIcon(Icons.facebook),
              _socialIcon(Icons.linked_camera),
              _socialIcon(Icons.email),
            ],
          )
        ],
      ),
    );
  }

  // কলামের লিঙ্ক জেনারেটর
  Widget _footerLinkColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 20),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {},
                child: Text(link, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              ),
            )),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  // কপিরাইট ও পেমেন্ট আইকন সেকশন
  Widget _buildBottomSection(bool isMobile) {
    var content = [
      const Text(
        "© 2026 AIH Global Ltd. All Rights Reserved",
        style: TextStyle(color: Colors.white38, fontSize: 12),
      ),
      if (isMobile) const SizedBox(height: 20),
      Row(
        children: [
          const Text("We Accept:", style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(width: 10),
          _paymentIcon(Icons.credit_card),
          _paymentIcon(Icons.account_balance_wallet),
          _paymentIcon(Icons.qr_code_scanner),
        ],
      ),
    ];

    return isMobile 
        ? Column(children: content) 
        : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: content);
  }

  Widget _paymentIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Icon(icon, color: Colors.white24, size: 24),
    );
  }
}