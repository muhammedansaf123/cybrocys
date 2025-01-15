import 'package:hospital_managment/dashboard/dashboard.dart';
import 'package:hospital_managment/profile/profile.dart';
import 'package:hospital_managment/settings/settings_page.dart';
import 'package:flutter/material.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

int index = 0;
List<Widget> screens = [Homepage(), ProfilePage(), SettingsPage()];

class _BottomnavState extends State<Bottomnav> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (value) {
           setState(() {
              index = value;
           });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'settings')
          ]),
    );
  }
}
