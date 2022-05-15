import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Singletons/MessMenu.dart';

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
    Map<String, dynamic>? datesInformation = (await FirebaseFirestore.instance
            .collection("MessOff")
            .doc(user)
            .collection(day.year.toString())
            .doc(monthIntToString(day.month))
            .get())
        .data();

    if (datesInformation != null) {
      for (MapEntry<String, dynamic> dateInformation in datesInformation.entries) {
        if (dateInformation.key == day.toUtc().toString()) {
          print(dateInformation.value);
          result["breakfast"] = result["breakfast"]! + ((((dateInformation.value as int) & 1) == 0) ? 1 : 0);
          result["lunch"] = result["lunch"]! + ((((dateInformation.value as int) & 2) == 0) ? 1 : 0);
          result["dinner"] = result["dinner"]! + ((((dateInformation.value as int) & 4) == 0) ? 1 : 0);
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
    case 1:
      return "monday";
    case 2:
      return "tuesday";
    case 3:
      return "wednesday";
    case 4:
      return "thursday";
    case 5:
      return "friday";
    case 6:
      return "saturday";
    case 7:
      return "sunday";
    default:
      return "";
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

  Map<String, int> savedBreakfastState = <String, int>{};
  Map<String, int> savedLunchState = <String, int>{};
  Map<String, int> savedDinnerState = <String, int>{};
  Map<String, int> savedTotalState = <String, int>{};

  String breakfastString = "...";
  String lunchString = "...";
  String dinnerString = "...";
  String totalString = "...";

  String breakfastLikeString = "...";
  String breakfastDislikeString = "...";
  String lunchLikeString = "...";
  String lunchDislikeString = "...";
  String dinnerLikeString = "...";
  String dinnerDislikeString = "...";
  String totalLikeString = "...";
  String totalDislikeString = "...";

  Map<String, List<int>> savedBreakfastLikeState = <String, List<int>>{};
  Map<String, List<int>> savedLunchLikeState = <String, List<int>>{};
  Map<String, List<int>> savedDinnerLikeState = <String, List<int>>{};
  Map<String, List<int>> savedTotalLikeState = <String, List<int>>{};

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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.03, right: screenWidth * 0.03),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.025),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Mess Information",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.25,
                      child: TableCalendar(
                        rowHeight: screenHeight * 0.045,
                        firstDay: DateTime.utc(start.year),
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
                              breakfastString = "...";
                              lunchString = "...";
                              dinnerString = "...";
                              totalString = "...";

                              breakfastLikeString = "...";
                              breakfastDislikeString = "...";
                              lunchLikeString = "...";
                              lunchDislikeString = "...";
                              dinnerLikeString = "...";
                              dinnerDislikeString = "...";
                              totalLikeString = "...";
                              totalDislikeString = "...";

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
                      padding: const EdgeInsets.only(top: 16, left: 16),
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Offs on ${DateFormat("yyyy-MM-dd").format(datesSelected[0])}", style: TextStyle(fontWeight: FontWeight.bold),),
                          FutureBuilder<Map<String, int>>(
                            future: dayInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
                              if (snapshot.hasData && snapshot.data! != savedBreakfastState) {
                                breakfastString = snapshot.data!["breakfast"].toString();
                                savedBreakfastState = snapshot.data!;
                              }

                              return Text("Breakfast: $breakfastString");
                            },
                          ),
                          FutureBuilder<Map<String, int>>(
                            future: dayInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
                              if (snapshot.hasData && snapshot.data! != savedLunchState) {
                                lunchString = snapshot.data!["lunch"].toString();
                                savedLunchState = snapshot.data!;
                              }

                              return Text("Lunch: $lunchString");
                            },
                          ),
                          FutureBuilder<Map<String, int>>(
                            future: dayInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
                              if (snapshot.hasData && snapshot.data! != savedDinnerState) {
                                dinnerString = snapshot.data!["dinner"].toString();
                                savedDinnerState = snapshot.data!;
                              }

                              return Text("Dinner: $dinnerString");
                            },
                          ),
                          FutureBuilder<Map<String, int>>(
                            future: dayInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
                              if (snapshot.hasData && snapshot.data! != savedTotalState) {
                                dinnerString = snapshot.data!["dinner"].toString();
                                int total = 0;
                                for (MapEntry<String, int> entry in snapshot.data!.entries) {
                                  total += entry.value;
                                }

                                totalString = total.toString();
                                savedTotalState = snapshot.data!;
                              }

                              return Text("Total: $totalString");
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 16,
                      ),
                      width: screenWidth * 0.12,
                      height: screenHeight * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(child: Text("Likes & Dislikes of Meals", style: TextStyle(fontWeight: FontWeight.bold),)),
                          FutureBuilder<Map<String, List<int>>>(
                            future: mealLikeInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, List<int>>> snapshot) {
                              if (snapshot.hasData && snapshot.data! != savedBreakfastLikeState) {
                                breakfastLikeString = snapshot.data!["breakfast"]![0].toString();
                                breakfastDislikeString = snapshot.data!["breakfast"]![1].toString();

                                savedBreakfastLikeState = snapshot.data!;
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Icon(
                                    Icons.thumb_up,
                                    size: 16,
                                  ),
                                  Text(breakfastLikeString),
                                  const Icon(
                                    Icons.thumb_down,
                                    size: 16,
                                  ),
                                  Text(breakfastDislikeString),
                                ],
                              );
                            },
                          ),
                          FutureBuilder<Map<String, List<int>>>(
                            future: mealLikeInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, List<int>>> snapshot) {
                              if (snapshot.hasData && snapshot.data! != savedLunchLikeState) {
                                lunchLikeString = snapshot.data!["lunch"]![0].toString();
                                lunchDislikeString = snapshot.data!["lunch"]![1].toString();

                                savedLunchLikeState = snapshot.data!;
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Icon(
                                    Icons.thumb_up,
                                    size: 16,
                                  ),
                                  Text(lunchLikeString),
                                  const Icon(
                                    Icons.thumb_down,
                                    size: 16,
                                  ),
                                  Text(lunchDislikeString),
                                ],
                              );
                            },
                          ),
                          FutureBuilder<Map<String, List<int>>>(
                            future: mealLikeInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, List<int>>> snapshot) {
                              if (snapshot.hasData && snapshot.data! != savedDinnerLikeState) {
                                dinnerLikeString = snapshot.data!["dinner"]![0].toString();
                                dinnerDislikeString = snapshot.data!["dinner"]![1].toString();

                                savedDinnerLikeState = snapshot.data!;
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Icon(
                                    Icons.thumb_up,
                                    size: 16,
                                  ),
                                  Text(dinnerLikeString),
                                  const Icon(
                                    Icons.thumb_down,
                                    size: 16,
                                  ),
                                  Text(dinnerDislikeString),
                                ],
                              );
                            },
                          ),
                          FutureBuilder<Map<String, List<int>>>(
                            future: mealLikeInformation,
                            builder: (BuildContext context, AsyncSnapshot<Map<String, List<int>>> snapshot) {
                              if (snapshot.hasData && snapshot.data! != savedTotalLikeState) {
                                int totalLike = 0, totalDislike = 0;
                                for (MapEntry<String, List<int>> entry in snapshot.data!.entries) {
                                  totalLike += entry.value[0];
                                  totalDislike += entry.value[1];
                                }

                                totalLikeString = totalLike.toString();
                                totalDislikeString = totalDislike.toString();

                                savedTotalLikeState = snapshot.data!;
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Icon(
                                    Icons.thumb_up,
                                    size: 16,
                                  ),
                                  Text(totalLikeString),
                                  const Icon(
                                    Icons.thumb_down,
                                    size: 16,
                                  ),
                                  Text(totalDislikeString),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                  color: Color.fromARGB(0xFF, 0xFF, 0xA6, 0x3A),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Statistics",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FutureBuilder<List<Map<String, int>>>(
                      future: Future.wait(
                        List.generate(
                          29,
                          (index) {
                            return getDayInformation(datesSelected[0].subtract(Duration(days: 28 - index)));
                          },
                        ),
                      ),
                      builder: (BuildContext context, AsyncSnapshot<List<Map<String, int>>> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.only(left: screenWidth * 0.1, top: screenHeight * 0.1),
                              child: const CircularProgressIndicator.adaptive(
                                backgroundColor: Color.fromARGB(0xFF, 0xFF, 0xA6, 0x3A),
                              ),
                            ),
                          );
                        }

                        List<int> breakfasts = snapshot.data!.map((e) => e["breakfast"]!).toList();
                        List<int> lunchs = snapshot.data!.map((e) => e["lunch"]!).toList();
                        List<int> dinners = snapshot.data!.map((e) => e["dinner"]!).toList();

                        // int breakfastLen = breakfasts.length;
                        List<double> breakfastAverage = List.empty(growable: true);
                        List<double> lunchAverage = List.empty(growable: true);
                        List<double> dinnerAverage = List.empty(growable: true);
                        for (int i = 0; i<7; i++){
                          breakfastAverage.add((breakfasts[breakfasts.length - 1 - i] + breakfasts[breakfasts.length - 1 - i - 7] +
                              breakfasts[breakfasts.length - 1 - i - 14]) / 3);

                          lunchAverage.add((lunchs[lunchs.length - 1 - i] + lunchs[lunchs.length - 1 - i - 7] +
                              lunchs[lunchs.length - 1 - i - 14]) / 3);

                          dinnerAverage.add((dinners[dinners.length - 1 - i] + dinners[dinners.length - 1 - i - 7] +
                              dinners[dinners.length - 1 - i - 14]) / 3);
                        }
                        // print("$breakfastAverage $lunchAverage $dinnerAverage");

                        // double avgBreakfast =
                        //     breakfasts.fold(0.0, (previousValue, element) => previousValue + element.toDouble());
                        // double avgLunch =
                        //     lunchs.fold(0.0, (previousValue, element) => previousValue + element.toDouble());
                        // double avgDinner =
                        //     dinners.fold(0.0, (previousValue, element) => previousValue + element.toDouble());
                        //
                        // avgBreakfast /= breakfasts.length;
                        // avgLunch /= lunchs.length;
                        // avgDinner /= dinners.length;
                        //
                        // avgBreakfast = 8.5;
                        // avgLunch = 6.8;
                        // avgDinner = 5.6;

                        List<FlSpot> breakfastsSpots = List<FlSpot>.empty(growable: true);
                        List<FlSpot> lunchSpots = List<FlSpot>.empty(growable: true);
                        List<FlSpot> dinnerSpots = List<FlSpot>.empty(growable: true);

                        // double lastBreakfastValue = breakfasts.last.toDouble();
                        // double lastLunchValue = lunchs.last.toDouble();
                        // double lastDinnerValue = dinners.last.toDouble();

                        // lastBreakfastValue = 7;
                        // lastLunchValue = 8;
                        // lastDinnerValue = 5;
                        for (int i = 0; i < 7; i++) {
                          breakfastsSpots.add(FlSpot(i.toDouble(), breakfastAverage[i].roundToDouble()));
                          lunchSpots.add(FlSpot(i.toDouble(), lunchAverage[i].roundToDouble()));
                          dinnerSpots.add(FlSpot(i.toDouble(), dinnerAverage[i].roundToDouble()));

                          // lastBreakfastValue = avgBreakfast;
                          // lastLunchValue = avgLunch;
                          // lastDinnerValue = avgDinner;

                          // if (Random().nextDouble() < 0.5) {
                          //   slopeBreakfast = (-(slopeBreakfast * (29 + i)) + lastBreakfastValue) / (29 + (i + 1));
                          // } else {
                          //   slopeBreakfast = ((slopeBreakfast * (29 + i)) + lastBreakfastValue) / (29 + (i + 1));
                          // }
                          //
                          // if (Random().nextDouble() < 0.5) {
                          //   slopeLunch = (-(slopeLunch * (29 + i)) + lastLunchValue) / (29 + (i + 1));
                          // } else {
                          //   slopeLunch = ((slopeLunch * (29 + i)) + lastLunchValue) / (29 + (i + 1));
                          // }
                          //
                          // if (Random().nextDouble() < 0.5) {
                          //   slopeDinner = (-(slopeDinner * (29 + i)) + lastDinnerValue) / (29 + (i + 1));
                          // } else {
                          //   slopeDinner = ((slopeDinner * (29 + i)) + lastDinnerValue) / (29 + (i + 1));
                          // }

                          // avgBreakfast = ((avgBreakfast * (29 + i)) + lastBreakfastValue) / (29 + (i + 1));
                          // avgLunch = ((avgLunch * (29 + i)) + lastLunchValue) / (29 + (i + 1));
                          // avgDinner = ((avgDinner * (29 + i)) + lastDinnerValue) / (29 + (i + 1));
                          //
                          // lastBreakfastValue = lastBreakfastValue.round().toDouble();
                          // lastLunchValue = lastLunchValue.round().toDouble();
                          // lastDinnerValue = lastDinnerValue.round().toDouble();
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: screenWidth * 0.25,
                                height: screenWidth * 0.125,
                                child: LineChart(LineChartData(
                                    titlesData: FlTitlesData(
                                      show: true,
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      // rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (double index, TitleMeta meta) {
                                              switch (index.toInt()) {
                                                case 0:
                                                  return Text(DateFormat("dd-MM").format(datesSelected[0]));
                                                case 1:
                                                  return Text(DateFormat("dd-MM")
                                                      .format(datesSelected[0].add(Duration(days: 1))));
                                                case 2:
                                                  return Text(DateFormat("dd-MM")
                                                      .format(datesSelected[0].add(Duration(days: 2))));
                                                case 3:
                                                  return Text(DateFormat("dd-MM")
                                                      .format(datesSelected[0].add(Duration(days: 3))));
                                                case 4:
                                                  return Text(DateFormat("dd-MM")
                                                      .format(datesSelected[0].add(Duration(days: 4))));
                                                case 5:
                                                  return Text(DateFormat("dd-MM")
                                                      .format(datesSelected[0].add(Duration(days: 5))));
                                                case 6:
                                                  return Text(DateFormat("dd-MM")
                                                      .format(datesSelected[0].add(Duration(days: 6))));
                                                case 7:
                                                  return Text(DateFormat("dd-MM")
                                                      .format(datesSelected[0].add(Duration(days: 7))));

                                                default:
                                                  return const Text("");
                                              }
                                            }),
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        show: true,
                                        spots: breakfastsSpots,
                                        color: Colors.orange,
                                      ),
                                      LineChartBarData(
                                        show: true,
                                        spots: lunchSpots,
                                        color: Colors.green,
                                      ),
                                      LineChartBarData(
                                        show: true,
                                        spots: dinnerSpots,
                                        color: Colors.blueGrey,
                                      ),
                                    ])),
                              ),
                            ),
                            const Text("Prediction"),
                          ],
                        );
                      },
                    ),
                    FutureBuilder<List<Map<String, int>>>(
                      future: Future.wait([
                        getDayInformation(datesSelected[0].subtract(const Duration(days: 6))),
                        getDayInformation(datesSelected[0].subtract(const Duration(days: 5))),
                        getDayInformation(datesSelected[0].subtract(const Duration(days: 4))),
                        getDayInformation(datesSelected[0].subtract(const Duration(days: 3))),
                        getDayInformation(datesSelected[0].subtract(const Duration(days: 2))),
                        getDayInformation(datesSelected[0].subtract(const Duration(days: 1))),
                        getDayInformation(datesSelected[0]),
                      ]),
                      builder: (BuildContext context, AsyncSnapshot<List<Map<String, int>>> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.only(left: screenWidth * 0.05, top: screenHeight * 0.1),
                              child: const CircularProgressIndicator.adaptive(
                                backgroundColor: Color.fromARGB(0xFF, 0xFF, 0xA6, 0x3A),
                              ),
                            ),
                          );
                        }
                        int breakfast = 0;
                        int lunch = 0;
                        int dinner = 0;

                        for (Map<String, int> item in snapshot.data!) {
                          breakfast += item['breakfast']!;
                          lunch += item['lunch']!;
                          dinner += item['dinner']!;
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: screenWidth * 0.125,
                                height: screenWidth * 0.125,
                                child: PieChart(
                                  PieChartData(
                                    // centerSpaceRadius: 0,
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.orange,
                                        title: 'Breakfast: $breakfast',
                                        value: breakfast == 0 && lunch == 0 && dinner == 0 ? 1.0 : breakfast.toDouble(),
                                        radius: screenWidth * 0.05,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.green,
                                        title: "Lunch: $lunch",
                                        value: breakfast == 0 && lunch == 0 && dinner == 0 ? 1.0 : lunch.toDouble(),
                                        radius: screenWidth * 0.05,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blueGrey,
                                        title: 'Dinner: $dinner',
                                        value: breakfast == 0 && lunch == 0 && dinner == 0 ? 1.0 : dinner.toDouble(),
                                        radius: screenWidth * 0.05,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              "Mess off data for Last 7 days",
                            )
                          ],
                        );
                      },
                    ),
                    FutureBuilder<List<Map<String, List<int>>>>(
                      future: Future.wait(
                        [
                          getMealInformation(datesSelected[0].subtract(const Duration(days: 7))),
                          getMealInformation(datesSelected[0].subtract(const Duration(days: 6))),
                          getMealInformation(datesSelected[0].subtract(const Duration(days: 5))),
                          getMealInformation(datesSelected[0].subtract(const Duration(days: 4))),
                          getMealInformation(datesSelected[0].subtract(const Duration(days: 3))),
                          getMealInformation(datesSelected[0].subtract(const Duration(days: 2))),
                          getMealInformation(datesSelected[0].subtract(const Duration(days: 1))),
                        ],
                      ),
                      builder: (BuildContext context, AsyncSnapshot<List<Map<String, List<int>>>> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.only(left: screenWidth * 0.05, top: screenHeight * 0.1, right: screenWidth * 0.05,),
                              child: const CircularProgressIndicator.adaptive(
                                backgroundColor: Color.fromARGB(0xFF, 0xFF, 0xA6, 0x3A),
                              ),
                            ),
                          );
                        }

                        int breakfastLike = 0;
                        int breakfastDislike = 0;
                        int lunchLike = 0;
                        int lunchDislike = 0;
                        int dinnerLike = 0;
                        int dinnerDislike = 0;
                        for (Map<String, List<int>> item in snapshot.data!) {
                          breakfastLike += item["breakfast"]![0];
                          breakfastDislike += item["breakfast"]![1];
                          lunchLike += item["lunch"]![0];
                          lunchDislike += item["lunch"]![1];
                          dinnerLike += item["dinner"]![0];
                          dinnerDislike += item["dinner"]![1];
                        }

                        int maxValue = 0;
                        maxValue = max(maxValue, breakfastLike);
                        maxValue = max(maxValue, breakfastDislike);
                        maxValue = max(maxValue, lunchLike);
                        maxValue = max(maxValue, lunchDislike);
                        maxValue = max(maxValue, dinnerLike);
                        maxValue = max(maxValue, dinnerDislike);

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: screenWidth * 0.125,
                                height: screenWidth * 0.125,
                                child: BarChart(
                                  BarChartData(
                                    barGroups: [
                                      BarChartGroupData(
                                        x: 0,
                                        barRods: [
                                          BarChartRodData(toY: breakfastLike.toDouble(), color: Colors.greenAccent),
                                          BarChartRodData(toY: breakfastDislike.toDouble(), color: Colors.redAccent),
                                        ],
                                      ),
                                      BarChartGroupData(
                                        x: 1,
                                        barRods: [
                                          BarChartRodData(toY: lunchLike.toDouble(), color: Colors.greenAccent),
                                          BarChartRodData(toY: lunchDislike.toDouble(), color: Colors.redAccent),
                                        ],
                                      ),
                                      BarChartGroupData(
                                        x: 2,
                                        barRods: [
                                          BarChartRodData(toY: dinnerLike.toDouble(), color: Colors.greenAccent),
                                          BarChartRodData(toY: dinnerDislike.toDouble(), color: Colors.redAccent),
                                        ],
                                      ),
                                    ],
                                    titlesData: FlTitlesData(
                                      show: true,
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            const TextStyle textStyle = TextStyle(
                                              fontSize: 12,
                                            );
                                            if (value == 0 ||
                                                value == maxValue.toDouble() ||
                                                value == maxValue.toDouble() / 2) {
                                              return Text(
                                                "$value",
                                                style: textStyle,
                                              );
                                            }

                                            return Container();
                                          },
                                        ),
                                      ),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            const TextStyle textStyle = TextStyle(
                                              fontSize: 12,
                                            );

                                            switch (value.toInt()) {
                                              case 0:
                                                return const Text(
                                                  "Breakfast",
                                                  style: textStyle,
                                                );
                                              case 1:
                                                return const Text(
                                                  "Lunch",
                                                  style: textStyle,
                                                );
                                              case 2:
                                                return const Text(
                                                  "Dinner",
                                                  style: textStyle,
                                                );
                                              default:
                                                return const Text(
                                                  "",
                                                  style: textStyle,
                                                );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              "Meals like/dislike data for whole week",
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
