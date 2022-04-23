import 'package:admin_eat/Components/ChatComponent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Components/MessComponent.dart';

class HomePageScaffold extends StatefulWidget {
  const HomePageScaffold({Key? key}) : super(key: key);

  @override
  _HomePageScaffoldState createState() => _HomePageScaffoldState();
}

class _HomePageScaffoldState extends State<HomePageScaffold> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: screenWidth * 0.125,
              height: double.infinity,
              child: NavigationRail(
                leading: Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.1),
                  child: SvgPicture.asset(
                    "assets/HomepageLogo.svg",
                    width: screenWidth * 0.075,
                  ),
                ),
                // extended: true,
                unselectedIconTheme: const IconThemeData(color: Colors.black),
                backgroundColor: const Color.fromARGB(255, 227, 231, 238),
                selectedIndex: _selectedIndex,
                groupAlignment: 0,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.selected,
                destinations: <NavigationRailDestination>[
                  NavigationRailDestination(
                    icon: const Center(
                        child: Icon(
                      Icons.dashboard,
                    )),
                    label: Center(
                      child: Text(
                        "Dashboard",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    selectedIcon: const Icon(Icons.dashboard),
                  ),
                  NavigationRailDestination(
                    icon: SvgPicture.asset(
                      "assets/MessMenuIcon.svg",
                      width: screenWidth * 0.035,
                      color: Colors.grey.shade600,
                    ),
                    label: Text(
                      "Menu",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    selectedIcon: SvgPicture.asset(
                      "assets/MessMenuIcon.svg",
                      width: screenWidth * 0.035,
                    ),
                  ),
                  NavigationRailDestination(
                    icon: SvgPicture.asset(
                      "assets/ChatIcon.svg",
                      width: screenWidth * 0.035,
                      color: Colors.grey.shade600,
                    ),
                    label: Text(
                      "Chat",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    selectedIcon: SvgPicture.asset(
                      "assets/ChatIcon.svg",
                      width: screenWidth * 0.035,
                    ),
                  ),
                  NavigationRailDestination(
                    icon: SvgPicture.asset(
                      "assets/FeedbackIcon.svg",
                      width: screenWidth * 0.035,
                      color: Colors.grey.shade600,
                    ),
                    label: Text(
                      "Feedback",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    selectedIcon: SvgPicture.asset(
                      "assets/FeedbackIcon.svg",
                      width: screenWidth * 0.035,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 240, 243, 246),
              ),
              width: screenWidth * 0.875,
              // height: screenHeight * 0.8,
              child: (_selectedIndex == 0)
                  ? Container()
                  : (_selectedIndex == 1)
                      ? const MessMenuComponent()
                      : (_selectedIndex == 2)
                          ? const ChatComponent()
                          : (_selectedIndex == 3)
                              ? Container()
                              : Container(),
            )
          ],
        ),
      ),
    );
  }
}
