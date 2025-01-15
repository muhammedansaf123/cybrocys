
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hospital_managment/firebase_options.dart';
import 'package:hospital_managment/dashboard/dashboard.dart';
import 'package:hospital_managment/login/login_page.dart';
import 'package:hospital_managment/user/userstate.dart';

import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      title: 'Firebase',
        theme: ThemeData(
      disabledColor: Colors.blue,
    ),
      home: UserState(),
    );
  }
}

