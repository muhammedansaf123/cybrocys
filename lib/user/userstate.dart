import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_managment/dashboard/dashboard.dart';
import 'package:hospital_managment/login/login_page.dart';
import 'package:flutter/material.dart';

class UserState extends StatelessWidget {
  const UserState({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: ( context, usersnapshot) {
      if(usersnapshot.data!=null){
        return Homepage();

      }

      else if(usersnapshot.hasError){
        return Scaffold(
          body: Center(child: Text('Unexpected Error Occured'),),
        );
      }
      else if(usersnapshot.data==null){
        return LoginDemo();
      }
      else{
        return Scaffold(
          body: Center(
          child: SizedBox(width: 40,height: 40,child: CircularProgressIndicator(),),
          ),
        );
      }
      },);
  }
}
