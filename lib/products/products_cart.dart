import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/model.dart';
import '../utils/common_shimmer.dart';
import 'product_details.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // স্ক্রিনের উইডথ কত সেটা চেক করা হচ্ছে
    double screenWidth = MediaQuery.of(context).size.width;

    // কলাম সংখ্যা নির্ধারণ: উইডথ যদি ৬০০ এর বেশি হয় (ট্যাবলেট) তবে ৩টি, নাহলে ২টি
    int crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    // বড় স্ক্রিনে কার্ড খুব লম্বা যেন না হয় সেজন্য রেশিও অ্যাডজাস্ট করা
    double aspectRatio = screenWidth > 600 ? 0.85 : 0.72;

    return GestureDetector(
      onTap: () => ProductDetailsSheet.show(context, product),
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
            // ১. ইমেজ সেকশন (আপনার শিমারের মতো Expanded ব্যবহার করা হয়েছে)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  // শিমারের বেস কালারের সাথে মিল রাখতে
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child:
                      // Image.network এর বদলে এটি ব্যবহার করুন
                      CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CommonShimmer(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 12,
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image),
                      ),

                  /*Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      // লোড হওয়ার সময় আপনার সেই কমন শিমার
                      return const CommonShimmer(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 12,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  )*/
                ),
              ),
            ),

            // ২. টেক্সট সেকশন (আপনার শিমারের প্যাডিং ও এলাইনমেন্ট অনুযায়ী)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // প্রোডাক্টের নাম
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // শিমারের স্পেসিং অনুযায়ী ৮ পিক্সেল

                  // প্রোডাক্টের দাম
                  Text(
                    "৳ ${product.price}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w900, // আরও বোল্ড লুকের জন্য
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

/*

import 'package:flutter/material.dart';

import '../models/model.dart';
import '../utils/common_shimmer.dart';
import 'product_details.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ProductDetailsSheet.show(context, product),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
*/
/*

                child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CommonShimmer(
                        width: double.infinity,
                        height: 180,
                        borderRadius: 12,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                  ),
*/ /*



                  // ProductCard.dart ফাইলে ইমেজ সেকশনটি এভাবে আপডেট করুন
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child; // ইমেজ লোড শেষ হলে আসল ছবি

                      // ইমেজ লোড হওয়ার সময় আপনার তৈরি শিমার দেখাবে
                      return CommonShimmer(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 12,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "৳ ${product.price}",
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
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
*/
