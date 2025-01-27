import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_managment/dashboard/dashboard.dart';
import 'package:hospital_managment/login/login_page.dart';
import 'package:flutter/material.dart';

class UserState extends StatefulWidget {
  const UserState({super.key});

  @override
  _UserStateState createState() => _UserStateState();
}

class _UserStateState extends State<UserState> {
  bool isSignupCompleted = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, usersnapshot) {
     
        if (usersnapshot.data != null && !isSignupCompleted) {
          return Homepage();
        }

        else if (usersnapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Unexpected Error Occurred')),
          );
        }

        
        else if (usersnapshot.data == null) {
          return LoginDemo();
        }

        // Show loading spinner while waiting for authentication state
        else {
          return Scaffold(
            body: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }

  void setSignupCompleted() {
    setState(() {
      isSignupCompleted = true;
    });
  }
}
