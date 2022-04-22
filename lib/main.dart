import 'package:admin_eat/Scaffold/SignInSignUpScaffold.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBQYPbYYIu-1QVtSbOYBaNNsziNslmR_Ts",
      authDomain: "messmanagementsystem-9d274.firebaseapp.com",
      databaseURL: "https://messmanagementsystem-9d274-default-rtdb.firebaseio.com",
      projectId: "messmanagementsystem-9d274",
      storageBucket: "messmanagementsystem-9d274.appspot.com",
      messagingSenderId: "962645154019",
      appId: "1:962645154019:web:0066a4d8c59a88fc81cdd6"
    )
  );

  runApp(MaterialApp(
    theme: ThemeData(
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Color.fromARGB(0xFF, 0x30, 0x5D, 0x51), fontFamily: 'Nexa'),
        titleMedium: TextStyle(color: Color.fromARGB(0xFF, 0x30, 0x5D, 0x51), fontFamily: 'Nexa'),
        titleSmall: TextStyle(color: Color.fromARGB(0xFF, 0x30, 0x5D, 0x51), fontFamily: 'Nexa'),
        displayMedium: TextStyle(color: Color.fromARGB(0xFF, 0xFF, 0xA6, 0x3A), fontFamily: 'Nexa', fontSize: 20),
        labelLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Nexa'),
        labelMedium: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Nexa'),
        labelSmall: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Nexa'),
      ),
    ),
    home: const SignInSignUpPage(),
  ));
}
