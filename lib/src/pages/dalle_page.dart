import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatgpt/Subscritionpage.dart';
import 'package:chatgpt/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/images.dart';
import '../../network/api_services.dart';

class DallePage extends StatefulWidget {
  const DallePage({
    super.key,
  });

  @override
  State<DallePage> createState() => _DallePageState();
}

class _DallePageState extends State<DallePage> {
  TextEditingController searchController = TextEditingController();
  bool imagesAvailable = false;
  bool searching = false;
  final double _value = 1;
  List<Images> imagesList = [];
  late SharedPreferences prefs;
  //bool isPaid = false;
  //int searchCount = 0;

  @override
  void initState() {
    super.initState();
    initPrefs();
    imagesAvailable = imagesList.isNotEmpty ? true : false;
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    //isPaid = prefs.getBool("isPaid") ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 103, 178),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 103, 178),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 22,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'AppGPT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Center(
              child: Text(
            "Coins: $coins",
            style: const TextStyle(
              fontSize: 20,
            ),
          )),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 5,
          ),
          child: Column(
            children: [
              _formChat(),
              Expanded(
                child: imagesAvailable
                    ? imageView(imagesList[0].url)
                    : Center(
                        child: searchingWidget(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchingWidget() {
    if (searching) {
      return const CircularProgressIndicator(
        color: Color(0xFF292B4D),
      );
    } else {
      return const Text(
        "Search for any image",
        style: TextStyle(color: Colors.white),
      );
    }
  }

  Widget _formChat() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Enter Your Query...',
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: InkWell(
            onTap: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              if (searchController.text == '') return;
              // int searchCount = prefs.getInt(
              //         "${DateTime.now().toString().split(" ")[0]}-image") ??
              //     0;
              // log("$searchCount");
              if (coins - 2 >= 0) {
                // await prefs.setInt(
                //     "${DateTime.now().toString().split(" ")[0]}-image",
                //     searchCount + 1);
                setState(() {
                  searching = true;
                });
                imagesList = await submitGetImagesForm(
                  context: context,
                  prompt: searchController.text.toString(),
                  n: 1,
                );
                coins = coins - 2;
                await prefs.setInt("coins", coins);
                setState(() {
                  imagesAvailable = imagesList.isNotEmpty ? true : false;
                });
              } else {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: const Text("Limit Reached"),
                        content:
                            const Text("You have Reached Daily search limit"),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => const Subscritionpage(),
                                ),
                              );
                            },
                            child: const Text("Ok"),
                          ),
                        ],
                      );
                    });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF292B4D),
              ),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(5),
              child: const Icon(
                Icons.search,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          labelStyle: const TextStyle(fontSize: 12),
          contentPadding: const EdgeInsets.all(20),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade100,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade100,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  imageView(String path) {
    List<String> images = prefs.getStringList("images") ?? [];
    if (!images.contains(path)) {
      images.add(path);
      prefs.setStringList("images", images);
    }
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.hardEdge,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: CachedNetworkImage(
              imageUrl: path,
              placeholder: (context, url) => Container(
                    color: const Color(0xfff5f8fd),
                  ),
              fit: BoxFit.cover),
        ),
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                  onTap: () async {
                    await ImageDownloader.downloadImage(path);
                  },
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xff1C1B1B).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24, width: 1),
                            borderRadius: BorderRadius.circular(40),
                            gradient: const LinearGradient(
                                colors: [Color(0x36FFFFFF), Color(0x0FFFFFFF)],
                                begin: FractionalOffset.topLeft,
                                end: FractionalOffset.bottomRight)),
                        child: const Text(
                          "Download",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 5,
              )
            ],
          ),
        )
      ],
    );
  }
}

class ImageCard extends StatelessWidget {
  const ImageCard({super.key, required this.imageData});

  final String imageData;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.0),
      child: CachedNetworkImage(
        imageUrl: imageData,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
            height: 150,
            width: 150,
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade100,
              highlightColor: Colors.white,
              child: Container(
                height: 220,
                width: 130,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4)),
              ),
            )),
      ),
    );
  }
}

class CustomPageRoute extends MaterialPageRoute {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  CustomPageRoute({builder}) : super(builder: builder);
}
