import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImagesHistory extends StatefulWidget {
  const ImagesHistory({super.key});

  @override
  State<ImagesHistory> createState() => _ImagesHistoryState();
}

class _ImagesHistoryState extends State<ImagesHistory> {
  List<String> images = [];
  late SharedPreferences prefs;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    prefs = await SharedPreferences.getInstance();
    images = prefs.getStringList("images") ?? [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Old Images"),
        centerTitle: true,
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: images.isEmpty
            ? const Center(
                child: Text("No Data..."),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: images.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisExtent: size.height * 0.4),
                  itemBuilder: (context, index) {
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
                              imageUrl: images[index],
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
                                    await ImageDownloader.downloadImage(
                                        images[index]);
                                  },
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff1C1B1B)
                                              .withOpacity(0.8),
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        height: 50,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white24,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            gradient: const LinearGradient(
                                                colors: [
                                                  Color(0x36FFFFFF),
                                                  Color(0x0FFFFFFF)
                                                ],
                                                begin: FractionalOffset.topLeft,
                                                end: FractionalOffset
                                                    .bottomRight)),
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
                  },
                ),
              ),
      ),
    );
  }
}
