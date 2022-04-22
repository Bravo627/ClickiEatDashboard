import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> getHostelsName() async {
  FirebaseFirestore instance = FirebaseFirestore.instance;
  DocumentSnapshot<Map<String, dynamic>> snapshot = await instance.collection("Hostels").doc("names").get();
  List<dynamic> names = snapshot.get("names");

  return names.map((e) {
    return e.toString();
  }).toList();
}
