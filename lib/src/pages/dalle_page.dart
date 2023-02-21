import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatgpt/Subscritionpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/images.dart';
import '../../network/api_services.dart';
import 'full_screen.dart';

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
  final double _value = 10;
  List<Images> imagesList = [];
  late SharedPreferences prefs;
  bool isPaid = false;
  int searchCount = 0;

  @override
  void initState() {
    super.initState();
    initPrefs();
    imagesAvailable = imagesList.isNotEmpty ? true : false;
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    isPaid = prefs.getBool("isPaid") ?? false;
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
          'App GPT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
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
                    ? MasonryGridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        itemCount: imagesList.length > 4 && isPaid ? 4 : 2,
                        crossAxisSpacing: 10,
                        semanticChildCount: 6,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                CustomPageRoute(
                                  builder: (context) =>
                                      ImageView(imgPath: imagesList[index].url),
                                ),
                              );
                            },
                            child: Hero(
                              tag: imagesList[index].url,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6)),
                                height: index % 2 == 0 ? 180 : 250,
                                width: MediaQuery.of(context).size.width / 3,
                                child: ImageCard(
                                  imageData: imagesList[index].url,
                                ),
                              ),
                            ),
                          );
                        },
                      )
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
              if (searchController.text == '') return;
              int searchCount = prefs.getInt(
                      "${DateTime.now().toString().split(" ")[0]}-image") ??
                  0;
              log("$searchCount");
              if (isPaid && searchCount < 4) {
                await prefs.setInt(
                    "${DateTime.now().toString().split(" ")[0]}-image",
                    searchCount + 1);
                setState(() {
                  searching = true;
                });
                imagesList = await submitGetImagesForm(
                  context: context,
                  prompt: searchController.text.toString(),
                  n: _value.round(),
                );
                setState(() {
                  imagesAvailable = imagesList.isNotEmpty ? true : false;
                });
              } else if (isPaid && searchCount >= 4) {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: const Text("Limit Reached"),
                        content:
                            const Text("You have Reached Daily search limit"),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Ok"),
                          ),
                        ],
                      );
                    });
              } else {
                if (!isPaid && searchCount < 2) {
                  await prefs.setInt(
                      "${DateTime.now().toString().split(" ")[0]}-image",
                      searchCount + 1);
                  setState(() {
                    searching = true;
                  });
                  imagesList = await submitGetImagesForm(
                    context: context,
                    prompt: searchController.text.toString(),
                    n: _value.round(),
                  );
                  setState(() {
                    imagesAvailable = imagesList.isNotEmpty ? true : false;
                  });
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const Subscritionpage(),
                    ),
                  );
                }
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
