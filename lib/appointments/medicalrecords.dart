import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/profile/edit_profile.dart';
import 'package:flutter/material.dart';

class Medicalrecords extends StatefulWidget {
  const Medicalrecords({super.key});

  @override
  _MedicalrecordsState createState() => _MedicalrecordsState();
}

class _MedicalrecordsState extends State<Medicalrecords> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredRecords = [];
  List<Map<String, dynamic>> _allRecords = [];

  @override
  void initState() {
    super.initState();
  }

  void _filterRecords() {
    final searchText = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecords = _allRecords.where((record) {
        return record.values.any((value) {
          final stringValue = value.toString().toLowerCase();
          return stringValue.contains(searchText);
        });
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.download),
            onPressed: _downloadMedicalHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                _filterRecords();
              },
              controller: _searchController,
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.search),
                hintText: "Search...",
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 3)),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('medicalrecords')
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Error fetching data: ${snapshot.error}');
                  return const Center(child: Text('Error fetching data'));
                }

                if (snapshot.hasData) {
                  _allRecords = snapshot.data!.docs
                      .map<Map<String, dynamic>>(
                          (doc) => doc.data() as Map<String, dynamic>)
                      .toList();
                }

                if (_filteredRecords.isEmpty &&
                    _searchController.text.isEmpty) {
                  _filteredRecords = _allRecords;
                }
                if (_filteredRecords.isEmpty) {
                  _filteredRecords = _allRecords;
                  return const Center(child: Text('No records found'));
                }

                return ListView.builder(
                  itemCount: _filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = _filteredRecords[index];

                    final name = record['name'];
                    final lastConsultationDate =
                        record['consultation']['lastConsultationDate'];
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
                            'Consultation: $lastConsultationDate\nReason: ${history}',
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
                                  doctorsName: record['consultation']['doctor']
                                      ['name'],
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("hello world");
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void _downloadMedicalHistory() {}
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
    Key? key,
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
  }) : super(key: key);

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

                          //             ListTile(
                          //   leading:
                          //   title: Column(
                          //     children: [

                          //       Text('Dosage:${presc1['dosage']}')
                          //     ],
                          //   ),
                          //   subtitle: Text(', $presc2'),
                          // ),
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
                          Icon(Icons.content_paste_go_outlined, color: Colors.deepPurple),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Lab Results',
                            style: TextStyle(fontSize: 16),
                          ),

                          //             ListTile(
                          //   leading:
                          //   title: Column(
                          //     children: [

                          //       Text('Dosage:${presc1['dosage']}')
                          //     ],
                          //   ),
                          //   subtitle: Text(', $presc2'),
                          // ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('1.'),
                      Text(
                        'Status:  ${labResults[0]['result']}',
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
                          'Status:  ${labResults[1]['result']}',
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
    );
  }
}
