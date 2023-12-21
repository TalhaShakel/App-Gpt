import 'dart:convert';
import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatgpt/models/model.dart';
import 'package:chatgpt/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Subscritionpage.dart';
import '../../models/chat.dart';
import '../../network/api_services.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String messagePrompt = '';
  int tokenValue = 500;
  List<Chat> chatList = [];
  List<Chat> chatToStore = [];
  List<Model> modelsList = [];
  late SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    getModels();
    getData();
    //initPrefs();
  }

  void getModels() async {
    modelsList = await submitGetModelsForm(context: context);
  }

  List<DropdownMenuItem<String>> get models {
    List<DropdownMenuItem<String>> menuItems =
        List.generate(modelsList.length, (i) {
      return DropdownMenuItem(
        value: modelsList[i].id,
        child: Text(modelsList[i].id),
      );
    });
    return menuItems;
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    tokenValue = prefs.getInt("token") ?? 500;
  }

  TextEditingController mesageController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 103, 178),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _topChat(),
                _bodyChat(),
                Visibility(
                  visible: isLoading,
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(111, 158, 158, 158),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: const SpinKitThreeBounce(
                            color: Color.fromARGB(255, 66, 103, 178),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 75,
                )
              ],
            ),
            _formChat(),
          ],
        ),
      ),
    );
  }

  void saveData(int value) {
    prefs.setInt("token", value);
  }

  getData() async {
    prefs = await SharedPreferences.getInstance();
    String date = DateTime.now().toString().split(" ")[0];
    String oldChat = prefs.getString("date: $date") ?? '';
    print("OldChat: $oldChat");
    if (oldChat != '') {
      final List<dynamic> jsonList = json.decode(oldChat);
      chatToStore = jsonList.map((json) => Chat.fromJson(json)).toList();
      print("chatToStore: $chatToStore");
      setState(() {});
    }
    //return prefs.getInt("token") ?? 1;
  }

  _topChat() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const Text(
                'App GPT',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "Coins: $coins",
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     showModalBottomSheet<void>(
          //       context: context,
          //       backgroundColor: Colors.transparent,
          //       builder: (BuildContext context) {
          //         return StatefulBuilder(
          //             builder: (BuildContext context, StateSetter state) {
          //           return Container(
          //             height: 400,
          //             decoration: const BoxDecoration(
          //                 color: Colors.white,
          //                 borderRadius: BorderRadius.only(
          //                   topLeft: Radius.circular(20),
          //                   topRight: Radius.circular(20),
          //                 )),
          //             child: Column(
          //               mainAxisAlignment: MainAxisAlignment.start,
          //               mainAxisSize: MainAxisSize.min,
          //               children: <Widget>[
          //                 const Padding(
          //                   padding: EdgeInsets.symmetric(vertical: 15.0),
          //                   child: Text(
          //                     'Settings',
          //                     style: TextStyle(
          //                       color: Color(0xFFF75555),
          //                       fontWeight: FontWeight.bold,
          //                     ),
          //                   ),
          //                 ),
          //                 Divider(
          //                   color: Colors.grey.shade700,
          //                 ),
          //                 Padding(
          //                   padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
          //                   child: DropdownButtonFormField(
          //                     items: models,
          //                     borderRadius: const BorderRadius.only(),
          //                     focusColor: Colors.amber,
          //                     onChanged: (String? s) {},
          //                     decoration: const InputDecoration(
          //                         hintText: "Select Model"),
          //                   ),
          //                 ),
          //                 const Padding(
          //                   padding: EdgeInsets.fromLTRB(20, 20, 20, 2),
          //                   child: Align(
          //                       alignment: Alignment.topLeft,
          //                       child: Text("Token")),
          //                 ),
          //                 Slider(
          //                   min: 0,
          //                   max: 1000,
          //                   activeColor: const Color(0xFFE58500),
          //                   inactiveColor:
          //                       const Color.fromARGB(255, 230, 173, 92),
          //                   value: tokenValue.toDouble(),
          //                   onChanged: (value) {
          //                     state(() {
          //                       tokenValue = value.round();
          //                     });
          //                   },
          //                 ),
          //                 Padding(
          //                   padding: const EdgeInsets.symmetric(vertical: 10.0),
          //                   child: Row(
          //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //                     children: [
          //                       InkWell(
          //                         onTap: () {
          //                           Navigator.of(context).pop(false);
          //                         },
          //                         child: Container(
          //                           width:
          //                               MediaQuery.of(context).size.width / 2.2,
          //                           decoration: BoxDecoration(
          //                             color: Colors.grey.shade200,
          //                             borderRadius: BorderRadius.circular(40),
          //                           ),
          //                           padding: const EdgeInsets.symmetric(
          //                               vertical: 15, horizontal: 20),
          //                           child: const Center(
          //                             child: Text(
          //                               'Cancel',
          //                               style: TextStyle(
          //                                 color: Colors.black,
          //                                 fontWeight: FontWeight.bold,
          //                               ),
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //                       InkWell(
          //                         onTap: () {
          //                           saveData(tokenValue);
          //                           Navigator.of(context).pop(false);
          //                         },
          //                         child: Container(
          //                           width:
          //                               MediaQuery.of(context).size.width / 2.2,
          //                           decoration: BoxDecoration(
          //                             color: const Color(0xFFE58500),
          //                             borderRadius: BorderRadius.circular(40),
          //                           ),
          //                           padding: const EdgeInsets.symmetric(
          //                               vertical: 15, horizontal: 20),
          //                           child: const Center(
          //                             child: Text(
          //                               'Save',
          //                               style: TextStyle(
          //                                 color: Colors.black,
          //                                 fontWeight: FontWeight.bold,
          //                               ),
          //                             ),
          //                           ),
          //                         ),
          //                       )
          //                     ],
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           );
          //         });
          //       },
          //     );
          //   },
          //   child: const Icon(
          //     Icons.more_vert_rounded,
          //     size: 25,
          //     color: Colors.white,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget chats() {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: chatList.length,
      itemBuilder: (context, index) => _itemChat(
        chat: chatList[index].chat,
        message: chatList[index].msg,
      ),
    );
  }

  Widget _bodyChat() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(45), topRight: Radius.circular(45)),
          color: Colors.white,
        ),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: chatList.length,
          itemBuilder: (context, index) => _itemChat(
            chat: chatList[index].chat,
            message: chatList[index].msg,
          ),
        ),
      ),
    );
  }

  _itemChat({required int chat, required String message}) {
    return Row(
      mainAxisAlignment:
          chat == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: chat == 0
                  ? const Color.fromARGB(255, 0, 106, 255)
                  : const Color.fromARGB(111, 158, 158, 158),
              borderRadius: chat == 0
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
            ),
            child: chatWidget(message, chat),
          ),
        ),
        if (chat == 1)
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: message)).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Text Copied"),
                  ),
                );
              });
            },
            child: const CircleAvatar(
              child: Icon(
                Icons.copy,
              ),
            ),
          ),
      ],
    );
  }

  Widget chatWidget(String text, int chat) {
    return SizedBox(
      width: 250.0,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        child: AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              text.replaceFirst('\n\n', ''),
              textStyle: TextStyle(
                color: chat == 0 ? Colors.white : Colors.black,
              ),
            ),
          ],
          repeatForever: false,
          totalRepeatCount: 1,
        ),
      ),
    );
  }

  Widget _formChat() {
    return Positioned(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          color: Colors.white,
          child: TextField(
            controller: mesageController,
            decoration: InputDecoration(
              hintText: 'Type your message...',
              suffixIcon: InkWell(
                onTap: (() async {
                  isLoading = true;
                  final prefs = await SharedPreferences.getInstance();
                  // int searchCount =
                  //     prefs.getInt(DateTime.now().toString().split(" ")[0]) ??
                  //         0;
                  // bool isPaid = prefs.getBool("isPaid") ?? false;
                  // log("isPaid: $isPaid");
                  if (coins - 1 >= 0) {
                    messagePrompt = mesageController.text.toString();
                    setState(() {
                      chatList.add(Chat(msg: messagePrompt, chat: 0));
                      mesageController.clear();
                    });
                    submitGetChatsForm(
                      context: context,
                      prompt: messagePrompt,
                      tokenValue: tokenValue,
                    ).then((value) async {
                      log("here");
                      isLoading = false;
                      chatList.addAll(value);
                      chatToStore.addAll(chatList);
                      final dataToStore = jsonEncode(
                          chatToStore.map((e) => e.toJson()).toList());
                      print(dataToStore);
                      final date = DateTime.now().toString().split(" ")[0];
                      await prefs.setString("date: $date", dataToStore);
                      List<String> list = prefs.getStringList("oldChats") ?? [];
                      if (!list.contains("date: $date")) {
                        list.add("date: $date");
                        await prefs.setStringList("oldChats", list);
                      }
                      setState(() {});
                    });
                    coins--;
                    await prefs.setInt("coins", coins);
                    setState(() {});
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const Subscritionpage(),
                      ),
                    );
                    // if (searchCount <= 15) {
                    //   await prefs.setInt(
                    //       DateTime.now().toString().split(" ")[0],
                    //       searchCount + 1);

                    //   messagePrompt = mesageController.text.toString();
                    //   setState(() {
                    //     chatList.add(Chat(msg: messagePrompt, chat: 0));
                    //     mesageController.clear();
                    //   });
                    //   submitGetChatsForm(
                    //     context: context,
                    //     prompt: messagePrompt,
                    //     tokenValue: tokenValue,
                    //   ).then((value) {
                    //     log("here");
                    //     isLoading = false;
                    //     chatList.addAll(value);
                    //     setState(() {});
                    //   });
                    //   setState(() {});
                    // } else {
                    //   Navigator.of(context).push(
                    //     MaterialPageRoute(
                    //       builder: (ctx) => const Subscritionpage(),
                    //     ),
                    //   );
                    // }
                  }
                }),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: const Color(0xFF292B4D)),
                  padding: const EdgeInsets.all(14),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              filled: true,
              fillColor: Colors.blueGrey.shade50,
              labelStyle: const TextStyle(fontSize: 12),
              contentPadding: const EdgeInsets.all(20),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey.shade50),
                borderRadius: BorderRadius.circular(25),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey.shade50),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
