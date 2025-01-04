import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicalRecords extends StatefulWidget {
  final Map<String, dynamic> data;
  const MedicalRecords({super.key, required this.data});

  @override
  State<MedicalRecords> createState() => _MedicalRecordsState();
}

class _MedicalRecordsState extends State<MedicalRecords> {
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
                final age = appointmentdata['patientage'];
                final type = appointmentdata['type'];
                final description = appointmentdata['description'];
                final imageurl = appointmentdata['doctorimageurl'];
                final rating = appointmentdata['rating'];
                final gender = appointmentdata['gender'];
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4), // Add vertical spacing here
                    child: MedicalRecordTile(age: age,
                    gender: gender,
                      approved: approved,
                      url: imageurl,
                      rating: rating,
                      type: type,
                      description: description,
                      ontap: () {},
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

class MedicalRecordTile extends StatefulWidget {
  final String reason;
  final String doctorsname;
  final String date;
  final String time;
  final String description;
  final String url;
  final double rating;
  final String type;
  final bool approved;
  final String age;
  final String gender;
  final void Function()? onPressed;
  final void Function()? ontap;
  final bool isapproved;
  const MedicalRecordTile(
      {super.key,
      required this.age,
      required this.gender,
      required this.approved,
      required this.url,
      required this.rating,
      required this.type,
      required this.description,
      required this.onPressed,
      required this.reason,
      required this.doctorsname,
      required this.date,
      required this.isapproved,
      required this.ontap,
      required this.time});

  @override
  State<MedicalRecordTile> createState() => _MedicalRecordTileState();
}

class _MedicalRecordTileState extends State<MedicalRecordTile> {
  void showdialogform(double screenwidth) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            insetPadding: EdgeInsets.all(15),
            child: DialogContainerMedical(
              age: widget.age,
              gender: widget.age,
              description: widget.description,
              rating: widget.rating,
              url: widget.url,
              name: widget.doctorsname,
              type: widget.type,
              approved: widget.approved,
              onPressed: () {
                Navigator.pop(context);
              },
              screenwidth: screenwidth,
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        color: const Color.fromARGB(136, 79, 34, 153),
        shadowColor: const Color.fromARGB(24, 99, 69, 155),
        elevation: 15,
        child: InkWell(
          onTap: () {
            showdialogform(MediaQuery.of(context).size.width);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.doctorsname,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.reason,
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
                              widget.date,
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
                            Icon(Icons.alarm),
                            Text(
                              widget.time,
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
                widget.isapproved
                    ? Text(
                        'Approved',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      )
                    : ElevatedButton(
                        onPressed: widget.onPressed,
                        child: Text(
                          'Delete',
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DialogContainerMedical extends StatefulWidget {
  final double screenwidth;

  final double rating;
  final String url;
  final String age;
  final String name;
  final String type;
  final String description;
  final String gender;
  final void Function()? onPressed;
  final bool approved;

  const DialogContainerMedical({
    super.key,
    required this.age,
    required this.gender,
    required this.description,
    required this.screenwidth,
    required this.rating,
    required this.url,
    required this.name,
    required this.type,
    required this.approved,
    required this.onPressed,
  });

  @override
  State<DialogContainerMedical> createState() => _DialogContainerState();
}

class _DialogContainerState extends State<DialogContainerMedical> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 650,
      width: widget.screenwidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Appointment Details",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: FileImage(File(widget.url)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.type,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.rating} ★",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.approved ? "Approved" : "Not approved",
                      style: TextStyle(
                        color: widget.approved ? Colors.green : Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            DetailRow(label: "Full Name", value: widget.name),
            const SizedBox(height: 10),
            DetailRow(label: "Age", value: widget.age),
            const SizedBox(height: 10),
            DetailRow(label: "Gender", value: "Male"),
            const SizedBox(height: 10),
            DetailRow(label: "Purpose of Visit", value: "General Checkup"),
            const SizedBox(height: 10),
            DetailRow(
                label: "Date",
                value: DateFormat('dd-MM-yyyy').format(selectedDate)),
            const SizedBox(height: 10),
            DetailRow(label: "Describe Condition", value: widget.description),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
