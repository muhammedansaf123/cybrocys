import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:hospital_managment/appointments/appointmentsbooking.dart';
import 'package:hospital_managment/appointments/components/custom_textfield.dart';
import 'package:hospital_managment/components/components.dart';
import 'package:hospital_managment/dashboard/dashboard.dart';
import 'package:hospital_managment/surgeries_admit/components/surgery_admit_tile.dart';
import 'package:hospital_managment/surgeries_admit/surgery_admit.dart';
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
  final TextEditingController startdatecontroler = TextEditingController();
  final TextEditingController enddatecontroller = TextEditingController();
  final TextEditingController _differenceController = TextEditingController();
  TextEditingController wardController = TextEditingController();
  int? durationinseconds;
  TextEditingController specialInstructionsController = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _startDateError;
  String? _endDateError;
  bool _submitted = false;
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SurgeryAdmit()),
    );
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to all text controllers
    typecontroller.addListener(_onTextChanged);
    roomController.addListener(_onTextChanged);
    anesthesiaController.addListener(_onTextChanged);
    wardController.addListener(_onTextChanged);
    _differenceController.addListener(_onTextChanged);
    specialInstructionsController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_submitted) {
      setState(() {
        _formKey.currentState!.validate();
      });
    }
  }

  void _submitForm() {
    setState(() {
      _submitted = true;
      _startDateError =
          _startDate == null ? 'Please select a start date' : null;
      _endDateError = _endDate == null ? 'Please select an end date' : null;
    });

    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      print("Form Submitted Successfully!");
      if (widget.issurgery) {
        surgery();
      } else {
        admit();
      }
    }
  }

  Future<void> _pickDateAndTime(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? (_startDate ?? DateTime.now()));
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
            _startDateError = null;
            if (_endDate != null && _endDate!.isBefore(_startDate!)) {
              _endDate = null;
              _endDateError = 'End date must be after start date';
            }
          } else {
            if (_startDate == null) {
              _startDateError = 'Please select a start date first';
            } else {
              _endDate = finalDateTime;
              _endDateError = null;
            }
          }
          _calculateDifference();
        });
      }
    }
    if (_startDate != null) {
      startdatecontroler.text =
          DateFormat('dd/MM/yyyy HH:mm').format(_startDate!);
    }
    if (_endDate != null) {
      enddatecontroller.text = DateFormat('dd/MM/yyyy HH:mm').format(_endDate!);
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

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              border: Border.all(color: Colors.blueGrey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
            child: Text(
              date != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(date)
                  : label,
              style: TextStyle(fontSize: 16.0, color: Colors.blueGrey[700]),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              error,
              style: const TextStyle(color: Color(0xffb73e37), fontSize: 12),
            ),
          ),
        if (error == null)
          SizedBox(
            height: 10,
          ),
      ],
    );
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                const Text(
                  "Enter Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 25),
                if (widget.issurgery) ...[
                  SurgeryAdmitTile(
                    controller: typecontroller,
                    hinttext: "Type of Surgery",
                    validator: (value) =>
                        value!.isEmpty ? "Please fill this field" : null,
                  ),
                  SurgeryAdmitTile(
                    controller: roomController,
                    hinttext: "Room Number (for surgery)",
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? "Room no. is Required" : null,
                  ),
                  SurgeryAdmitTile(
                    controller: anesthesiaController,
                    hinttext: "Anesthesia Type",
                    validator: (value) =>
                        value!.isEmpty ? "Please fill this field" : null,
                  ),
                ] else ...[
                  SurgeryAdmitTile(
                    controller: wardController,
                    hinttext: "Ward Number (for admit)",
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? "Ward no. is required" : null,
                  ),
                ],
                _startDate == null
                    ? _buildDatePickerField(
                        label: 'Select a Starting Date & Time',
                        date: _startDate,
                        onTap: () => _pickDateAndTime(context, true),
                        error: _startDateError,
                      )
                    : SurgeryAdmitTile(
                        onTap: () {
                          _pickDateAndTime(context, true);
                        },
                        readOnly: true,
                        controller: startdatecontroler,
                        hinttext: "Start date",
                      ),
                const SizedBox(height: 10.0),
                _endDate == null
                    ? _buildDatePickerField(
                        label: 'Select an Ending Date & Time',
                        date: _endDate,
                        onTap: () => _pickDateAndTime(context, false),
                        error: _endDateError,
                      )
                    : SurgeryAdmitTile(
                        onTap: () {
                          _pickDateAndTime(context, true);
                        },
                        readOnly: true,
                        controller: enddatecontroller,
                        hinttext: "End date",
                      ),
                const SizedBox(height: 10.0),
                SurgeryAdmitTile(
                  controller: _differenceController,
                  hinttext: "Hours",
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? "Please fill this field" : null,
                ),
                SurgeryAdmitTile(
                  controller: specialInstructionsController,
                  hinttext: "Special Instructions",
                  validator: (value) =>
                      value!.isEmpty ? "Instructions are required" : null,
                ),
                SizedBox(height: 10),
                Mybutton(
                  load: false,
                  onPressed: _submitForm,
                  text: "Submit",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
