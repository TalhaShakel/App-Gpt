import 'dart:developer';

import 'package:chatgpt/purchase_api.dart';
import 'package:chatgpt/src/pages/home_page.dart';
import 'package:chatgpt/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Subscritionpage extends StatefulWidget {
  const Subscritionpage({super.key});

  @override
  State<Subscritionpage> createState() => _SubscritionpageState();
}

class _SubscritionpageState extends State<Subscritionpage> {
  List<Offering> offerings = [];
  //late Package p;
  String price = '';
  @override
  void initState() {
    fetchOffers();
    super.initState();
  }

  fetchOffers() async {
    offerings = await PurchaseApi.fetchOffers();
    log("packages: $offerings");
    offerings = offerings
        .where(
          (element) => element.availablePackages[0].storeProduct.identifier
              .contains("chatify"),
        )
        .toList();
    // final packages = offerings
    //     .map((offer) => offer.availablePackages)
    //     .expand((element) => element)
    //     .toList();
    // log("packages: $packages");
    // p = packages.firstWhere((element) =>
    //     element.storeProduct.identifier ==
    //     (Platform.isAndroid ? "appgptai_monthly" : "07860786"));
    // price = p.storeProduct.priceString;
    log("length: ${offerings.length}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Coins"),
        backgroundColor: const Color.fromARGB(255, 66, 103, 178),
        actions: [
          Center(
            child: Text(
              "Coins: $coins",
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: ListView.builder(
            itemCount: offerings.length,
            itemBuilder: (ctx, index) {
              return Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offerings[index].identifier,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "◉ You Will Get ${offerings[index].identifier}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const Text(
                              "◉ Can be bought multiple times",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              "◉ Price: ${offerings[index].availablePackages[0].storeProduct.priceString} Only",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const Text(
                              "◉ 1 coin for 1 chat search",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const Text(
                              "◉ 2 coins for 1 image search ",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              showWaitingDialog();
                              getOffers(offerings[index].availablePackages[0]);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text("Buy Now"),
                          ),
                          Text(offerings[index]
                              .availablePackages[0]
                              .storeProduct
                              .priceString)
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  getOffers(Package p) async {
    log(p.storeProduct.description);
    bool purchaseMade = await PurchaseApi.purchasePackage(p);
    log("purchase: $purchaseMade");
    final prefs = await SharedPreferences.getInstance();
    Navigator.of(context).pop();
    if (!purchaseMade) {
      showFailDialog();
    } else {
      int coinsToAdd = int.parse(p.offeringIdentifier.split(" ")[0]);
      coins += coinsToAdd;
      prefs.setInt("coins", coins);
      showSuccessDialog();
      setState(() {});
    }
    // prefs.setBool("isPaid", purchaseMade).then((value) {

    // });
  }

  purchaseIos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      CustomerInfo customerInfo =
          await Purchases.purchaseProduct("appgpt_monthly");
      await prefs.setBool("isPaid", true);
    } catch (e) {
      showFailDialog();
    }
  }

  showWaitingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            title: Text("loading"),
            content: Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 66, 103, 178),
              ),
            ),
          );
        });
  }

  showFailDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Payment Failed"),
            content: const Text("Payment Failed! Please Try Again Later"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Ok"),
              ),
            ],
          );
        });
  }

  showSuccessDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Payment Success"),
            content: const Text("Payment Done! Thank You for your Purchase"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (ctx) => const HomePage()),
                      (route) => false);
                },
                child: const Text("Ok"),
              ),
            ],
          );
        });
  }
}




// Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               color: const Color.fromARGB(255, 66, 103, 178),
//               height: MediaQuery.of(context).padding.top,
//             ),
//             IconButton(
//               icon: const Icon(Icons.cancel),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               color: Colors.red,
//             ),
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text(
//                 "Unrestricted Access!",
//                 style: TextStyle(
//                   fontSize: 25,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.only(left: 8.0),
//               child: Text("Join Premium Users"),
//             ),
//             SizedBox(
//               height: size.height * 0.03,
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Container(),
//                 ),
//                 SizedBox(
//                   width: size.width * 0.2,
//                   child: const Text(
//                     "Regular",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 SizedBox(
//                   width: size.width * 0.2,
//                   child: const Text(
//                     "Premium",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//             Card(
//               margin: const EdgeInsets.all(8.0),
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.smart_toy,
//                           size: 20,
//                           color: Color.fromARGB(255, 66, 103, 178),
//                         ),
//                         const SizedBox(
//                           width: 5,
//                         ),
//                         const Expanded(
//                           child: Text(
//                             "Best Ai Model",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         SizedBox(
//                           width: size.width * 0.2,
//                           child: const Icon(
//                             Icons.check_circle_rounded,
//                             color: Colors.green,
//                           ),
//                         ),
//                         SizedBox(
//                           width: size.width * 0.2,
//                           child: const Icon(
//                             Icons.check_circle_rounded,
//                             color: Colors.green,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: size.height * 0.01,
//                     ),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.chat,
//                           size: 20,
//                           color: Color.fromARGB(255, 66, 103, 178),
//                         ),
//                         const SizedBox(
//                           width: 5,
//                         ),
//                         const Expanded(
//                           child: Text(
//                             "Unlimited Chats",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         SizedBox(
//                           width: size.width * 0.2,
//                           child: const Icon(
//                             Icons.cancel,
//                             color: Colors.red,
//                           ),
//                         ),
//                         SizedBox(
//                           width: size.width * 0.2,
//                           child: const Icon(
//                             Icons.check_circle_rounded,
//                             color: Colors.green,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: size.height * 0.01,
//                     ),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.tv,
//                           size: 20,
//                           color: Color.fromARGB(255, 66, 103, 178),
//                         ),
//                         const SizedBox(
//                           width: 5,
//                         ),
//                         const Expanded(
//                           child: Text(
//                             "Ad-Free Experience",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         SizedBox(
//                           width: size.width * 0.2,
//                           child: const Icon(
//                             Icons.cancel,
//                             color: Colors.red,
//                           ),
//                         ),
//                         SizedBox(
//                           width: size.width * 0.2,
//                           child: const Icon(
//                             Icons.check_circle_rounded,
//                             color: Colors.green,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: size.height * 0.01,
//                     ),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.zoom_in,
//                           size: 20,
//                           color: Color.fromARGB(255, 66, 103, 178),
//                         ),
//                         const SizedBox(
//                           width: 5,
//                         ),
//                         const Expanded(
//                           child: Text(
//                             "App Widget Access",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         SizedBox(
//                           width: size.width * 0.2,
//                           child: const Icon(
//                             Icons.cancel,
//                             color: Colors.red,
//                           ),
//                         ),
//                         SizedBox(
//                           width: size.width * 0.2,
//                           child: const Icon(
//                             Icons.check_circle_rounded,
//                             color: Colors.green,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: size.height * 0.01,
//                     ),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.star,
//                           size: 20,
//                           color: Color.fromARGB(255, 66, 103, 178),
//                         ),
//                         const SizedBox(
//                           width: 5,
//                         ),
//                         const Expanded(
//                           child: Text(
//                             "VIP Customer Support",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         SizedBox(
//                           width: size.width * 0.2,
//                           child: const Icon(
//                             Icons.cancel,
//                             color: Colors.red,
//                           ),
//                         ),
//                         SizedBox(
//                           width: size.width * 0.2,
//                           child: const Icon(
//                             Icons.check_circle_rounded,
//                             color: Colors.green,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.centerRight,
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 8.0),
//                 child: Text(
//                   "$price/Month",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: size.height * 0.07,
//             ),
//             Align(
//               child: ElevatedButton(
//                 onPressed: getOffers,
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(
//                         Radius.circular(20),
//                       ),
//                     ),
//                     padding: const EdgeInsets.all(10)),
//                 child: const Text("Continue", style: TextStyle(fontSize: 30)),
//               ),
//             ),
//           ],
//         ),