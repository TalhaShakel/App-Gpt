import 'dart:convert';

import 'package:chatgpt/src/pages/showchatFromHistory.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistory extends StatefulWidget {
  const ChatHistory({super.key});

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  List<String> oldChats = [];
  late SharedPreferences prefs;
  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    prefs = await SharedPreferences.getInstance();
    //prefs.clear();
    oldChats = prefs.getStringList("oldChats") ?? [];
    print("oldchats: $oldChats ");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Old Chats"),
        centerTitle: true,
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: oldChats.isEmpty
            ? const Center(
                child: Text(
                "No Old Chats...",
                style: TextStyle(
                  fontSize: 20,
                ),
              ))
            : ListView.builder(
                itemCount: oldChats.length,
                itemBuilder: (ctx, index) {
                  print("this is: ${oldChats[index]}");
                  String oldChat = prefs.getString(oldChats[index]) ?? '';
                  final List<dynamic> jsonList = json.decode(oldChat);
                  print(jsonList[0]['msg']);
                  //chatList = jsonList.map((json) => Chat.fromJson(json)).toList();
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) =>
                              ShowHistoryFromChat(jsonList: jsonList),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${jsonList[0]['msg']}",
                            style: TextStyle(
                                fontSize: size.width * 0.07,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
