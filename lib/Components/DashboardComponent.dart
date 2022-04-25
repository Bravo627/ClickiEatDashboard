import '../Singletons/MessMenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

String monthIntToString(int month) {
  switch (month) {
    case 01:
      return "january";
    case 02:
      return "february";
    case 03:
      return "march";
    case 04:
      return "april";
    case 05:
      return "may";
    case 06:
      return "june";
    case 07:
      return "july";
    case 08:
      return "august";
    case 09:
      return "september";
    case 10:
      return "october";
    case 11:
      return "november";
    case 12:
      return "december";
  }

  return "";
}

Future<Map<String, int>> getDayInformation(DateTime day) async {
  List<String> users = (await FirebaseFirestore.instance.collection("Users").get()).docs.map((doc) => doc.id).toList();

  Map<String, int> result = <String, int>{};
  result["breakfast"] = 0;
  result["lunch"] = 0;
  result["dinner"] = 0;

  for (String user in users) {
    Map<String, dynamic>? datesInformation =
      (await FirebaseFirestore.instance.collection("MessOff").doc(user).collection(day.year.toString()).doc(monthIntToString(day.month)).get()).data();

    if (datesInformation != null) {
      for (MapEntry<String, dynamic> dateInformation in datesInformation.entries) {
        if(dateInformation.key == day.toUtc().toString()) {
          result["breakfast"] = result["breakfast"]! + ((dateInformation.value as int) & 1 != 0 ? 1 : 0);
          result["lunch"] = result["lunch"]! + ((dateInformation.value as int) & 2 != 0 ? 1 : 0);
          result["dinner"] = result["dinner"]! + ((dateInformation.value as int) & 4 != 0 ? 1 : 0);
        }
      }
    }
  }

  return result;
}

String replaceSpecialCharacterInMealName(String mealName) {
  return mealName.replaceAll(RegExp(r"[^\w\s]+"), "");
}

String weekDayToName(int weekday) {
  switch (weekday) {
    case 1: return "monday";
    case 2: return "tuesday";
    case 3: return "wednesday";
    case 4: return "thursday";
    case 5: return "friday";
    case 6: return "saturday";
    case 7: return "sunday";
    default: return "";
  }
}

Future<Map<String, List<int>>> getMealInformation(DateTime day) async {
  Map<String, List<String>> messMenu = await MessMenu.instance;
  List<String> meals = messMenu[weekDayToName(day.weekday)]!.map((e) => replaceSpecialCharacterInMealName(e)).toList();

  Map<String, List<int>> result = <String, List<int>>{};
  result["breakfast"] = [0, 0];
  result["lunch"] = [0, 0];
  result["dinner"] = [0, 0];

  Map<String, dynamic>? mealsInformation =
    (await FirebaseFirestore.instance.collection("MessVoteCollectively").doc("collection").get()).data();

  if (mealsInformation != null) {
    for (MapEntry<String, dynamic> mealInformation in mealsInformation.entries) {
      int index = meals.indexOf(mealInformation.key);
      if (index == 0) {
        result["breakfast"]![0] = (mealInformation.value as List<dynamic>).map((e) => e as int).toList()[0];
        result["breakfast"]![1] = (mealInformation.value as List<dynamic>).map((e) => e as int).toList()[1];
      }
      if (index == 1) {
        result["lunch"]![0] = (mealInformation.value as List<dynamic>).map((e) => e as int).toList()[0];
        result["lunch"]![1] = (mealInformation.value as List<dynamic>).map((e) => e as int).toList()[1];
      }
      if (index == 2) {
        result["dinner"]![0] = (mealInformation.value as List<dynamic>).map((e) => e as int).toList()[0];
        result["dinner"]![1] = (mealInformation.value as List<dynamic>).map((e) => e as int).toList()[1];
      }
    }
  }

  return result;
}


class DashboardComponent extends StatefulWidget {
  const DashboardComponent({Key? key}) : super(key: key);

  @override
  _DashboardComponentState createState() => _DashboardComponentState();
}

class _DashboardComponentState extends State<DashboardComponent> {
  late List<DateTime> datesSelected;
  late DateTime now;
  late DateTime start;
  late DateTime end;

  late Future<Map<String, int>> dayInformation;
  late Future<Map<String, List<int>>> mealLikeInformation;

