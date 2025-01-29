import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hospital_managment/appointments/provider/appointments_provider.dart';
import 'package:hospital_managment/components/const.dart';
import 'package:hospital_managment/firebase_options.dart';
import 'package:hospital_managment/dashboard/dashboard.dart';
import 'package:hospital_managment/login/login_page.dart';
import 'package:hospital_managment/medical_records/medical_records_provider.dart';
import 'package:hospital_managment/surgeries_admit/provider/surgeryandadmit_provider.dart';
import 'package:hospital_managment/user/userstate.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppointmentsProvider()),
        ChangeNotifierProvider(create: (_) => SurgeryandadmitProvider()),
         ChangeNotifierProvider(create: (_) => MedicalRecordsProvider()),
      ],
      child: MyApp(),
    ),
  );
print("hello");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase',
      theme: ThemeData(
        disabledColor: Colors.blue,
      ),
      home: UserState(),
    );
  }
}
