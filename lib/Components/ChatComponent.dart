import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Singletons/User.dart';


bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class ChatComponent extends StatefulWidget {
  const ChatComponent({Key? key}) : super(key: key);

  @override
  _ChatComponentState createState() => _ChatComponentState();
}

class _ChatComponentState extends State<ChatComponent> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          )
        ]),
        width: screenWidth * 0.7,
        height: screenHeight * 0.8,
        child: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.1, right: screenWidth * 0.1),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection("Chats")
                        .doc(User.user.getHostel())
                        .collection(User.user.getHostel())
                        .orderBy("timestamp", descending: true)
                        .limit(64)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      } else {
                        List<QueryDocumentSnapshot<Map<String, dynamic>>> messages = snapshot.data!.docs;
                        return ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.only(left: 16, right: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  messages[index].data()["from"] != User.user.getEmailAddress()
                                      ? Row(
                                    mainAxisAlignment:
                                    messages[index].data()["from"] == User.user.getEmailAddress()
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: screenWidth * 0.35,
                                        // padding: EdgeInsets.all(8),
                                        child: Text(messages[index].data()["name"]),
                                      ),
                                    ],
                                  )
                                      : Container(),
                                  Row(
                                    mainAxisAlignment: messages[index].data()["from"] == User.user.getEmailAddress()
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: screenWidth * 0.35,
                                        padding: EdgeInsets.all(8),
                                        child: Text(messages[index].data()["message"]),
                                        decoration: BoxDecoration(
                                          color: messages[index].data()["from"] == User.user.getEmailAddress()
                                              ? Color.fromARGB(0x50, 0xFF, 0xA6, 0x3A)
                                              : Color.fromARGB(0xFF, 0xF0, 0xF3, 0xF6),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                            bottomRight: messages[index].data()["from"] == User.user.getEmailAddress()
                                                ? Radius.circular(0)
                                                : Radius.circular(16),
                                            bottomLeft: messages[index].data()["from"] == User.user.getEmailAddress()
                                                ? Radius.circular(16)
                                                : Radius.circular(0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 4, bottom: 4),
                                    child: Row(
                                      mainAxisAlignment: messages[index].data()["from"] == User.user.getEmailAddress()
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Text(DateFormat("hh:mm a")
                                            .format(DateTime.parse(messages[index].data()["timestamp"]).toLocal())),
                                        isSameDate(DateTime.now().toLocal(),
                                            DateTime.parse(messages[index].data()["timestamp"]).toLocal())
                                            ? Text("")
                                            : Text(", "),
                                        isSameDate(DateTime.now().toLocal(),
                                            DateTime.parse(messages[index].data()["timestamp"]).toLocal())
                                            ? Text("")
                                            : Text(DateFormat("yyyy-MM-dd")
                                            .format(DateTime.parse(messages[index].data()["timestamp"]).toLocal())),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                height: screenHeight * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: screenWidth * 0.4,
                      child: TextFormField(
                        cursorColor: Colors.grey,
                        controller: _messageController,
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: "Type a Message",
                          fillColor: Colors.grey.shade200,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                              width: 0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                              width: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.05,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_messageController.text.isNotEmpty) {
                            FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
                              String message = _messageController.text;
                              _messageController.text = "";

                              FirebaseFirestore.instance.collection("Chats").doc(User.user.getHostel()).set({
                                "updated": DateTime.now().toUtc().toString(),
                              });

                              transaction.set(
                                FirebaseFirestore.instance
                                    .collection("Chats")
                                    .doc(User.user.getHostel())
                                    .collection(User.user.getHostel())
                                    .doc(DateTime.now().toUtc().toString()),
                                {
                                  "from": User.user.getEmailAddress(),
                                  "name": User.user.getName(),
                                  "message": message,
                                  "timestamp": DateTime.now().toUtc().toString(),
                                },
                              );
                            }).then((value) {
                              _messageController.text = "";
                            });
                          }
                        },
                        child: Icon(Icons.send_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