  @override
  void initState() {
    super.initState();

    now = DateTime.now();
    start = now;
    start = DateTime.utc(start.year, start.month, start.day);
    end = DateTime.utc(now.year, now.month + 2, 0);

    datesSelected = [start];
    dayInformation = getDayInformation(datesSelected[0]);
    mealLikeInformation = getMealInformation(datesSelected[0]);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
            padding: EdgeInsets.only(left: screenWidth * 0.01, right: screenWidth * 0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.25,
                      child: TableCalendar(
                        rowHeight: screenHeight * 0.045,
                        firstDay: start,
                        lastDay: end,
                        focusedDay: datesSelected.last,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarFormat: CalendarFormat.month,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            datesSelected = [selectedDay];
                            getDayInformation(selectedDay);

                            setState(() {
                              dayInformation = getDayInformation(datesSelected[0]);
                              mealLikeInformation = getMealInformation(datesSelected[0]);
                            });
                          });
                        },
                        selectedDayPredicate: (day) {
                          for (DateTime loopDay in datesSelected) {
                            if (isSameDay(day, loopDay)) return true;
                          }
                          return false;
                        },
                        rangeSelectionMode: RangeSelectionMode.toggledOff,
                        // rowHeight: screenHeight * 0.05,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      width: 8,
                      height: screenHeight * 0.33,
                      child: const VerticalDivider(
                        thickness: 1,
                        color: Color.fromARGB(0xFF, 0xFF, 0xA6, 0x3A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 16, left: 16),
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Offs on ${DateFormat("yyyy-MM-dd").format(datesSelected[0])}"),
                          FutureBuilder<Map<String, int>>(
                            future: dayInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
                              if (!snapshot.hasData) {
                                return const Text("Breakfast: ");
                              } else {
                                return Text("Breakfast: ${snapshot.data!["breakfast"]}");
                              }
                            },
                          ),
                          FutureBuilder<Map<String, int>>(
                            future: dayInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
                              if (!snapshot.hasData) {
                                return const Text("Lunch: ");
                              } else {
                                return Text("Lunch: ${snapshot.data!["lunch"]}");
                              }
                            },
                          ),
                          FutureBuilder<Map<String, int>>(
                            future: dayInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
                              if (!snapshot.hasData) {
                                return const Text("Dinner: ");
                              } else {
                                return Text("Dinner: ${snapshot.data!["dinner"]}");
                              }
                            },
                          ),
                          FutureBuilder<Map<String, int>>(
                            future: dayInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
                              if (!snapshot.hasData) {
                                return const Text("Total: ");
                              } else {
                                int total = 0;
                                for (MapEntry<String, int> entry in snapshot.data!.entries) {
                                  total += entry.value;
                                }
                                return Text("Total: $total");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      width: 8,
                      height: screenHeight * 0.33,
                      child: const VerticalDivider(
                        thickness: 1,
                        color: Color.fromARGB(0xFF, 0xFF, 0xA6, 0x3A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 16,),
                      width: screenWidth * 0.12,
                      height: screenHeight * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(child: Text("Likes & Dislikes of Meals")),
                          FutureBuilder<Map<String, List<int>>>(
                            future: mealLikeInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, List<int>>> snapshot) {
                              if (!snapshot.hasData) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: const [
                                    Icon(Icons.thumb_up, size: 16,),
                                    Text(""),
                                    Icon(Icons.thumb_down, size: 16,),
                                    Text(""),
                                  ],
                                );
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Icon(Icons.thumb_up, size: 16,),
                                  Text(snapshot.data!["breakfast"]![0].toString()),
                                  const Icon(Icons.thumb_down, size: 16,),
                                  Text(snapshot.data!["breakfast"]![1].toString()),
                                ],
                              );
                            },
                          ),
                          FutureBuilder<Map<String, List<int>>>(
                            future: mealLikeInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, List<int>>> snapshot) {
                              if (!snapshot.hasData) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: const [
                                    Icon(Icons.thumb_up, size: 16,),
                                    Text(""),
                                    Icon(Icons.thumb_down, size: 16,),
                                    Text(""),
                                  ],
                                );
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Icon(Icons.thumb_up, size: 16,),
                                  Text(snapshot.data!["lunch"]![0].toString()),
                                  const Icon(Icons.thumb_down, size: 16,),
                                  Text(snapshot.data!["lunch"]![1].toString()),
                                ],
                              );
                            },
                          ),
                          FutureBuilder<Map<String, List<int>>>(
                            future: mealLikeInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, List<int>>> snapshot) {
                              if (!snapshot.hasData) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: const [
                                    Icon(Icons.thumb_up, size: 16,),
                                    Text(""),
                                    Icon(Icons.thumb_down, size: 16,),
                                    Text(""),
                                  ],
                                );
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Icon(Icons.thumb_up, size: 16,),
                                  Text(snapshot.data!["dinner"]![0].toString()),
                                  const Icon(Icons.thumb_down, size: 16,),
                                  Text(snapshot.data!["dinner"]![1].toString()),
                                ],
                              );
                            },
                          ),
                          FutureBuilder<Map<String, List<int>>>(
                            future: mealLikeInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, List<int>>> snapshot) {
                              if (!snapshot.hasData) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: const [
                                    Icon(Icons.thumb_up, size: 16,),
                                    Text(""),
                                    Icon(Icons.thumb_down, size: 16,),
                                    Text(""),
                                  ],
                                );
                              }

                              int totalLike = 0, totalDislike = 0;
                              for (MapEntry<String, List<int>> entry in snapshot.data!.entries) {
                                totalLike += entry.value[0];
                                totalDislike += entry.value[1];
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Icon(Icons.thumb_up, size: 16,),
                                  Text("$totalLike"),
                                  const Icon(Icons.thumb_down, size: 16,),
                                  Text("$totalDislike"),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      width: 8,
                      height: screenHeight * 0.33,
                      child: const VerticalDivider(
                        thickness: 1,
                        color: Color.fromARGB(0xFF, 0xFF, 0xA6, 0x3A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
