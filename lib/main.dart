import 'package:bastoopshop/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'cart/cart_controller.dart';
import 'main_wrapper.dart';

void main() {
  // ১. নিশ্চিত করুন উইজেট বাইন্ডিং ঠিক আছে
  WidgetsFlutterBinding.ensureInitialized();

// ২. কনস্ট্রাক্টর এরর এড়াতে copyWith ব্যবহার (Pro Standard)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  // ৩. স্ক্রিন পুরো ডিসপ্লে জুড়ে ছড়িয়ে দেওয়া
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MultiProvider(
      // বড় কোম্পানিগুলো MultiProvider ব্যবহার করে যাতে পরে আরও প্রোভাইডার যোগ করা যায়
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const MyApp(),
    ),
  );


}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BastobShop',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainWrapper(),
    );
  }
}
