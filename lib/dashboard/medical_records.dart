import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MedicalRecords extends StatelessWidget {
  final Map<String, dynamic> data;
  const MedicalRecords({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Medical Records',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .orderBy('approved', descending: true)
            .where('patientid',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // ignore: avoid_print
            print('Error fetching data: ${snapshot.error}');
            return const Center(child: Text('Error fetching data'));
          }

          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Appointments found found'));
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final appointmentdata = snapshot.data!.docs[index];

                final patientid = appointmentdata['patientid'];
                final doctorsid = appointmentdata['doctorid'];
                final date = appointmentdata['date'];
                final timeslot = appointmentdata['timeslot'];
                final reason = appointmentdata['reason'];
                final doctorsname = appointmentdata['doctorsname'];
                final appointmentid = appointmentdata['appointmentid'];
                final approved = appointmentdata['approved'];
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4), // Add vertical spacing here
                    child: MedicalRecordTile(
                      isapproved: approved,
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('appointments')
                            .doc(appointmentid)
                            .delete();
                      },
                      reason: reason,
                      date: date,
                      time: timeslot,
                      doctorsname: doctorsname,
                    ));
              });
        },
      ),
    );
  }
}

class MedicalRecordTile extends StatelessWidget {
  final String reason;
  final String doctorsname;
  final String date;
  final String time;
  final void Function()? onPressed;
  final bool isapproved;
  const MedicalRecordTile(
      {super.key,
      required this.onPressed,
      required this.reason,
      required this.doctorsname,
      required this.date,
      required this.isapproved,
      required this.time});

  @override
  Widget build(BuildContext context) {
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
                    doctorsname,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    reason,
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
                        children: [   Icon(Icons.calendar_month),
                          Text(
                            date,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      Row(
                        children: [Icon(Icons.alarm),
                          Text(
                            time,
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
              isapproved
                  ? Text(
                      'Approved',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    )
                  : ElevatedButton(onPressed: onPressed, child: Text('Delete'))
            ],
          ),
        ),
      ),
    );
  }
}
