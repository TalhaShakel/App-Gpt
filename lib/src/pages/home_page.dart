import 'dart:developer';

import 'package:chatgpt/Subscritionpage.dart';
import 'package:chatgpt/network/admob_service_helper.dart';
import 'package:chatgpt/purchase_api.dart';
import 'package:chatgpt/src/pages/chat_history.dart';
import 'package:chatgpt/src/pages/chat_page.dart';
import 'package:chatgpt/src/pages/dalle_page.dart';
import 'package:chatgpt/src/pages/images_history.dart';
import 'package:chatgpt/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static AdRequest request = const AdRequest(nonPersonalizedAds: true);

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  final BannerAd myBanner = BannerAd(
    adUnitId: AdMobService.bannerAdUnitId ?? '',
    size: AdSize.fullBanner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdMobService.interstitialAdUnitId ?? '',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            log('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            log('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      log('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          log('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  void initState() {
    super.initState();
    loadAds();
  }

  bool bannerLoaded = false;

  loadAds() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDone =
        prefs.getBool(DateTime.now().toString().split(" ")[0]) ?? false;
    if (!isDone) {
      var tempCoins = prefs.getInt("coins");
      if (coins < 8) {
        prefs.setInt("coins", 8);
      }
      prefs.setBool(DateTime.now().toString().split(" ")[0], true);
    }
    coins = prefs.getInt("coins") ?? 0;
    // final customer = await Purchases.getCustomerInfo();
    // final entitlements = customer.entitlements.active.values.toList();
    // log("$entitlements");
    // PurchaseApi.isPaid = entitlements.isEmpty ? false : true;

    // await prefs.setBool("isPaid", PurchaseApi.isPaid);

    myBanner.load();
    //_createInterstitialAd();
    bannerLoaded = true;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 66, 103, 178),
      appBar: AppBar(
        title: const Text(
          'AppGPT',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 66, 103, 178),
        elevation: 1,
        centerTitle: true,
        actions: [
          Center(
            child: Text(
              "Coins: $coins",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buttonWidget('Image Generation', () {
              if (!PurchaseApi.isPaid) _showInterstitialAd();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DallePage(),
                ),
              ).then((value) => setState(() {}));
            }),
            buttonWidget(
              'Chat Bot',
              () {
                if (!PurchaseApi.isPaid) _showInterstitialAd();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatPage(),
                  ),
                ).then((value) => setState(() {}));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: buttonWidget("Old Chats", () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const ChatHistory(),
                      ),
                    );
                  }),
                ),
                Expanded(
                  child: buttonWidget("Old Images", () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const ImagesHistory(),
                      ),
                    );
                  }),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: buttonWidget("Privacy Policy", () {
                    _launchUrl(
                      Uri.parse(
                        'https://sites.google.com/view/chat-gpt-ai-privacy-policy/privacy-policy',
                      ),
                    );
                  }),
                ),
                Expanded(
                  child: buttonWidget("About Us", () {
                    _launchUrl(
                      Uri.parse(
                        'https://sites.google.com/view/chat-gpt-ai-privacy-policy/about-us',
                      ),
                    );
                  }),
                ),
              ],
            ),
            if (!PurchaseApi.isPaid)
              buttonWidget('Buy Coins', () {
                log(DateTime.now().toString().split(" ")[0]);
                if (!PurchaseApi.isPaid) _showInterstitialAd();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Subscritionpage(),
                  ),
                );
              }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        alignment: Alignment.center,
        width: myBanner.size.width.toDouble(),
        height: myBanner.size.height.toDouble(),
        child: bannerLoaded ? AdWidget(ad: myBanner) : Container(),
      ),
    );
  }

  Widget buttonWidget(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                const Color.fromARGB(255, 66, 103, 178), //Colors.grey.shade400,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 40,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Color.fromARGB(255, 66, 103, 178),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) throw 'Could not launch $url';
  }
}
