import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_managment/appointments/appointmentsbooking.dart';
import 'package:hospital_managment/medical_records/medical_records_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

class DetailScreen extends StatelessWidget {
  final String id;
  final String name;
  final String lastConsultationDate;
  final String history;
  final String age;
  final String status;
  final String nextConsultationDate;
  final String doctorsName;
  final String specialization;
  final Map<dynamic, dynamic> presc1;
  final Map<dynamic, dynamic> presc2;
  final List<dynamic> labResults;
  final String allergies;
  final String contactInfo;
  final String notes;

  const DetailScreen({
    super.key,
    required this.id,
    required this.name,
    required this.lastConsultationDate,
    required this.history,
    required this.age,
    required this.status,
    required this.nextConsultationDate,
    required this.doctorsName,
    required this.specialization,
    required this.presc1,
    required this.presc2,
    required this.labResults,
    required this.allergies,
    required this.contactInfo,
    required this.notes,
  });

  Future<void> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Patient Details',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Text('ID: $id',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('Name: $name', style: pw.TextStyle(fontSize: 14)),
            pw.Text('Age: $age', style: pw.TextStyle(fontSize: 14)),
            pw.Text('_Status: $status', style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text('Last Consultation: $lastConsultationDate',
                style: pw.TextStyle(fontSize: 14)),
            pw.Text('Next Consultation: $nextConsultationDate',
                style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text('Doctor: $doctorsName', style: pw.TextStyle(fontSize: 14)),
            pw.Text('Specialization: $specialization',
                style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.Text('History:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text(history, style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text('Allergies:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text(allergies, style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text('Contact Info:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text(contactInfo, style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text('Notes:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text(notes, style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Prescriptions',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Bullet(
              text:
                  'Medicine: ${presc1['medicine']}\nFrequency: ${presc1['frequency']}\nDosage: ${presc1['dosage']}',
            ),
            pw.Bullet(
              text:
                  'Medicine: ${presc2['medicine']}\nFrequency: ${presc2['frequency']}\nDosage: ${presc2['dosage']}',
            ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Lab Results',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            for (var result in labResults)
              pw.Container(
                padding: pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(
                  '${result['test']} - ${result['result']} on ${result['date']}',
                  style: pw.TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'my-document.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.perm_identity, color: Colors.deepPurple),
                title: Text('ID: $id',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Name: $name'),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.cake, color: Colors.deepPurple),
                title: Text('Age: $age'),
                subtitle: Text('Status: $status'),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
                title: Text('Last Consultation: $lastConsultationDate'),
                subtitle: Text('Next Consultation: $nextConsultationDate'),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.medical_services, color: Colors.deepPurple),
                title: Text('Doctor\'s Name: $doctorsName'),
                subtitle: Text('Specialization: $specialization'),
              ),
            ),
            Divider(color: Colors.grey),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Medical Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(Icons.local_pharmacy, color: Colors.deepPurple),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Prescriptions',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('1.'),
                      Text(
                        'Medicine:  ${presc1['medicine']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Frequenct:  ${presc1['frequency']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Dosage:  ${presc1['dosage']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('2.'),
                      Text(
                        'Medicine:  ${presc2['medicine']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Frequenct:  ${presc2['frequency']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Dosage:  ${presc2['dosage']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(Icons.content_paste_go_outlined,
                              color: Colors.deepPurple),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Lab Results',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('1.'),
                      Text(
                        '_Status:  ${labResults[0]['result']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Test:  ${labResults[0]['test']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'Date:  ${labResults[0]['date']}',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if (labResults.length > 1) ...[
                        Text('2'),
                        Text(
                          '_Status:  ${labResults[1]['result']}',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          'Test:  ${labResults[1]['test']}',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          'Date:  ${labResults[1]['date']}',
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.warning, color: Colors.deepPurple),
                title: Text('Allergies'),
                subtitle: Text(allergies),
              ),
            ),
            Divider(color: Colors.grey),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Additional Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.contact_phone, color: Colors.deepPurple),
                title: Text('Contact Info'),
                subtitle: Text(contactInfo),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.history, color: Colors.deepPurple),
                title: Text('Reason'),
                subtitle: Text(history),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: Icon(Icons.note, color: Colors.deepPurple),
                title: Text('Notes'),
                subtitle: Text(notes),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          generatePdf();
        },
        child: Icon(Icons.download),
      ),
    );
  }
}
