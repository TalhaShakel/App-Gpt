import 'package:chatgpt/purchase_api.dart';
import 'package:chatgpt/src/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await PurchaseApi.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AppGPT Ai',
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}
