import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/components/components.dart';
import 'package:first_app/profile/edit_profile.dart';
import 'package:first_app/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:uuid/uuid.dart';

class AppointmentsPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const AppointmentsPage({super.key, required this.data});

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
                        vertical: 4), // Add vertical spacing here
                    child: Appointmenttile(
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

class Appointmenttile extends StatefulWidget {
  final String url;
  final String name;
  final double rating;
  final String availablity;
  final String type;
  final String uid;
  const Appointmenttile(
      {super.key,
      required this.availablity,
      required this.name,
      required this.rating,
      required this.type,
      required this.uid,
      required this.url});

  @override
  State<Appointmenttile> createState() => _AppointmenttileState();
}

TextEditingController reasoncontroller = TextEditingController();
TextEditingController namecontroller = TextEditingController();
TextEditingController agecontroller = TextEditingController();
TextEditingController descriptioncontroller = TextEditingController();
String dropdownvalue = '8.00 AM - 9.00 AM';
final sDateFormate = "dd/MM/yyyy";
DateTime selectedDate = DateTime.now();
String date = DateFormat("dd/MM/yyyy").format(DateTime.now());
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

class _AppointmenttileState extends State<Appointmenttile> {
  void appointmentRequest() {
    final appointmentid = Uuid().v4();
    if (reasoncontroller.text.isNotEmpty) {
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
          'date': date,
          'doctorsname': widget.name,
          'appointmentid': appointmentid,
          'patientname': fullname.text,
          'patientage': agecontroller.text,
          'description': descriptioncontroller.text,
          'doctorimageurl': widget.url
        });

        print('successfully updated');
        Navigator.pop(context);
        reasoncontroller.clear();

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('request sent successfully')));
      } catch (e) {
        print(e);
      }
    } else {
      print('reason is empty');
    }
  }

  void showdialog(double screenwidth) {
    setState(() {
      reasoncontroller.clear();
      dropdownvalue = '8.00 AM - 9.00 AM';
      date = DateFormat("dd/MM/yyyy").format(DateTime.now());
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            insetPadding: EdgeInsets.all(15),
            child: DialogContainer(
              onPressed: () {
                appointmentRequest();
              },
              screenwidth: screenwidth,
              uid: uid,
              rating: widget.rating,
              url: widget.url,
              name: widget.name,
              type: widget.type,
              availablity: widget.availablity,
            ));
      },
    );
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
            showdialog(screenwidth);
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
                image: FileImage(File(widget.url)),
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
              const SizedBox(height: 4), // Decreased vertical space here
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
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      height: 600,
      width: widget.screenwidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Book your Appointment",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                Spacer(),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close))
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.white,
                    ),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: FileImage(File(widget.url)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      widget.type,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingBar(
                      isHalfAllowed: true,
                      halfFilledIcon: Icons.star_half,
                      filledColor: Colors.amber,
                      halfFilledColor: Colors.amber,
                      size: 30,
                      filledIcon: Icons.star,
                      emptyIcon: Icons.star_border,
                      initialRating: widget.rating,
                      maxRating: 5,
                      onRatingChanged: (p0) {},
                    ),
                    Text(
                      widget.availablity,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Edittile(
              onTap: () {},
              controller: reasoncontroller,
              title: "Fill in the details below",
              istitle: true,
              autofocus: true,
              hintText: "Enter your full name",
            ),
            Edittile(
              onTap: () {},
              controller: reasoncontroller,
              title: "",
              istitle: false,
              autofocus: true,
              hintText: "Enter your Age",
            ),
            Edittile(
              onTap: () {},
              controller: reasoncontroller,
              title: "Purpose of visit",
              istitle: false,
              autofocus: true,
              hintText: "Purpose of visit",
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 2)),
                    child: DropdownButton(
                      underline: DropdownButtonHideUnderline(child: SizedBox()),
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(15),
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.normal),
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
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 2)),
                    child: DropdownButton(
                      underline: DropdownButtonHideUnderline(child: SizedBox()),
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(15),
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.normal),
                      value: dropdownvalue,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: items.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownvalue = newValue!;
                          print(dropdownvalue);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '(note the doctor is only avialble b/w ${widget.availablity})',
              style:
                  TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 13),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        locale: const Locale('en', 'GB'),
                        context: context,
                        fieldHintText: sDateFormate,
                        initialDate: selectedDate,
                        firstDate: DateTime(1970, 8),
                        lastDate: DateTime(2101),
                      );

                      setState(() {
                        selectedDate = picked!;

                        date = DateFormat(sDateFormate).format(selectedDate);
                        print(date);
                      });
                    },
                    child: Container(
                        height: 55,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 2)),
                        child: Row(
                          children: [
                            Text(date),
                            Spacer(),
                            Icon(Icons.calendar_month)
                          ],
                        )),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              minLines: 2,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: descriptioncontroller,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  hintText: 'describe more about you condition',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(width: 3, color: Colors.black))),
            ),
            Mybutton(load: false, onPressed: widget.onPressed, text: "Book now")
          ],
        ),
      ),
    );
  }
}
