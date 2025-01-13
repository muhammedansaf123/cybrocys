import 'package:first_app/dashboard/dashboard.dart';
import 'package:first_app/profile/profile.dart';
import 'package:first_app/settings/settings_page.dart';
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
