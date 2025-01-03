import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/components/components.dart';

import 'package:first_app/components/const.dart';
import 'package:first_app/dashboard/appointments.dart';
import 'package:first_app/dashboard/medical_records.dart';
import 'package:first_app/login/login_page.dart';
import 'package:first_app/profile/edit_profile.dart';
import 'package:first_app/profile/hospital/hospital_details.dart';
import 'package:first_app/profile/profile.dart';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

class Homepage extends StatefulWidget {
  const Homepage({
    super.key,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool? biometrics;
  bool? authsettings;
  late final LocalAuthentication localAuth;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
   Map<String,dynamic>? userdata;
  @override
  void initState() {
    super.initState();

    final id = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        print('Document exists on the database');
        final data = documentSnapshot.data() as Map<String, dynamic>;
        authsettings = data['authentication'];
        print('auth is $authsettings');
        setState(() {
          userdata=data;
        });
        if (authsettings == true) {
          setState(() {
            biometrics = !authsettings!;

          });
          print("hello");
          if (mounted) {
            localAuth = LocalAuthentication();
            localAuth.isDeviceSupported().then((bool isSupported) {
              if (isSupported) {
                authentication();
              } else {
                print("Device does not support authentication");
              }
            });
          }
        } else {
          if (mounted) {
            setState(() {
              biometrics = !authsettings!;
            });
          }
        }

        if (data['roles'] == 'doctor') {
          await FirebaseFirestore.instance.collection('doctors').doc(id).update({
            'name': data['name'],
            'uid': id,
            'imageurl':data['imageurl']
          });
        }
        if (data['roles'] == 'patient') {
          await FirebaseFirestore.instance.collection('patient').doc(id).update({
            'name': data['name'],
            'uid': id,
          });
        }
      }
    });
  }

  Future<void> authentication() async {
    try {
      bool isAuthenticated = await localAuth.authenticate(
        localizedReason: "Authenticate to continue",
        options: AuthenticationOptions(
          stickyAuth: false,
          biometricOnly: true,
        ),
      );
      print('Authentication success: $isAuthenticated');

      if (mounted) {
        setState(() {
          biometrics = isAuthenticated;
        });
      }
    } catch (e) {
      print('Authentication error: $e');
    }
    if (!mounted) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user!.uid;

    late Stream<DocumentSnapshot<Map<String, dynamic>>>? personnalData =
        FirebaseFirestore.instance.collection('users').doc(uid).snapshots();

    return StreamBuilder<DocumentSnapshot>(
        stream: personnalData,
        builder: (context, userssnapshot) {
          if (userssnapshot.hasData) {
            final data = userssnapshot.data;
            print(data);
            print(authsettings);
            if (data!['roles'] == 'patient' && biometrics == true) {
              return Scaffold(
                key: _key,
                drawer: Drawer(
                  child: Container(
                    color: Colors.deepPurple.withAlpha(15),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 60,
                        ),
                        Customrow(
                            icons: Icons.calendar_month_sharp,
                            title: 'Appontments',
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AppointmentsPage(data: userdata!,)));

                              _key.currentState!.closeDrawer();
                            }),
                        Customrow(
                            icons: Icons.medical_information,
                            title: 'Medical Records',
                            onTap: () {  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MedicalRecords(data: userdata!,)));})
                      ],
                    ),
                  ),
                ),
                appBar: AppBar(
                    actions: [
                      IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.notifications_active))
                    ],
                    leadingWidth: 120,
                    leading: Row(
                      children: [
                        IconButton(
                            onPressed: () => _key.currentState!.openDrawer(),
                            icon: Icon(Icons.menu)),
                        SizedBox(
                          width: 15,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 158, 77, 130),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              backgroundImage: FileImage(File(
                                data!['imageurl'],
                              )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    titleSpacing: 0,
                    centerTitle: true,
                    title: Text('Dashboard')),
                body: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 160,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 140,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: InkWell(
                                      splashColor:
                                          const Color.fromARGB(255, 28, 20, 41),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            'Clinic Visit',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'make an appointment',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Container(
                                    height: 140,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          child: Icon(
                                            Icons.home_filled,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          'Home Visit',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'call the doctor home',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      height: 400,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: SfCalendar(
                                        dataSource: getCalendarDataSource(),
                                        view: CalendarView.month,
                                        monthViewSettings:
                                            MonthViewSettings(showAgenda: true),
                                      )))
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  height: 400,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      Row(children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Recent Lab esults',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Spacer(),
                                      ]),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          LabResultsTile(
                                            progresscolor: Colors.red,
                                            iconcolor: Colors.red,
                                            percentage: 0.4,
                                            icons: Icons.water_drop_outlined,
                                            color: const Color.fromARGB(
                                                    255, 151, 94, 90)
                                                .withOpacity(0.3),
                                            count: '2.56 cells/L',
                                            title: 'Blood Count',
                                          ),
                                          Spacer(),
                                          LabResultsTile(
                                            progresscolor: Colors.green,
                                            iconcolor: Colors.green,
                                            percentage: 0.9,
                                            icons: Icons.healing_outlined,
                                            color: const Color.fromARGB(
                                                    255, 111, 145, 112)
                                                .withOpacity(0.3)
                                                .withOpacity(0.3),
                                            count: '75 mg/dL ',
                                            title: 'Sugar Count',
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          LabResultsTile(
                                            progresscolor: Colors.orange,
                                            iconcolor: Colors.orange,
                                            percentage: 0.7,
                                            icons: Icons.bolt_sharp,
                                            color: const Color.fromARGB(
                                                    255, 185, 148, 92)
                                                .withOpacity(0.3),
                                            count: '140 mmHg',
                                            title: 'BP',
                                          ),
                                          Spacer(),
                                          LabResultsTile(
                                            progresscolor: Colors.green,
                                            iconcolor: Colors.green,
                                            percentage: 0.9,
                                            icons: Icons.health_and_safety,
                                            color: const Color.fromARGB(
                                                    255, 111, 145, 112)
                                                .withOpacity(0.3)
                                                .withOpacity(0.3),
                                            count: '180 mg/dl',
                                            title: 'Cholesterol',
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            height: 450,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Current Appointments',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    ElevatedButton.icon(
                                      style: ButtonStyle(
                                          shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      )),
                                      onPressed: () {},
                                      label: Text('Re schedule'),
                                      icon: Icon(Icons.restore),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  height: 156,
                                  child: ListView.builder(
                                    itemCount: currentappointments.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: const Color.fromARGB(
                                                  255, 144, 111, 201)),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                height: 40,
                                                width: 40,
                                                child: Image.asset(
                                                  'assets/doctor (2).png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Spacer(),
                                              SizedBox(
                                                width: 80,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      currentappointments[index]
                                                          .name,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      currentappointments[index]
                                                          .expertise,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Spacer(),
                                              SizedBox(
                                                child: SizedBox(
                                                  width: 90,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        currentappointments[
                                                                index]
                                                            .date,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Text(
                                                        currentappointments[
                                                                index]
                                                            .time,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Last Appointments',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    ElevatedButton.icon(
                                      style: ButtonStyle(
                                          shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      )),
                                      onPressed: () {},
                                      label: Text('filter by'),
                                      icon: Icon(Icons.filter_list_off_sharp),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  height: 156,
                                  child: ListView.builder(
                                    itemCount: appointmentdetails.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.deepPurple),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                height: 40,
                                                width: 40,
                                                child: Image.asset(
                                                  'assets/doctor (3).png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Spacer(),
                                              SizedBox(
                                                width: 100,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      appointmentdetails[index]
                                                          .name,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      appointmentdetails[index]
                                                          .expertise,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Spacer(),
                                              SizedBox(
                                                width: 80,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      appointmentdetails[index]
                                                          .date,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    SizedBox(
                                                      height: 2,
                                                    ),
                                                    Text(
                                                      appointmentdetails[index]
                                                          .time,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: Container(
                          //         padding: EdgeInsets.symmetric(
                          //             horizontal: 10, vertical: 10),
                          //         height: 355,
                          //         decoration: BoxDecoration(
                          //             color: Colors.grey[200],
                          //             borderRadius: BorderRadius.circular(10)),
                          //         child: Column(
                          //           crossAxisAlignment: CrossAxisAlignment.start,
                          //           children: [
                          //             Text(
                          //               'Available Doctors',
                          //               style: TextStyle(
                          //                   color: Colors.black,
                          //                   fontWeight: FontWeight.bold),
                          //             ),
                          //             SizedBox(
                          //               height: 15,
                          //             ),
                          //             Container(
                          //               height: 300,
                          //               child: ListView.builder(
                          //                 itemCount: docotDetails.length,
                          //                 itemBuilder:
                          //                     (BuildContext context, int index) {
                          //                   return Padding(
                          //                     padding: const EdgeInsets.only(bottom: 5),
                          //                     child: Container(
                          //                       height: 60,
                          //                       decoration: BoxDecoration(
                          //                           borderRadius:
                          //                               BorderRadius.circular(5),
                          //                           color: Colors.deepPurple),
                          //                       child: Row(
                          //                         children: [
                          //                           SizedBox(
                          //                             width: 10,
                          //                           ),
                          //                           Container(
                          //                             height: 40,
                          //                             width: 40,
                          //                             child: Image.asset(
                          //                               docotDetails[index].image,
                          //                               fit: BoxFit.cover,
                          //                             ),
                          //                           ),
                          //                           Spacer(),
                          //                           Column(
                          //                             mainAxisAlignment:
                          //                                 MainAxisAlignment.center,
                          //                             children: [
                          //                               Text(
                          //                                 docotDetails[index].name,
                          //                                 style: TextStyle(
                          //                                     color: Colors.white,
                          //                                     fontWeight:
                          //                                         FontWeight.bold),
                          //                               ),
                          //                               Text(
                          //                                 docotDetails[index].expertise,
                          //                                 style: TextStyle(
                          //                                     color: Colors.white),
                          //                               ),
                          //                             ],
                          //                           ),
                          //                           Spacer(),
                          //                           Column(
                          //                             mainAxisAlignment:
                          //                                 MainAxisAlignment.center,
                          //                             crossAxisAlignment:
                          //                                 CrossAxisAlignment.center,
                          //                             children: [
                          //                               Text(
                          //                                 'Rating',
                          //                                 style: TextStyle(
                          //                                     color: Colors.white),
                          //                               ),
                          //                               Row(
                          //                                 mainAxisAlignment:
                          //                                     MainAxisAlignment.end,
                          //                                 children: [
                          //                                   Icon(
                          //                                     Icons.star,
                          //                                     color: Colors.amber,
                          //                                   ),
                          //                                   SizedBox(
                          //                                     width: 3,
                          //                                   ),
                          //                                   Text(
                          //                                     docotDetails[index]
                          //                                         .rating
                          //                                         .toString(),
                          //                                     style: TextStyle(
                          //                                         color: Colors.white),
                          //                                   )
                          //                                 ],
                          //                               ),
                          //                             ],
                          //                           ),
                          //                           SizedBox(
                          //                             width: 20,
                          //                           ),
                          //                         ],
                          //                       ),
                          //                     ),
                          //                   );
                          //                 },
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (biometrics == false) {
              return Scaffold(
                body: Container(
                  color: Colors.black,
                  child: Center(
                    child: IconButton(
                        onPressed: () {
                          authentication();
                        },
                        icon: Icon(
                          Icons.restore_outlined,
                          size: 25,
                          color: Colors.white,
                        )),
                  ),
                ),
              );
            } else if (data['roles'] == 'doctor') {
              return Scaffold(
                appBar: AppBar(
                    centerTitle: true,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 158, 77, 130),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            backgroundImage: FileImage(File(data!['imageurl'])),
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginDemo()));
                          },
                          icon: Icon(Icons.notifications_active))
                    ],
                    title: Text('Dashboard')),
                body: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 160,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 140,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/hospital.png',
                                            scale: 5,
                                            fit: BoxFit.fill,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'Appointments',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'See all of your appointments',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 140,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/patienttile.png',
                                            scale: 9,
                                            fit: BoxFit.fill,
                                          ),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                            'Patients',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'See all of your patients',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                                child: Doctorcharts()),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                color: Colors.grey[200],
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 10,
                                          color: Colors.deepPurple,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Surgeries'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 10,
                                          color: Colors.green,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Done'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 10,
                                          color: Colors.orangeAccent,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Pending'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 10,
                                          color: Colors.blueAccent,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Consultation'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding: EdgeInsets.all(15),
                              height: 350,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Containertile(
                                          percentage: '10%',
                                          isdown: true,
                                          icons: Icons.person,
                                          color: const Color.fromARGB(
                                              255, 219, 164, 160),
                                          daylength: 'last 7 days',
                                          title: 'total patients',
                                          value: 2034),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Containertile(
                                          percentage: '80%',
                                          icons: Icons.local_hospital,
                                          color: const Color.fromARGB(
                                              255, 119, 148, 145),
                                          daylength: 'last 2 weaks',
                                          title: 'Lab reports',
                                          value: 50)
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      Containertile(
                                          percentage: '20%',
                                          isdown: true,
                                          icons: Icons
                                              .running_with_errors_outlined,
                                          color: const Color.fromARGB(
                                              255, 192, 228, 181),
                                          daylength: 'last 7 days',
                                          title: 'Urgent',
                                          value: 37),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Containertile(
                                          percentage: '30%',
                                          icons: Icons.car_crash_sharp,
                                          color: const Color.fromARGB(
                                              255, 219, 210, 160),
                                          daylength: 'last 7 days',
                                          title: 'Surgeries',
                                          value: 123)
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                                child: PaymentChart()),
                          ],
                        ),
                      ),
                    )),
              );
            } else if (data['roles'] == 'manager') {
              return Scaffold(
                  appBar: AppBar(
                      toolbarHeight: 40,
                      actions: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.notifications_active))
                      ],
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 158, 77, 130),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              backgroundImage:
                                  FileImage(File(data!['imageurl'])),
                            ),
                          ),
                        ),
                      ),
                      centerTitle: true,
                      title: Text('Dashboard')),
                  body: Container(
                    padding: EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Customcontainer(
                            widget: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 140,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: InkWell(
                                      splashColor:
                                          const Color.fromARGB(255, 28, 20, 41),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            'Doctor Details',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'see all doctors details',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HospitalDetails()));
                                    },
                                    child: Container(
                                      height: 140,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: Icon(
                                              Icons.location_city,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            'Hospital Details',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'see hospital Details',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 400,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10)),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Total number of doctors',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      children: [
                                        DoctorsNumbertile(
                                          title: 'Neurologist',
                                          value: '12',
                                        ),
                                        SizedBox(height: 10),
                                        DoctorsNumbertile(
                                          title: 'Cardiologist',
                                          value: '15',
                                        ),
                                        SizedBox(height: 10),
                                        DoctorsNumbertile(
                                          title: 'Dermatologist',
                                          value: '20',
                                        ),
                                        SizedBox(height: 10),
                                        DoctorsNumbertile(
                                          title: 'Pediatrician',
                                          value: '18',
                                        ),
                                        SizedBox(height: 10),
                                        DoctorsNumbertile(
                                          title: 'Orthopedist',
                                          value: '16',
                                        ),
                                        SizedBox(height: 10),
                                        DoctorsNumbertile(
                                          title: 'Oncologist',
                                          value: '14',
                                        ),
                                        SizedBox(height: 10),
                                        DoctorsNumbertile(
                                          title: 'Psychiatrist',
                                          value: '19',
                                        ),
                                        SizedBox(height: 10),
                                        DoctorsNumbertile(
                                          title: 'General Practitioner',
                                          value: '20',
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 400,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Online visits - last weak',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                managerchart(),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            height: 400,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: ActivityGraph(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ));
            } else {
              return Scaffold(
                body: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
          } else {
            return Scaffold(
              body: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
        });
  }
}
