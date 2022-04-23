import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:admin_eat/Singletons/Hostels.dart';

import '../Components/ShowAlertDialog.dart';
import '../Components/HostelListButtonState.dart';
import '../Singletons/User.dart' as MyUser;
import '../Scaffold/HomePageScaffold.dart';

class SignInSignUpPage extends StatefulWidget {
  const SignInSignUpPage({Key? key}) : super(key: key);

  @override
  _SignInSignUpPageState createState() => _SignInSignUpPageState();
}

class _SignInSignUpPageState extends State<SignInSignUpPage> with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Sign Up'),
    Tab(text: 'Login'),
  ];

  late TabController _tabController;

  TextEditingController signInEmailController = TextEditingController();
  TextEditingController signInPasswordController = TextEditingController();
  TextEditingController signUpEmailController = TextEditingController();
  TextEditingController signUpPasswordController = TextEditingController();
  TextEditingController hostelNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            Widget mainContainer = Row(
              children: [
                Container(
                  width: screenWidth * 0.65,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(0xFF, 0x30, 0x5D, 0x51),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/SignInSignUpimage.svg",
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      height: double.infinity,
                      width: screenWidth * 0.35,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(0xFF, 0x30, 0x5D, 0x51),
                      ),
                    ),
                    Container(
                      height: double.infinity,
                      width: screenWidth * 0.35,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          bottomLeft: Radius.circular(32),
                        ),
                      ),
                      child: Center(
                        child: SizedBox(
                          height: double.infinity,
                          width: screenWidth * 0.25,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TabBar(
                                labelStyle: Theme.of(context).textTheme.labelLarge,
                                indicatorColor: const Color.fromARGB(0xFF, 0xFF, 0xA6, 0x3A),
                                labelColor: const Color.fromARGB(0xFF, 0xFF, 0xA6, 0x3A),
                                unselectedLabelColor: Theme.of(context).textTheme.labelMedium!.color,
                                indicatorSize: TabBarIndicatorSize.label,
                                tabs: myTabs,
                                controller: _tabController,
                              ),
                              SizedBox(
                                height: screenHeight * 0.7,
                                width: screenWidth * 0.25,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    Tab(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 16.0),
                                            child: Text("Email Address", style: Theme.of(context).textTheme.labelSmall,),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 16.0),
                                            child: TextField(
                                              controller: signUpEmailController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(width: 0, style: BorderStyle.none),
                                                ),
                                                fillColor: Colors.grey.shade200,
                                                filled: true,
                                              ),
                                              cursorColor: Colors.black,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 16.0),
                                            child: Text("Password", style: Theme.of(context).textTheme.labelSmall,),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 16.0),
                                            child: TextField(
                                              controller: signUpPasswordController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(width: 0, style: BorderStyle.none),
                                                ),
                                                fillColor: Colors.grey.shade200,
                                                filled: true,
                                              ),
                                              obscureText: true,
                                              cursorColor: Colors.black,
                                            ),
                                          ),
                                          FutureBuilder<List<String>>(
                                            future: getHostelsName(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 16.0),
                                                  child: Container(
                                                    height: screenHeight * 0.1,
                                                    child: HostelListButton(
                                                      controller: hostelNameController,
                                                      hostelsName: snapshot.data!,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Container(
                                                  height: screenHeight * 0.1,
                                                  child: Center(child: CircularProgressIndicator.adaptive()),
                                                );
                                              }
                                            },
                                          ),
                                          Center(
                                            child: Padding(
                                              padding: EdgeInsets.only(top: screenHeight * 0.1),
                                              child: SizedBox(
                                                width: screenWidth * 0.1,
                                                child: TextButton(
                                                  style: ElevatedButton.styleFrom(
                                                    primary: const Color.fromARGB(0xFF, 0xFF, 0xA6, 0x3A),
                                                    padding: const EdgeInsets.all(24),
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                                          email: signUpEmailController.text, password: signUpPasswordController.text);

                                                      HashMap<String, String> map = HashMap<String, String>();
                                                      map["hostel"] = hostelNameController.text;
                                                      map["name"] = "Manager ${hostelNameController.text}";
                                                      map["isAdmin"] = "true";
                                                      await FirebaseFirestore.instance.collection("Users").doc(signUpEmailController.text).set(map);
                                                    } on FirebaseAuthException catch (e) {
                                                      await showAlertDialog(context, "Error", e.toString());
                                                    }
                                                  },
                                                  child: Text(
                                                    "Sign Up",
                                                    style: Theme.of(context).textTheme.labelMedium,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Tab(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 16.0),
                                            child: Text("Email Address", style: Theme.of(context).textTheme.labelSmall,),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 16.0),
                                            child: TextField(
                                              controller: signInEmailController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(width: 0, style: BorderStyle.none),
                                                ),
                                                fillColor: Colors.grey.shade200,
                                                filled: true,
                                              ),
                                              cursorColor: Colors.black,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 16.0),
                                            child: Text("Password", style: Theme.of(context).textTheme.labelSmall,),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 16.0),
                                            child: TextField(
                                              controller: signInPasswordController,
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(width: 0, style: BorderStyle.none),
                                                ),
                                                fillColor: Colors.grey.shade200,
                                                filled: true,
                                              ),
                                              cursorColor: Colors.black,
                                            ),
                                          ),
                                          Center(
                                            child: Padding(
                                              padding: EdgeInsets.only(top: screenHeight * 0.2),
                                              child: SizedBox(
                                                width: screenWidth * 0.1,
                                                child: TextButton(
                                                  style: ElevatedButton.styleFrom(
                                                    primary: const Color.fromARGB(0xFF, 0xFF, 0xA6, 0x3A),
                                                    padding: const EdgeInsets.all(24),
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                                                          email: signInEmailController.text, password: signInPasswordController.text);
                                                    } on FirebaseAuthException catch (e) {
                                                      await showAlertDialog(context, "Error", e.toString());
                                                    }
                                                  },
                                                  child: Text(
                                                    "Login",
                                                    style: Theme.of(context).textTheme.labelMedium,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );

            if (!snapshot.hasData) {
              MyUser.User.instance.setName("");
              MyUser.User.instance.setHostel("");
              MyUser.User.instance.setEmailAddress("");

              return mainContainer;
            }

            User? user = snapshot.data;
            if (user == null) {
              MyUser.User.instance.setName("");
              MyUser.User.instance.setHostel("");
              MyUser.User.instance.setEmailAddress("");

              return mainContainer;
            }

            Future.delayed(const Duration(), () {
              if (!user.emailVerified) {
                user.sendEmailVerification();
                showAlertDialog(context, "Email Verification", "Check your email for verification...");
                FirebaseAuth.instance.signOut();
                return;
              } else {
                MyUser.User.instance.setEmailAddress(user.email!);
                FirebaseFirestore.instance.collection("Users").doc(user.email!).get().then((value) {
                  Map<String, String> map = value.data()!.map((String name, dynamic value) {
                    return MapEntry(name, value as String);
                  });
                  if (map["isAdmin"]! == "false") {
                    showAlertDialog(context, "User account", "Please use app to sign in...");
                    FirebaseAuth.instance.signOut();
                    return;
                  }

                  MyUser.User.instance.setHostel(map["hostel"]!);
                  MyUser.User.instance.setName(map["name"]!);
                  if (map["image"] == null) {
                    MyUser.User.instance.setProfilePic(Image.asset(
                      "assets/default_pic.png",
                      height: screenHeight * 0.1,
                      width: screenHeight * 0.1,
                    ));
                  } else {
                    MyUser.User.instance.setProfilePic(Image.memory(
                      const Base64Decoder().convert(map["image"]!),
                      height: screenHeight * 0.1,
                      width: screenHeight * 0.1,
                    ));
                  }

                  print(MyUser.User.instance.getEmailAddress());
                  print(MyUser.User.instance.getName());
                  print(MyUser.User.instance.getHostel());

                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    // return HomePageScaffold();
                    return HomePageScaffold();
                  }));
                });
              }
            });

            return Container(
              height: screenHeight,
              width: screenWidth,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
