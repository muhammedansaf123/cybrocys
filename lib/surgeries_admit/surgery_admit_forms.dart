import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:hospital_managment/appointments/appointmentsbooking.dart';
import 'package:hospital_managment/components/components.dart';
import 'package:hospital_managment/dashboard/dashboard.dart';
import 'package:intl/intl.dart';

class SurgeryAdmitForms extends StatefulWidget {
  final String reason;
  final String appointmentid;
  final String patientid;
  final String patientname;
  final String doctorsname;
  final bool issurgery;
  final Map userdata;
  const SurgeryAdmitForms(
      {super.key,
      required this.patientname,
      required this.doctorsname,
      required this.patientid,
      required this.userdata,
      required this.issurgery,
      required this.appointmentid,
      required this.reason});

  @override
  State<SurgeryAdmitForms> createState() => _SurgeryAdmitFormsState();
}

class _SurgeryAdmitFormsState extends State<SurgeryAdmitForms> {
  TextEditingController typecontroller = TextEditingController();
  TextEditingController datecontroller = TextEditingController();

  //TextEditingController notecontroller = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController anesthesiaController = TextEditingController();
  TextEditingController surgeonController = TextEditingController();
  TextEditingController preSurgeryInstructionsController =
      TextEditingController();

  TextEditingController wardController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  TextEditingController specialInstructionsController = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  DateTime? _selectedDate;

  // Updated surgery method

  void surgery() async {
    final date = DateFormat('dd-MM-yyyy').format(_selectedDate!);
    try {
      FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentid)
          .update({'note': "requested for a Surgery", 'prescribed': 'surgery'});
      FirebaseFirestore.instance
          .collection('surgeries')
          .doc(widget.appointmentid)
          .set({
        'id': widget.appointmentid,
        'typeofsurgery': typecontroller.text,
        'date': date,
        'reason': widget.reason,
        'doctorid': uid,
        'status': 'Pending',
        'patientsname': widget.patientname,
        'doctorsname': widget.doctorsname,
        'patientid': widget.patientid,
        'room': roomController.text,
        'anesthesiaType': anesthesiaController.text,
        'preSurgeryInstructions': preSurgeryInstructionsController.text,
        'payment': 'notpaid'
      });
      _clearFields();
      _navigateToHomepage();
    } catch (e) {
      print(e);
    }
  }

  // Updated admit method
  void admit() async {
    final date = DateFormat('dd-MM-yyyy').format(_selectedDate!);
    try {
      FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentid)
          .update({'note': "requested for an Admit", 'prescribed': 'admit'});
      FirebaseFirestore.instance
          .collection('admits')
          .doc(widget.appointmentid)
          .set({
        'id': widget.appointmentid,
        'reason': widget.reason,
        'doctorid': uid,
        'patientsname': widget.patientname,
        'doctorsname': widget.doctorsname,
        'patientid': widget.patientid,
        'status': 'Pending',
        'ward': wardController.text,
        'durationOfStay': durationController.text,
        'admissionDate': date,
        'specialInstructions': specialInstructionsController.text,
        'payment': 'notpaid'
      });
      _clearFields();
      _navigateToHomepage();
    } catch (e) {
      print(e);
    }
  }

  void _clearFields() {
    typecontroller.clear();
    datecontroller.clear();

    roomController.clear();
    anesthesiaController.clear();
    surgeonController.clear();
    preSurgeryInstructionsController.clear();

    wardController.clear();
    durationController.clear();

    specialInstructionsController.clear();
  }

  void _navigateToHomepage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Homepage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    if (mounted) {
      setState(() {
        _selectedDate = DateTime.now();
        print(DateTime.now());

        date = DateFormat("dd/MM/yyyy").format(DateTime.now());
        print(date);
        appointmentDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
        print(appointmentDate);
      });
    }
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Fill in the forms',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Text(
                "Enter Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              if (widget.issurgery) ...[
                AppointmentTextfield(
                  controller: typecontroller,
                  hinttext: "Type of Surgery",
                ),
                SizedBox(height: 20),
                AppointmentTextfield(
                  controller: roomController,
                  hinttext: "Room Number (for surgery)",
                ),
                SizedBox(height: 20),
                AppointmentTextfield(
                  controller: anesthesiaController,
                  hinttext: "Anesthesia Type",
                ),
                SizedBox(height: 20),
                AppointmentTextfield(
                  controller: preSurgeryInstructionsController,
                  hinttext: "Pre-Surgery Instructions",
                ),
              ] else ...[
                AppointmentTextfield(
                  controller: wardController,
                  hinttext: "Ward Number (for admit)",
                ),
                SizedBox(height: 20),
                AppointmentTextfield(
                  controller: durationController,
                  hinttext: "Duration of Stay",
                ),
                SizedBox(height: 20),
                AppointmentTextfield(
                  controller: specialInstructionsController,
                  hinttext: "Special Instructions",
                ),
              ],
              SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    barrierDismissible: true,
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      appointmentDate =
                          DateFormat('dd-MM-yyyy').format(_selectedDate!);
                    });
                  }
                },
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('dd-MM-yyyy').format(_selectedDate!),
                        style: TextStyle(color: Colors.black87),
                      ),
                      Spacer(),
                      Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Mybutton(
                load: false,
                onPressed: widget.issurgery ? surgery : admit,
                text: "Submit",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
