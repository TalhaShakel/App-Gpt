import 'package:chatgpt/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShowHistoryFromChat extends StatefulWidget {
  const ShowHistoryFromChat({super.key, required this.jsonList});
  final List<dynamic> jsonList;

  @override
  State<ShowHistoryFromChat> createState() => _ShowHistoryFromChatState();
}

class _ShowHistoryFromChatState extends State<ShowHistoryFromChat> {
  List<Chat> chatList = [];
  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() {
    print(widget.jsonList);
    chatList = widget.jsonList.map((json) => Chat.fromJson(json)).toList();
    print(chatList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jsonList[0]['msg']),
        centerTitle: true,
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
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
      ),
    );
  }

  _itemChat({required int chat, required String message}) {
    print(message);
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
          child: Text(
            text.replaceFirst('\n\n', ''),
            style: TextStyle(
              color: chat == 0 ? Colors.white : Colors.black,
            ),
          )),
    );
  }
}
