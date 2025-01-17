import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_managment/components/components.dart';
import 'package:hospital_managment/profile/edit_profile.dart';
import 'package:hospital_managment/profile/hospital/hospital_details.dart';
import 'package:hospital_managment/settings/settings_page.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    late Stream<DocumentSnapshot<Map<String, dynamic>>>? personnalData =
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots();

    return StreamBuilder<DocumentSnapshot>(
        stream: personnalData,
        builder: (context, userssnapshot) {
          if (userssnapshot.hasData) {
            final data = userssnapshot.data;
            return Scaffold(
              backgroundColor: Colors.grey[200],
              appBar: AppBar(
                automaticallyImplyLeading: true,
                iconTheme: IconThemeData(color: Colors.white),
                backgroundColor: Colors.deepPurple,
              ),
              body: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.deepPurple, width: 2)),
                    child: ClipOval(
                      child: Image.network(
                        data!['imageurl'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    data['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    data['email'],
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Customrow(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfile()));
                        },
                        icons: Icons.person,
                        title: 'Profile'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Customrow(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingsPage()));
                        },
                        icons: Icons.settings,
                        title: 'Settings'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Customrow(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HospitalDetails()),
                          );
                        },
                        icons: Icons.health_and_safety,
                        title: 'Hospital Details'),
                  ),
                ],
              ),
            );
          } else {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}
