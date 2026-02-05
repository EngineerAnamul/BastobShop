import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommonShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder shapeBorder;

  // ১. মেইন কনস্ট্রাক্টর
  const CommonShimmer({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.shapeBorder = const RoundedRectangleBorder(),
  });

  // ২. সার্কুলার কনস্ট্রাক্টর (ইনিশিয়ালাইজেশন এরর ফিক্সড)
  const CommonShimmer.circular({
    super.key,
    required this.width,  // এখানে সরাসরি this.width ব্যবহার করা হয়েছে
    required this.height, // এখানে সরাসরি this.height ব্যবহার করা হয়েছে
    this.borderRadius = 0,
  }) : shapeBorder = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: borderRadius > 0
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))
              : shapeBorder,
        ),
      ),
    );
  }
}


class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // স্ক্রিনের উইডথ চেক করা হচ্ছে
    double screenWidth = MediaQuery.of(context).size.width;

    // উইডথ অনুযায়ী কলাম সংখ্যা নির্ধারণ (বড় স্ক্রিনে ৪টি, ছোটতে ২টি)
    int crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.75,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CommonShimmer(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 12,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonShimmer(width: double.infinity, height: 15, borderRadius: 5),
                      SizedBox(height: 8),
                      CommonShimmer(width: 60, height: 15, borderRadius: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // স্ক্রিন বড় হলে শিমার কার্ডও বেশি দেখানো উচিত (যেমন ৮টি বা ১২টি)
          childCount: crossAxisCount * 3,
        ),
      ),
    );
  }
}