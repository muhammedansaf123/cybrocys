import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/appointments/appointmentsbooking.dart';
import 'package:first_app/appointments/appointmentshow.dart';
import 'package:first_app/components/components.dart';
import 'package:first_app/dashboard/dashboard.dart';
import 'package:first_app/user/userdata.dart';
import 'package:flutter/material.dart';

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

  // Updated surgery method

  void surgery() async {
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
        'date': datecontroller.text,
        'reason': widget.reason,
        'doctorid': uid,
        'status': 'Pending',
        'patientsname': widget.patientname,
        'doctorsname': widget.doctorsname,
        'patientid': widget.patientid,
        'room': roomController.text,
        'anesthesiaType': anesthesiaController.text,
        'preSurgeryInstructions': preSurgeryInstructionsController.text,
      });
      _clearFields();
      _navigateToHomepage();
    } catch (e) {
      print(e);
    }
  }

  // Updated admit method
  void admit() async {
    final patientdata = await Userdata(uid: widget.patientid).getData();
    print(patientdata['name']);
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
        'admissionDate': datecontroller.text,
        'specialInstructions': specialInstructionsController.text,
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
              AppointmentTextfield(
                controller: datecontroller,
                hinttext: "Scheduled Date",
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
