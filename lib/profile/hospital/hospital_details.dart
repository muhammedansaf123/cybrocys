import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hospital_managment/profile/edit_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HospitalDetails extends StatefulWidget {
  const HospitalDetails({super.key});

  @override
  State<HospitalDetails> createState() => _HospitalDetailsState();
}

List hosdata = [];
bool hospitaledit = false;

TextEditingController hospitalname = TextEditingController();
TextEditingController type = TextEditingController();
TextEditingController website = TextEditingController();
TextEditingController contact = TextEditingController();
TextEditingController location = TextEditingController();
String? roles;

class _HospitalDetailsState extends State<HospitalDetails> {
  CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('hospital');

  void getroles() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user!.uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        final data = documentSnapshot.data() as Map<String, dynamic>?;
        if (mounted) {
          setState(() {
            roles = data!['roles'];
          });
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  @override
  void initState() {
    getroles();
    super.initState();
  }

  late Stream<DocumentSnapshot<Map<String, dynamic>>>? hospitaldata =
      FirebaseFirestore.instance
          .collection('hospital')
          .doc('Hospital1')
          .snapshots();

  CollectionReference hospitalref =
      FirebaseFirestore.instance.collection('hospital');
  Future<void> updateHospital() {
    return hospitalref
        .doc('Hospital1')
        .update({
          'name': hospitalname.text,
          'contact': contact.text,
          'location': location.text,
          'type': type.text,
          'website': website.text
        })
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          roles == 'manager'
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      hospitaledit = !hospitaledit;
                      print(hospitaledit);
                    });
                  },
                  icon: hospitaledit ? Icon(Icons.close) : Icon(Icons.edit))
              : SizedBox()
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Hospital Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder(
          stream: hospitaldata,
          builder: (context, userssnapshot) {
            final data = userssnapshot.data;
            if (userssnapshot.hasData) {
              hospitalname.text = data!['name'];
              type.text = data['type'];
              website.text = data['website'];
              contact.text = data['contact'];
              location.text = data['location'];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(50),
                          border:
                              Border.all(width: 2, color: Colors.deepPurple)),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/hospital.png',
                          scale: 3,
                        ),
                      ),
                    ),
                    Text(
                      data['name'],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      data['website'],
                      style: TextStyle(fontSize: 17, color: Colors.blue),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Hospital Details',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            hospitaledit
                                ? Edittile(onTap: (){},
                                    controller: hospitalname,
                                    title: 'Hospital Name',
                                    autofocus: true,
                                  )
                                : Showtile(
                                    icons: Icons.person,
                                    data: hospitalname.text,
                                    title: 'Hospital Name'),
                            SizedBox(
                              height: 15,
                            ),
                            hospitaledit
                                ? Edittile(onTap: (){},
                                    controller: location,
                                    title: 'Location',
                                    autofocus: true,
                                  )
                                : Showtile(
                                    icons: Icons.location_on,
                                    data: location.text,
                                    title: 'Location'),
                            SizedBox(
                              height: 15,
                            ),
                            hospitaledit
                                ? Edittile(onTap: (){},
                                    controller: type,
                                    title: 'Type',
                                    autofocus: false,
                                  )
                                : Showtile(
                                    icons: Icons.type_specimen_outlined,
                                    data: type.text,
                                    title: 'Type'),
                            SizedBox(
                              height: 15,
                            ),
                            hospitaledit
                                ? Edittile(onTap: (){},
                                    controller: contact,
                                    title: 'Contact',
                                    autofocus: false,
                                  )
                                : Showtile(
                                    icons: Icons.phone,
                                    data: contact.text,
                                    title: 'Contact'),
                            SizedBox(
                              height: 15,
                            ),
                            hospitaledit
                                ? Edittile(onTap: (){},
                                    controller: website,
                                    title: 'Website',
                                    autofocus: false,
                                  )
                                : Showtile(
                                    icons: CupertinoIcons.globe,
                                    data: website.text,
                                    title: 'Website'),
                            SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            hospitaledit
                                ? SizedBox(
                                    height: 65,
                                    width: 360,
                                    child: Container(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      Colors.deepPurple)),
                                          child: Text(
                                            'Save',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          onPressed: () {
                                            updateHospital();
                                            setState(() {
                                              hospitaledit = false;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else if (userssnapshot.connectionState ==
                ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              return Scaffold(
                body: Center(
                  child: Text('unexpected error occured'),
                ),
              );
            }
          }),
    );
  }
}
