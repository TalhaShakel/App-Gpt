class PurchaseApi {
  // static const _apiKeyAndroid = 'goog_DRyqPWgDiJPfdrDSvwZnBMHykFH';
  // static const _apiKeiIos = 'appl_iBNNiSaBQcyYjpPLuEwMUKgllMH';
  // static bool isPaid = false;

  // static Future init() async {
  //   await Purchases.setLogLevel(LogLevel.debug);
  //   await Purchases.configure(
  //     PurchasesConfiguration(Platform.isAndroid ? _apiKeyAndroid : _apiKeiIos),
  //   );
  // }

  // static Future<List<Offering>> fetchOffers() async {
  //   try {
  //     final offerings = await Purchases.getOfferings();
  //     final current = offerings.all.values.toList();
  //     return current;
  //   } on PlatformException {
  //     return [];
  //   }
  // }

  // static Future<bool> purchasePackage(Package package) async {
  //   try {
  //     await Purchases.purchasePackage(package);
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }
}
