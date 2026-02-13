import 'dart:io';

import 'package:bastoopshop/api/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
          border: Border.all(
            color: Colors.grey.shade200,
          ), // বর্ডার দিলে প্রিমিয়াম লাগে
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ১. ইমেজ সেকশন (Expanded করার ফলে এটি ওভারফ্লো হতে দেবে না)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CommonShimmer(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 12,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // ২. টেক্সট সেকশন
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // এটি কন্টেন্ট অনুযায়ী জায়গা নেবে
                children: [
                  Text(
                    product.name,
                    maxLines: 2, // নাম বড় হলে ২ লাইনে দেখাবে, কার্ড ফাটবে না
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "৳ ${product.price}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w900,
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



// class ProductCard extends StatelessWidget {
//   final Product product;
//   final currentUserId = 101;


//   const ProductCard({super.key, required this.product});


//   @override
//   Widget build(BuildContext context) {
//     // স্ক্রিনের উইডথ কত সেটা চেক করা হচ্ছে
//     double screenWidth = MediaQuery.of(context).size.width;

//     // কলাম সংখ্যা নির্ধারণ: উইডথ যদি ৬০০ এর বেশি হয় (ট্যাবলেট) তবে ৩টি, নাহলে ২টি
//     int crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

//     // বড় স্ক্রিনে কার্ড খুব লম্বা যেন না হয় সেজন্য রেশিও অ্যাডজাস্ট করা
//     double aspectRatio = screenWidth > 600 ? 0.85 : 0.72;



// Future<String> getDeviceIdentifier() async {
//       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

//       if (Platform.isAndroid) {
//         AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//         return androidInfo.id; // অ্যান্ড্রয়েডের জন্য ইউনিক হার্ডওয়্যার আইডি
//       } else if (Platform.isIOS) {
//         IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//         return iosInfo.identifierForVendor ??
//             "unknown_ios"; // আইফোনের জন্য ইউনিক আইডি
//       }

//       return "unknown_device";
//     }

    
//     return GestureDetector(
//       onTap: () => {
//       // ApiService().trackUserInteraction(product.id, currentUserId),
//       ProductDetailsSheet.show(context, product),
//       },

//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ১. ইমেজ সেকশন (এখন ১:১ রেশিওতে থাকবে)
//             AspectRatio(
//               aspectRatio: 1 / 1,
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(12),
//                   ),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(12),
//                   ),
//                   child: CachedNetworkImage(
//                     imageUrl: product.imageUrl,
//                     fit:
//                         BoxFit.cover, // ইমেজটি যেন পুরো স্কয়ার জায়গা জুড়ে থাকে
//                     placeholder: (context, url) => const CommonShimmer(
//                       width: double.infinity,
//                       height: double.infinity,
//                       borderRadius: 12,
//                     ),
//                     errorWidget: (context, url, error) => const Center(
//                       child: Icon(Icons.broken_image, color: Colors.grey),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // ২. টেক্সট সেকশন (আপনার শিমারের প্যাডিং ও এলাইনমেন্ট অনুযায়ী) */
//             Padding(
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // প্রোডাক্টের নাম
//                   Text(
//                     product.name,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   // শিমারের স্পেসিং অনুযায়ী ৮ পিক্সেল

//                   // প্রোডাক্টের দাম
//                   Text(
//                     "৳ ${product.price}",
//                     style: const TextStyle(
//                       color: Colors.green,
//                       fontWeight: FontWeight.w900, // আরও বোল্ড লুকের জন্য
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
