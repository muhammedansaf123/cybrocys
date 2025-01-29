import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:hospital_managment/appointments/appointmentsbooking.dart';
import 'package:hospital_managment/appointments/components/custom_textfield.dart';
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

  final TextEditingController _differenceController = TextEditingController();
  TextEditingController wardController = TextEditingController();
  int? durationinseconds;
  TextEditingController specialInstructionsController = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  DateTime? _selectedDate;

  DateTime? _startDate;
  DateTime? _endDate;
  Future<void> _pickDateAndTime(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? (_startDate != null ? _startDate! : DateTime.now()));
    DateTime firstDate =
        isStartDate ? DateTime.now() : (_startDate ?? DateTime.now());

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartDate) {
            _startDate = finalDateTime;
            if (_endDate != null && _endDate!.isBefore(_startDate!)) {
              _endDate = null;
            }
          } else {
            _endDate = finalDateTime;
          }
          _calculateDifference();
        });
      }
    }
  }

  void _calculateDifference() {
    if (_startDate != null && _endDate != null) {
      final difference = _endDate!.difference(_startDate!);
      final hours = difference.inHours;
      setState(() {
        durationinseconds = difference.inSeconds;
      });
      _differenceController.text = '$hours hours';
    } else {
      _differenceController.clear();
    }
  }

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
        'date': _startDate,
        'enddate': _endDate,
        'reason': widget.reason,
        'doctorid': uid,
        'status': 'Pending',
        'patientsname': widget.patientname,
        'doctorsname': widget.doctorsname,
        'patientid': widget.patientid,
        'room': roomController.text,
        'anesthesiaType': anesthesiaController.text,
        'preSurgeryInstructions': specialInstructionsController.text,
        'durationOfStay': _differenceController.text,
        'durationinseconds': durationinseconds,
        'payment': 'notpaid',
        'starttime': null,
        'isstarted': false,
        'ispaused': false,
      });
      _clearFields();
      _navigateToHomepage();
    } catch (e) {
      print(e);
    }
  }

  // Updated admit method
  void admit() async {
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
        'durationOfStay': _differenceController.text,
        'admissionDate': _startDate,
        'enddate': _endDate,
        'specialInstructions': specialInstructionsController.text,
        'payment': 'notpaid',
        'durationinseconds': durationinseconds,
        'starttime': null,
        'isstarted': false,
        'ispaused': false,
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
      setState(() {});
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
              SizedBox(height: 15),
              Text(
                "Enter Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 25),
              if (widget.issurgery) ...[
                AppointmentTextfield(
                  controller: typecontroller,
                  hinttext: "Type of Surgery",
                ),
                AppointmentTextfield(
                  controller: roomController,
                  hinttext: "Room Number (for surgery)",
                ),
                AppointmentTextfield(
                  controller: anesthesiaController,
                  hinttext: "Anesthesia Type",
                ),
              ] else ...[
                AppointmentTextfield(
                  controller: wardController,
                  hinttext: "Ward Number (for admit)",
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDateAndTime(context, true),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 15.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          _startDate != null
                              ? DateFormat('dd/MM/yyyy HH:mm')
                                  .format(_startDate!)
                              : 'Select a Starting Date & Time',
                          style:
                              TextStyle(fontSize: 16.0, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDateAndTime(context, false),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 15.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          _endDate != null
                              ? DateFormat('dd/MM/yyyy HH:mm').format(_endDate!)
                              : 'Select a Ending Date & Time',
                          style:
                              TextStyle(fontSize: 16.0, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              AppointmentTextfield(
                controller: _differenceController,
                hinttext: "hours",
              ),
              AppointmentTextfield(
                controller: specialInstructionsController,
                hinttext: "Special Instructions",
              ),
              SizedBox(height: 20),
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
