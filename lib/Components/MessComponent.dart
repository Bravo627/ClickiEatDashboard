import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Singletons/MessMenu.dart';

class MessMenuComponent extends StatefulWidget {
  const MessMenuComponent({Key? key}) : super(key: key);

  @override
  _MessMenuComponentState createState() => _MessMenuComponentState();
}

class _MessMenuComponentState extends State<MessMenuComponent> with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = [
    Tab(text: 'Monday'),
    Tab(text: 'Tuesday'),
    Tab(text: 'Wednesday'),
    Tab(text: 'Thursday'),
    Tab(text: 'Friday'),
    Tab(text: 'Saturday'),
    Tab(text: 'Sunday'),
  ];

  late TabController tabController;
  static Future<Map<String, List<String>>> messMenu = MessMenu.instance;
  static Map<String, List<TextEditingController>> messMenuEditing = Map<String, List<TextEditingController>>();
  bool isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: messMenu,
      builder: (BuildContext context, AsyncSnapshot<Map<String, List<String>>> snapshot) {
        if (snapshot.hasData) {
          for (MapEntry<String, List<String>> entry in snapshot.data!.entries) {
            if (!messMenuEditing.containsKey(entry.key)) {
              messMenuEditing[entry.key] = [
                TextEditingController(text: entry.value[0]),
                TextEditingController(text: entry.value[1]),
                TextEditingController(text: entry.value[2])
              ];
            }
          }

          return Center(
            child: SizedBox(
              width: screenWidth * 0.7,
              height: screenHeight * 0.8,
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  )
                ]),
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.1, right: screenWidth * 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TabBar(
                        controller: tabController,
                        labelColor: Theme.of(context).textTheme.displayMedium!.color,
                        indicatorColor: Theme.of(context).textTheme.displayMedium!.color,
                        unselectedLabelColor: Colors.black,
                        tabs: myTabs,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.05),
                        child: SizedBox(
                          height: screenHeight * 0.5,
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              menuTable(snapshot.data!, messMenuEditing, 0, isEditing, isLoading),
                              menuTable(snapshot.data!, messMenuEditing, 1, isEditing, isLoading),
                              menuTable(snapshot.data!, messMenuEditing, 2, isEditing, isLoading),
                              menuTable(snapshot.data!, messMenuEditing, 3, isEditing, isLoading),
                              menuTable(snapshot.data!, messMenuEditing, 4, isEditing, isLoading),
                              menuTable(snapshot.data!, messMenuEditing, 5, isEditing, isLoading),
                              menuTable(snapshot.data!, messMenuEditing, 6, isEditing, isLoading),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Text("Edit: "),
                          Switch(
                            value: isEditing,
                            onChanged: (newValue) async {
                              if (newValue == false) {
                                setState(() {
                                  isLoading = true;
                                });

                                await updateMessMenuToFirebase(messMenuEditing);
                                MessMenu.reset();
                                messMenu = MessMenu.instance;
                                await messMenu;
                              }

                              setState(() {
                                isLoading = false;
                                isEditing = newValue;
                              });
                            },
                          ),
                          (isLoading) ? const CircularProgressIndicator.adaptive() : Container(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
      },
    );
  }

  String indexToDay(int index) {
    switch (index) {
      case 0:
        return "monday";
      case 1:
        return "tuesday";
      case 2:
        return "wednesday";
      case 3:
        return "thursday";
      case 4:
        return "friday";
      case 5:
        return "saturday";
      case 6:
        return "sunday";
      default:
        return "";
    }
  }

  Future<void> updateMessMenuToFirebase(Map<String, List<TextEditingController>> editingData) async {
    Map<String, List<String>> mappedData = editingData.map((key, value) {
      return MapEntry(
        key,
        value.map((e) {
          return e.text;
        }).toList(),
      );
    });

    for (MapEntry<String, List<String>> entry in mappedData.entries) {
      await FirebaseFirestore.instance.collection("MessMenu").doc(entry.key).update({"meals": entry.value});
    }
  }

  List<String> setSize(List<String> list, int size) {
    if (list.length < size) {
      for (int i = list.length; i < size; i++) {
        list.add("");
      }
    } else if (list.length > size) {
      list.length = size;
    }

    return list;
  }

  DataTable menuTable(Map<String, List<String>> data, Map<String, List<TextEditingController>> editingData, int index,
      bool isEditing, bool isLoading) {
    if (isEditing) {
      return DataTable(
        border: TableBorder(
          top: const BorderSide(),
          bottom: const BorderSide(),
          left: const BorderSide(),
          right: const BorderSide(),
          horizontalInside: const BorderSide(),
          verticalInside: const BorderSide(),
          borderRadius: BorderRadius.circular(16),
        ),
        columns: const [
          DataColumn(
            label: Text(
              "Meal",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          DataColumn(
            label: Text(
              "Comma Separated Meals",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ],
        rows: [
          DataRow(cells: [
            const DataCell(
              Text(
                "Breakfast",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(
              TextField(
                readOnly: isLoading,
                controller: editingData[indexToDay(index)]![0],
              ),
            ),
          ]),
          DataRow(cells: [
            const DataCell(
              Text(
                "Lunch",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(
              TextField(
                readOnly: isLoading,
                controller: editingData[indexToDay(index)]![1],
              ),
            ),
          ]),
          DataRow(cells: [
            const DataCell(
              Text(
                "Dinner",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(
              TextField(
                readOnly: isLoading,
                controller: editingData[indexToDay(index)]![2],
              ),
            ),
          ]),
        ],
      );
    }

    return DataTable(
      border: TableBorder(
        top: const BorderSide(),
        bottom: const BorderSide(),
        left: const BorderSide(),
        right: const BorderSide(),
        horizontalInside: const BorderSide(),
        verticalInside: const BorderSide(),
        borderRadius: BorderRadius.circular(16),
      ),
      columns: const [
        DataColumn(
          label: Text(
            "Meal",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            overflow: TextOverflow.clip,
          ),
        ),
        DataColumn(
          label: Text(
            "Item #1",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            overflow: TextOverflow.clip,
          ),
        ),
        DataColumn(
          label: Text(
            "Item #2",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            overflow: TextOverflow.clip,
          ),
        ),
        DataColumn(
          label: Text(
            "Item #3",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            overflow: TextOverflow.clip,
          ),
        ),
        DataColumn(
          label: Text(
            "Item #4",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            overflow: TextOverflow.clip,
          ),
        ),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(
            Text(
              "Breakfast",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ...(setSize(data[indexToDay(index)]![0].split(","), 4).map((meal) {
            return DataCell(Text(meal));
          }).toList()),
        ]),
        DataRow(cells: [
          const DataCell(
            Text(
              "Lunch",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ...(setSize(data[indexToDay(index)]![1].split(","), 4).map((meal) {
            return DataCell(Text(meal));
          }).toList()),
        ]),
        DataRow(cells: [
          const DataCell(
            Text(
              "Dinner",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ...(setSize(data[indexToDay(index)]![2].split(","), 4).map((meal) {
            return DataCell(Text(meal));
          }).toList()),
        ]),
      ],
    );
  }
}
