import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<List<Map<String, String>>> getFeedback() async {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> data = (await FirebaseFirestore.instance
          .collection("Feedbacks")
          .doc("feedbacks")
          .collection("Feedbacks")
          .orderBy(
            "timestamp",
            descending: true,
          )
          .get())
      .docs;

  List<Map<String, String>> result = List.empty(growable: true);
  for (QueryDocumentSnapshot<Map<String, dynamic>> iter in data) {
    result.add(iter.data().map((String key, dynamic value) {
      return MapEntry(key, value as String);
    }));
  }

  return result;
}

class FeedbackComponent extends StatefulWidget {
  const FeedbackComponent({Key? key}) : super(key: key);

  @override
  _FeedbackComponentState createState() => _FeedbackComponentState();
}

class _FeedbackComponentState extends State<FeedbackComponent> {
  final ScrollController _controller = ScrollController();
  final ScrollPhysics _physics = const ScrollPhysics();
  Future<List<Map<String, String>>> feedbacks = getFeedback();

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
        child: SingleChildScrollView(
          child: FutureBuilder<List<Map<String, String>>>(
            future: feedbacks,
            builder: (BuildContext context, AsyncSnapshot<List<Map<String, String>>> snapshot) {
              if (!snapshot.hasData) {
                return SizedBox(
                  width: screenWidth * 0.7,
                  height: screenHeight * 0.8,
                  child: const Center(child: CircularProgressIndicator.adaptive()),
                );
              }

              List<Map<String, String>> data = snapshot.data!;
              return SizedBox(
                width: screenWidth * 0.7,
                height: screenHeight * 0.8,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: 16,
                    left: screenWidth * 0.05,
                    right: screenWidth * 0.05,
                  ),
                  child: ListView.builder(
                    controller: _controller,
                    physics: _physics,
                    itemCount: data.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      final TextEditingController controller = TextEditingController(text: data[index]["message"]!);
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: 8.0,
                          top: 8.0,
                          right: screenWidth * 0.05,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            data[index]["from"]!.isEmpty || data[index]["from"]!.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                                    child: Text(
                                      "Anonymous Complaint",
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      "${data[index]["name"]!}\n${data[index]["from"]!}",
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                DateFormat("dd-MM-yyyy hh:mm a")
                                    .format(DateTime.parse(data[index]["timestamp"]!).toLocal()),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  enabledBorder: const OutlineInputBorder(),
                                  disabledBorder: const OutlineInputBorder(),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(0xAF, 0xFF, 0xA6, 0x3A),
                                      width: 3,
                                    ),
                                  ),
                                  labelStyle: Theme.of(context).textTheme.labelSmall,
                                ),
                                controller: controller,
                                readOnly: true,
                                minLines: 4,
                                maxLines: 8,
                              ),
                            ),
                            data[index]["from"]!.isEmpty || data[index]["from"]!.isEmpty
                                ? Container(padding: const EdgeInsets.only(bottom: 12),)
                                : Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                      children: [
                                        TextButton.icon(
                                          label: const Padding(
                                            padding: EdgeInsets.only(top: 6.0),
                                            child: Text("Reply via Email"),
                                          ),
                                          icon: const Icon(Icons.mail_outline),
                                          onPressed: () {
                                            List<String> messageSplit = data[index]["message"]!.split("\n");
                                            String messageFormatted = "\n\n----------- ORIGINAL COMPLAINT -----------\n";
                                            for (String part in messageSplit) {
                                              messageFormatted += "> $part\n";
                                            }

                                            messageFormatted = Uri.encodeComponent(messageFormatted);
                                            launchUrlString("mailto:${data[index]["from"]}?body=$messageFormatted");
                                          },
                                        )
                                      ],
                                    ),
                                ),
                            const Divider(
                              thickness: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
