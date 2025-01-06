import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/profile/edit_profile.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MedicalRecords extends StatefulWidget {
  final Map<String, dynamic> data;
  const MedicalRecords({super.key, required this.data});

  @override
  State<MedicalRecords> createState() => _MedicalRecordsState();
}

class _MedicalRecordsState extends State<MedicalRecords> {
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 300));
  String currentfilter = 'None';
  String? selectedname;
  Query? query;
  TextEditingController searchController = TextEditingController();

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        startDate = args.value.startDate;

        endDate = args.value.endDate ?? args.value.startDate;
        fetcclearquery(startDate, endDate);
        print('${startDate}-${endDate}');
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  @override
  void initState() {
    if (widget.data['roles'] == 'patient') {
      clearQuery();
    } else {
      doctorQuery();
    }
    super.initState();
  }

  void fetcclearquery(DateTime start, DateTime end) {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .where('patientid',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    });
  }

  void clearQuery() {
    setState(() {
      query = FirebaseFirestore.instance.collection('appointments').where(
          'patientid',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    });
  }

  void doctorQuery() {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    });
  }

  void searchQuery() {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('appointments')
          .where('patientid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('doctorsname', isNotEqualTo: searchController.text)
          .orderBy("doctorsname")
          .startAt([
        searchController.text,
      ]).endAt([
        searchController.text + '\uf8ff',
      ]);
    });
  }

  void fectcQuery(String name) {
    setState(() {
      query = FirebaseFirestore.instance
          .collection('appointments')
          .where('patientid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('doctorsname', isEqualTo: selectedname);
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime startOfDay =
        DateTime(startDate.year, startDate.month, startDate.day);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return SizedBox(
                        height: 500,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Filter By",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Select a filtering method",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    DropdownButton<String>(
                                      value: currentfilter,
                                      items: <String>[
                                        'None',
                                        'Doctors name',
                                        'Date range',
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          currentfilter = value!;
                                          print(currentfilter);
                                        });
                                      },
                                    ),
                                    Spacer(),
                                    ElevatedButton(
                                        onPressed: () {
                                          clearQuery();
                                        },
                                        child: Text("Clear Filter"))
                                  ],
                                ),
                                if (currentfilter == 'None') ...[
                                  Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[200],
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child:
                                          Text('No Filter Category Selected'),
                                    ),
                                  ),
                                ],
                                if (currentfilter == 'Date range') ...[
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[200],
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: SfDateRangePicker(
                                      onSelectionChanged: _onSelectionChanged,
                                      selectionMode:
                                          DateRangePickerSelectionMode.range,
                                      initialSelectedRange: PickerDateRange(
                                        DateTime.now()
                                            .subtract(const Duration(days: 1)),
                                        DateTime.now()
                                            .add(const Duration(days: 1)),
                                      ),
                                    ),
                                  ),
                                ],
                                if (currentfilter == 'Doctors name') ...[
                                  Container(
                                    height: 300,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[200],
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('doctors')
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        if (snapshot.hasError) {
                                          // ignore: avoid_print
                                          print(
                                              'Error fetching data: ${snapshot.error}');
                                          return const Center(
                                              child:
                                                  Text('Error fetching data'));
                                        }

                                        if (snapshot.hasData &&
                                            snapshot.data!.docs.isEmpty) {
                                          return const Center(
                                              child: Text('No Doctors  found'));
                                        }
                                        return ListView.builder(
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: (context, index) {
                                              final doctorsdata =
                                                  snapshot.data!.docs[index];
                                              final name = doctorsdata['name'];
                                              // final uid = doctorsdata['uid'];
                                              // final type = doctorsdata['type'];
                                              // final url =
                                              //     doctorsdata['imageurl'];
                                              // final available =
                                              //     doctorsdata['available'];
                                              // final rating =
                                              doctorsdata['rating'];

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: Material(
                                                  elevation: 4,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: Card(
                                                    color: const Color.fromARGB(
                                                        136, 79, 34, 153),
                                                    shadowColor:
                                                        const Color.fromARGB(
                                                            24, 99, 69, 155),
                                                    elevation: 15,
                                                    child: ListTile(
                                                        onTap: () {
                                                          print(selectedname);
                                                          setState(() {
                                                            selectedname = name;
                                                            fectcQuery(
                                                                selectedname!);
                                                          });
                                                        },
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 12),
                                                        leading: Text(
                                                          name,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        trailing: CircleAvatar(
                                                          radius: 10,
                                                          child: CircleAvatar(
                                                              radius: 8,
                                                              backgroundColor:
                                                                  selectedname ==
                                                                          name
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .black),
                                                        )),
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  },
                );
              },
              icon: Icon(Icons.filter_list))
        ],
        title: Text(
          'Medical Records',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        child: Column(
          children: [
            if (widget.data!['roles'] == 'patient') ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    print(searchController.text);
                    searchQuery();
                  },
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    hintText: "Search...",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide:
                            BorderSide(color: Colors.deepPurple, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.deepPurple, width: 3)),
                  ),
                ),
              ),
            ],
            Container(
              height: 600,
              child: StreamBuilder(
                stream: query!.snapshots(),
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
                    return const Center(
                        child: Text('No Appointments found found'));
                  }
                  return SizedBox(
                    child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final appointmentdata = snapshot.data!.docs[index];
                          // final patientid = appointmentdata['patientid'];
                          // final doctorsid = appointmentdata['doctorid'];
                          final date = appointmentdata['date'];
                          final timeslot = appointmentdata['timeslot'];
                          final reason = appointmentdata['reason'];
                          final doctorsname = appointmentdata['doctorsname'];
                          final appointmentid =
                              appointmentdata['appointmentid'];
                          final approved = appointmentdata['approved'];
                          final age = appointmentdata['patientage'];
                          final type = appointmentdata['type'];
                          final description = appointmentdata['description'];
                          final imageurl = appointmentdata['doctorimageurl'];
                          final rating = appointmentdata['rating'];
                          final gender = appointmentdata['gender'];
                          final patientname = appointmentdata['patientname'];
                          return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4), // Add vertical spacing here
                              child: MedicalRecordTile(
                                patientname: patientname,
                                userdata: widget.data,
                                age: age,
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
                                date: date.toDate(),
                                time: timeslot,
                                doctorsname: doctorsname,
                              ));
                        }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalRecordTile extends StatefulWidget {
  final String reason;
  final String doctorsname;
  final DateTime date;
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
  final Map userdata;
  final String patientname;
  const MedicalRecordTile(
      {super.key,
      required this.userdata,
      required this.age,
      required this.patientname,
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
              date: widget.date,
              age: widget.age,
              gender: widget.age,
              description: widget.description,
              rating: widget.rating,
              url: widget.url,
              name: widget.userdata['roles'] == 'patient'
                  ? widget.doctorsname
                  : widget.patientname,
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
                      widget.userdata['roles'] == 'patient'
                          ? widget.doctorsname
                          : widget.patientname,
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
                              DateFormat("dd/MM/yyyy").format(widget.date),
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
                widget.userdata['roles'] == 'patient'
                    ? widget.isapproved
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: IconButton(
                                tooltip: "Accept",
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: IconButton(
                                tooltip: "Reject",
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
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
  final DateTime date;
  final void Function()? onPressed;
  final bool approved;

  const DialogContainerMedical({
    super.key,
    required this.age,
    required this.date,
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
                value: DateFormat('dd-MM-yyyy').format(widget.date)),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Describe Condition",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                )
              ],
            ),
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
