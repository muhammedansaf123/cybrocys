import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_managment/appointments/appointmentsbooking.dart';
import 'package:hospital_managment/medical_records/components/detail_widget.dart';
import 'package:hospital_managment/medical_records/medical_records_provider.dart';

import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Medicalrecords extends StatefulWidget {
  const Medicalrecords({super.key});

  @override
  _MedicalrecordsState createState() => _MedicalrecordsState();
}

class _MedicalrecordsState extends State<Medicalrecords> {
  // @override
  // void initState() {
  //   fetchmedicalRecorddata();
  //   // TODO: implement initState
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalRecordsProvider>(
        builder: (context, provider, child) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text(
            'Medical Records',
            style: TextStyle(color: Colors.white),
          ),
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.deepPurple,
          actions: [
            IconButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Wrap(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
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
                                        Container(
                                          padding: EdgeInsets.only(left: 15),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: DropdownButton<String>(
                                            underline:
                                                DropdownButtonHideUnderline(
                                                    child: SizedBox()),
                                            value: provider.currentfilter,
                                            items: <String>[
                                              'None',
                                              'consultation dates',
                                              'status',
                                              'Doctors name'
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                provider.currentfilter = value!;
                                              });
                                            },
                                          ),
                                        ),
                                        Spacer(),
                                        ElevatedButton(
                                            onPressed: () {
                                              setState(() {});
                                              provider.clearQuery();
                                            },
                                            child: Text("Clear Filter"))
                                      ],
                                    ),
                                    if (provider.currentfilter == 'None') ...[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        height: 250,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.grey[200],
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                              'No Filter Category Selected'),
                                        ),
                                      ),
                                    ],
                                    if (provider.currentfilter ==
                                        'consultation dates') ...[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.grey[200],
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: TableCalendar(
                                              selectedDayPredicate: (day) {
                                                if (day ==
                                                    provider.selectedDate) {
                                                  return true;
                                                } else {
                                                  return false;
                                                }
                                              },
                                              onDaySelected: (start, selected) {
                                                provider.selectedDate =
                                                    selected;
                                                setState(() {
                                                  provider.selectedDate =
                                                      selected;
                                                });
                                                provider.filter();
                                              },
                                              calendarFormat:
                                                  CalendarFormat.month,
                                              onFormatChanged: (format) {},
                                              focusedDay:
                                                  provider.selectedDate == null
                                                      ? DateTime.now()
                                                      : provider.selectedDate!,
                                              firstDay: DateTime(2000),
                                              lastDay: DateTime(2100)),
                                        ),
                                      ),
                                    ],
                                    if (provider.currentfilter == 'status') ...[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        height: 250,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.grey[200],
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                            child: Column(
                                          children: [
                                            Card(
                                              color:
                                                  provider.status == 'recovered'
                                                      ? Colors.deepPurple
                                                      : Colors.white,
                                              child: ListTile(
                                                onTap: () {
                                                  setState(() {
                                                    provider.status =
                                                        "recovered";
                                                    provider.filter();
                                                  });
                                                },
                                                title: Text("Recovered",
                                                    style: TextStyle(
                                                      color: provider.status ==
                                                              'recovered'
                                                          ? Colors.white
                                                          : Colors.black,
                                                    )),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Card(
                                              color: provider.status ==
                                                      'under treatment'
                                                  ? Colors.deepPurple
                                                  : Colors.white,
                                              child: ListTile(
                                                onTap: () {
                                                  setState(() {
                                                    provider.status =
                                                        "under treatment";
                                                    provider.filter();
                                                  });
                                                },
                                                title: Text(
                                                  'Under Treatment',
                                                  style: TextStyle(
                                                      color: provider.status ==
                                                              'under treatment'
                                                          ? Colors.white
                                                          : Colors.black),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                      ),
                                    ],
                                    if (provider.currentfilter ==
                                        'Doctors name') ...[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        height: 250,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.grey[200],
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                            child: Column(
                                          children: [
                                            Card(
                                              color: provider.selectedName ==
                                                      'DR. Jane Doe'
                                                  ? Colors.deepPurple
                                                  : Colors.white,
                                              child: ListTile(
                                                onTap: () {
                                                  setState(
                                                    () {
                                                      provider.selectedName =
                                                          "DR. Jane Doe";
                                                      provider.filter();
                                                    },
                                                  );
                                                },
                                                title: Text(
                                                  "DR. Jane Doe",
                                                  style: TextStyle(
                                                    color:
                                                        provider.selectedName ==
                                                                'DR. Jane Doe'
                                                            ? Colors.white
                                                            : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Card(
                                              color: provider.selectedName ==
                                                      'Dr. John'
                                                  ? Colors.deepPurple
                                                  : Colors.white,
                                              child: ListTile(
                                                onTap: () {
                                                  setState(
                                                    () {
                                                      provider.selectedName =
                                                          "Dr. John";
                                                      provider.filter();
                                                    },
                                                  );
                                                },
                                                title: Text(
                                                  'DR. John',
                                                  style: TextStyle(
                                                    color:
                                                        provider.selectedName ==
                                                                'Dr. John'
                                                            ? Colors.white
                                                            : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                    },
                  );
                },
                icon: Icon(Icons.tune))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    provider.filter();
                  },
                  controller: provider.searchController,
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
              if (provider.filteredRecords.isEmpty &&
                  provider.allRecords.isNotEmpty) ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.12,
                ),
                Container(
                  child: Column(
                    children: [
                      Image.asset('assets/nodata1.png'),
                    ],
                  ),
                ),
              ],
              if (provider.filteredRecords.isEmpty &&
                  provider.allRecords.isEmpty) ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
              if (provider.filteredRecords.isNotEmpty &&
                  provider.allRecords.isNotEmpty) ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: ListView.builder(
                    itemCount: provider.filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = provider.filteredRecords[index];

                      final name = record['name'];
                      final lastConsultationDate =
                          record['consultation']['lastConsultationDate'];
                      final nextConsultationDate =
                          record['consultation']['nextConsultationDate'];
                      final history = record['history'].join(", ");

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Card(
                          color: const Color.fromARGB(136, 79, 34, 153),
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                              name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'last Consultation: $lastConsultationDate\nnext Consultation: $nextConsultationDate\nReason: $history',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                    id: record['patientId'],
                                    name: record['name'],
                                    lastConsultationDate: record['consultation']
                                        ['lastConsultationDate'],
                                    history: record['history'].join(", "),
                                    age: record['age'],
                                    status: record['status'],
                                    nextConsultationDate: record['consultation']
                                        ['nextConsultationDate'],
                                    doctorsName: record['consultation']
                                        ['doctor']['name'],
                                    specialization: record['consultation']
                                        ['doctor']['specialization'],
                                    presc1: record['consultation']['doctor']
                                        ['prescription'][0],
                                    presc2: record['consultation']['doctor']
                                        ['prescription'][1],
                                    labResults: record['labResults'],
                                    allergies: record['allergies'][0],
                                    contactInfo: record['contactInfo']['phone'],
                                    notes: record['notes'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ]
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.deepPurple,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      );
    });
  }
}

