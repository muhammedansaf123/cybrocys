import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/appointments/appointmentshow.dart';
import 'package:first_app/profile/edit_profile.dart';
import 'package:first_app/userdata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SurgeryAdmit extends StatelessWidget {
  const SurgeryAdmit({super.key});

  @override
  Widget build(BuildContext context) {
    final userdata =
        Userdata(uid: FirebaseAuth.instance.currentUser!.uid).getData();
    print('rdrrdrrr$userdata');
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.deepPurple,
            title: Text(
              "Surgeries & Admit",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(child: Text("Surgeries")),
                  Tab(child: Text("Admit"))
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('appointments')
                          .where('doctorid',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .where('prescribed', isEqualTo: 'surgery')
                          .where("note", isNotEqualTo: "")
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          // ignore: avoid_print
                          print('Error fetching data: ${snapshot.error}');
                          return const Center(
                              child: Text('Error fetching data'));
                        }

                        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('No Appointments found found'));
                        }
                        return SizedBox(
                          child: ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final appointmentdata =
                                    snapshot.data!.docs[index];
                                final appointmentid =
                                    appointmentdata['appointmentid'];
                                return Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            4), // Add vertical spacing here
                                    child: Appointmentshowtile(
                                        appointmentdata: appointmentdata,
                                        userdata: userdata));
                              }),
                        );
                      },
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('appointments')
                          .where('doctorid',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .where('prescribed', isEqualTo: 'admit')
                          .where("note", isNotEqualTo: "")
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          // ignore: avoid_print
                          print('Error fetching data: ${snapshot.error}');
                          return const Center(
                              child: Text('Error fetching data'));
                        }

                        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('No Appointments found found'));
                        }
                        return SizedBox(
                          child: ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final appointmentdata =
                                    snapshot.data!.docs[index];
                                final appointmentid =
                                    appointmentdata['appointmentid'];
                                return Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            4), // Add vertical spacing here
                                    child: Appointmentshowtile(
                                        appointmentdata: appointmentdata,
                                        userdata: userdata));
                              }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class Appointmentshowtile extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> appointmentdata;

  final Future<Map<String, dynamic>> userdata;
  const Appointmentshowtile({
    super.key,
    required this.appointmentdata,
    required this.userdata,
  });

  @override
  State<Appointmentshowtile> createState() => _MedicalRecordTileState();
}

class _MedicalRecordTileState extends State<Appointmentshowtile> {
  @override
  Widget build(BuildContext context) {
    final date = widget.appointmentdata['date'].toDate();

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        color: const Color.fromARGB(136, 79, 34, 153),
        shadowColor: const Color.fromARGB(24, 99, 69, 155),
        elevation: 15,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.appointmentdata['patientname'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.appointmentdata['reason'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month),
                          Text(
                            DateFormat("dd/MM/yyyy").format(date),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.local_hospital),
                          Text(
                            widget.appointmentdata['note'],
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Icon(
                IconData(
                  0xf07ac,
                  fontFamily: 'MaterialIcons',
                ),
                size: 40,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
