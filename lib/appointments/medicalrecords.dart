import 'package:flutter/material.dart';

class Medicalrecords extends StatefulWidget {
  const Medicalrecords({super.key});

  @override
  _MedicalrecordsState createState() => _MedicalrecordsState();
}

class _MedicalrecordsState extends State<Medicalrecords> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _records = [
    {
      'status': 'Under Treatment',
      'consultation': 'Consulted on 2023-12-20',
      'history': 'Diabetes, Hypertension',
    },
    {
      'status': 'Recovered',
      'consultation': 'Consulted on 2023-10-15',
      'history': 'Flu, Cold',
    },
  ];
  List<Map<String, String>> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _filteredRecords = _records;
  }

  void _filterRecords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecords = _records
          .where((record) =>
              record.values.any((value) => value.toLowerCase().contains(query)))
          .toList();
    });
  }

  void _downloadMedicalHistory() {}

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
            onPressed: () {
              _downloadMedicalHistory();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _filterRecords();
              },
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
            child: ListView.builder(
              itemCount: _filteredRecords.length,
              itemBuilder: (context, index) {
                final record = _filteredRecords[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(record['status']!),
                    subtitle: Text(
                        'Consultation: ${record['consultation']}\nHistory: ${record['history']}'),
                    onTap: () {},
                  ),
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
}
