import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_managment/appointments/components/custom_textfield.dart';
import 'package:hospital_managment/appointments/provider/appointments_provider.dart';
import 'package:hospital_managment/appointments/appointmentshow.dart';
import 'package:hospital_managment/profile/edit_profile.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Doctors List',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
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
            return const Center(child: Text('No Doctors  found'));
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doctorsdata = snapshot.data!.docs[index];
                final name = doctorsdata['name'];
                final uid = doctorsdata['uid'];
                final type = doctorsdata['type'];
                final url = doctorsdata['imageurl'];
                final available = doctorsdata['available'];
                final rating = doctorsdata['rating'];

                return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4),
                    child: AppointmenttileBooking(
                        uid: uid,
                        availablity: available,
                        name: name,
                        rating: rating,
                        type: type,
                        url: url));
              });
        },
      ),
    );
  }
}

class AppointmenttileBooking extends StatefulWidget {
  final String url;
  final String name;
  final double rating;
  final String availablity;
  final String type;
  final String uid;
  const AppointmenttileBooking(
      {super.key,
      required this.availablity,
      required this.name,
      required this.rating,
      required this.type,
      required this.uid,
      required this.url});

  @override
  State<AppointmenttileBooking> createState() => _AppointmenttileState();
}

TextEditingController reasoncontroller = TextEditingController();
TextEditingController namecontroller = TextEditingController();
TextEditingController agecontroller = TextEditingController();
TextEditingController descriptioncontroller = TextEditingController();
String dropdownvalue = '8.00 AM - 9.00 AM';
final sDateFormate = "dd/MM/yyyy";
DateTime? _selectedDate;
String? date;
String? appointmentDate;
var gender = [
  'Male',
  'Female',
];
String selectedCategory = 'Male';
var items = [
  '8.00 AM - 9.00 AM',
  '9.00 AM - 10.00 AM',
  '11.00 AM - 12.00 PM',
  '1.00 PM - 2.00 PM',
  '2.00 PM - 3.00 PM',
  '3.00 PM - 4.00 PM',
  '5.00 PM - 6.00 PM',
];

class _AppointmenttileState extends State<AppointmenttileBooking> {
  void appointmentRequest() {
    DateTime today = DateTime.now();
    String reasons = reasoncontroller.text;
    final appointmentid = Uuid().v4();
    if (_selectedDate!.isAfter(today) ||
        _selectedDate!.day == today.day &&
            reasoncontroller.text.isNotEmpty &&
            agecontroller.text.isNotEmpty &&
            descriptioncontroller.text.isNotEmpty) {
      try {
        FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentid)
            .set({
          'reason': reasoncontroller.text,
          'doctorid': widget.uid,
          'patientid': FirebaseAuth.instance.currentUser!.uid,
          'approved': false,
          'timeslot': dropdownvalue,
          'date': _selectedDate,
          'doctorsname': widget.name,
          'appointmentid': appointmentid,
          'patientname': namecontroller.text,
          'patientage': agecontroller.text,
          'description': descriptioncontroller.text,
          'doctorimageurl': widget.url,
          'type': widget.type,
          'rating': widget.rating,
          'gender': selectedCategory,
          'status': "null",
          'code': 'a',
          'note': "",
          'prescribed': 'null',
        });
        if (mounted) {
          setState(() {
            selectedCategory = 'Male';
            dropdownvalue = '8.00 AM - 9.00 AM';
            _selectedDate = DateTime.now();
          });
        }
        Navigator.pop(context);
        Navigator.pop(context);
        reasoncontroller.clear();
        Provider.of<AppointmentsProvider>(context, listen: false)
            .fetchAppointmentsPatients();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('request sent successfully')));
      } catch (e) {
        print(e);
      }
    } else if (reasoncontroller.text.isEmpty ||
        namecontroller.text.isEmpty ||
        agecontroller.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('please fill all the fields')));
    } else if (!_selectedDate!.isAfter(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Date must be selected of future')));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        color: const Color.fromARGB(136, 79, 34, 153),
        shadowColor: const Color.fromARGB(24, 99, 69, 155),
        elevation: 15,
        child: ListTile(
          onTap: () {
            print(_selectedDate);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DialogContainer(
                          onPressed: () {
                            appointmentRequest();
                          },
                          screenwidth: screenwidth,
                          uid: userid,
                          rating: widget.rating,
                          url: widget.url,
                          name: widget.name,
                          type: widget.type,
                          availablity: widget.availablity,
                        )));
          },
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Colors.white,
              ),
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                  widget.url,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.type,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          subtitle: Text(
            widget.availablity,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          trailing: SizedBox(
            width: 60,
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 30,
                  color: Colors.amber,
                ),
                Text(
                  widget.rating.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 14),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DialogContainer extends StatefulWidget {
  final double screenwidth;
  final String uid;
  final double rating;
  final String url;
  final String name;
  final String type;
  final String availablity;
  final void Function()? onPressed;

  const DialogContainer(
      {super.key,
      required this.screenwidth,
      required this.uid,
      required this.rating,
      required this.url,
      required this.name,
      required this.type,
      required this.availablity,
      required this.onPressed});

  @override
  State<DialogContainer> createState() => _DialogContainerState();
}

class _DialogContainerState extends State<DialogContainer> {
  @override
  void dispose() {
    namecontroller.clear();
    agecontroller.clear();
    descriptioncontroller.clear();
    reasoncontroller.clear();

    // TODO: implement dispose
    super.dispose();
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
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Book Your Appointment",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(widget.url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.type,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingBar.readOnly(
                          isHalfAllowed: true,
                          halfFilledIcon: Icons.star_half,
                          filledColor: Colors.amber,
                          size: 25,
                          filledIcon: Icons.star,
                          emptyIcon: Icons.star_border,
                          initialRating: widget.rating,
                          maxRating: 5,
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.availablity,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Text(
                  "Enter Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                AppointmentTextfield(
                    keyboardType: TextInputType.name,
                    controller: namecontroller,
                    hinttext: "Full Name"),
                SizedBox(height: 15),
                AppointmentTextfield(
                    keyboardType: TextInputType.number,
                    controller: agecontroller,
                    hinttext: "Age"),
                SizedBox(height: 15),
                AppointmentTextfield(
                    keyboardType: TextInputType.name,
                    controller: reasoncontroller,
                    hinttext: "Purpose of your visit"),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1, color: Colors.grey)),
                        child: DropdownButton(
                          underline:
                              DropdownButtonHideUnderline(child: SizedBox()),
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(15),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                          value: selectedCategory,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: gender.map((String gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue!;
                              print(selectedCategory);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1, color: Colors.grey)),
                        child: DropdownButton(
                          underline:
                              DropdownButtonHideUnderline(child: SizedBox()),
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(15),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                          value: dropdownvalue,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: items.map((String values) {
                            return DropdownMenuItem(
                              value: values,
                              child: Text(values),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownvalue = newValue!;
                              print(selectedCategory);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
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
                        Icon(Icons.calendar_today, color: Colors.black),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: descriptioncontroller,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Describe Your Condition",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: widget.onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Book Now",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

