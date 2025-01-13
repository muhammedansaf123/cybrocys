import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/user/userdata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
//import 'package:intl/intl.dart';

class SurgeryAdmit extends StatefulWidget {
  const SurgeryAdmit({super.key});

  @override
  State<SurgeryAdmit> createState() => _SurgeryAdmitState();
}

class _SurgeryAdmitState extends State<SurgeryAdmit> {
  final TextEditingController _searchControllersurgery =
      TextEditingController();
  final TextEditingController _searchControlleradmits = TextEditingController();
  List<Map<String, dynamic>> _filteredsurgeries = [];
  List<Map<String, dynamic>> _allsurgeries = [];
  List<Map<String, dynamic>> _filteredadmits = [];
  List<Map<String, dynamic>> _alladmites = [];

  String currentfilter = 'None';
  DateTime? selectedDate = DateTime.now();
  bool isFiltersurgeries = false;
  bool isFilteradmits = false;
  DateTime? filterdate = DateTime.now();
  String status = '';

  void _filtersurgeries() {
    isFiltersurgeries = true;
    final searchText = _searchControllersurgery.text.toLowerCase();
    setState(() {
      _filteredsurgeries = _allsurgeries.where((record) {
        return record.values.any((value) {
          final stringValue = value.toString().toLowerCase();
          return stringValue.contains(searchText);
        });
      }).toList();
    });
  }

  void _filteradmits() {
    isFiltersurgeries = true;
    final searchText = _searchControlleradmits.text.toLowerCase();
    setState(() {
      _filteredadmits = _alladmites.where((record) {
        return record.values.any((value) {
          final stringValue = value.toString().toLowerCase();
          return stringValue.contains(searchText);
        });
      }).toList();
    });
  }

  void clearfiltersurgeries() {
    setState(() {
      _filteredsurgeries = _filteredadmits;
    });
  }

  void clearfilteradmits() {
    setState(() {
      _filteredadmits = _filteredsurgeries;
    });
  }

  void consultationfiltersurgery(String date) {
    setState(() {
      isFiltersurgeries = true;
      _filteredsurgeries = _allsurgeries.where((record) {
        return record.values.any((value) {
          final stringValue = value.toString().toLowerCase();
          return stringValue.contains(date);
        });
      }).toList();
      print(_filteredsurgeries);
    });
  }

  void consultationfilteradmit(String date) {
    setState(() {
      isFilteradmits = true;
      _filteredadmits = _alladmites.where((record) {
        return record.values.any((value) {
          final stringValue = value.toString().toLowerCase();
          return stringValue.contains(date);
        });
      }).toList();
      print(_filteredsurgeries);
    });
  }

  void statusFiltersurgeries(String status) {
    print(status);
    setState(() {
      isFiltersurgeries = true;
      _filteredsurgeries = _allsurgeries.where((record) {
        return record.values.any((value) {
          final stringValue = value.toString().toLowerCase();
          return stringValue.contains(status);
        });
      }).toList();
      print(_filteredadmits);
    });
  }

  void statusFilteradmits(String status) {
    print(status);
    setState(() {
      isFilteradmits = true;
      _filteredadmits = _alladmites.where((record) {
        return record.values.any((value) {
          final stringValue = value.toString().toLowerCase();
          return stringValue.contains(status);
        });
      }).toList();
      print(_filteredadmits);
    });
  }

  void consultationquery() {}

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userdata =
        Userdata(uid: FirebaseAuth.instance.currentUser!.uid).getData();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              
              IconButton(
                  onPressed: () {
                     final tabIndex = DefaultTabController.of(context)?.index ?? 0;
                    showModalBottomSheet<void>(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return Wrap(
                            children: [
                              Container(color:tabIndex==0? Colors.red:Colors.blue,height: 500,)
                            ],
                          );
                        });
                      },
                    );
                  },
                  icon: Icon(Icons.tune))
            ],
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.deepPurple,
            title: Text(
              "Surgeries & Admit",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(child: Text("Surgeries")),
                  Tab(child: Text("Admit"))
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 60,
                            child: TextField(
                              onChanged: (value) {
                                _filtersurgeries();
                              },
                              controller: _searchControllersurgery,
                              decoration: InputDecoration(
                                suffixIcon: Icon(Icons.search),
                                hintText: "Search...",
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple, width: 2)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple, width: 3)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 500,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('surgeries')
                                .where('doctorid',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid)
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Error fetching data'));
                              }

                              if (snapshot.hasData) {
                                _allsurgeries = snapshot.data!.docs
                                    .map<Map<String, dynamic>>((doc) =>
                                        doc.data() as Map<String, dynamic>)
                                    .toList();
                              }

                              if (_filteredsurgeries.isEmpty &&
                                  isFiltersurgeries == false) {
                                print('second');

                                _filteredsurgeries = _allsurgeries;
                              }
                              if (_filteredsurgeries.isEmpty &&
                                  filterdate != null) {
                                print('third');
                                _filteredsurgeries = _allsurgeries;
                                return const Center(
                                    child: Text('No records found'));
                              }
                              return SizedBox(
                                child: ListView.builder(
                                    itemCount: _filteredsurgeries.length,
                                    itemBuilder: (context, index) {
                                      final surgerydata =
                                          _filteredsurgeries[index];

                                      return Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  4), // Add vertical spacing here
                                          child: Appointmentshowtile(
                                              issurgery: true,
                                              appointmentdata: surgerydata,
                                              userdata: userdata));
                                    }),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 60,
                            child: TextField(
                              onChanged: (value) {
                                _filteradmits();
                              },
                              controller: _searchControlleradmits,
                              decoration: InputDecoration(
                                suffixIcon: Icon(Icons.search),
                                hintText: "Search...",
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple, width: 2)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple, width: 3)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 500,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('admits')
                                .where('doctorid',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid)
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Error fetching data'));
                              }

                              if (snapshot.hasData) {
                                _alladmites = snapshot.data!.docs
                                    .map<Map<String, dynamic>>((doc) =>
                                        doc.data() as Map<String, dynamic>)
                                    .toList();
                              }

                              // if (_filteredadmits.isEmpty &&
                              //     isFilteradmits == false) {
                              //   print('second');

                              //   _filteredadmits = _alladmites;
                              // }
                              if (_filteredadmits.isEmpty &&
                                  filterdate != null) {
                                print('third');
                                _filteredadmits = _alladmites;
                                return const Center(
                                    child: Text('No records found'));
                              }
                              return SizedBox(
                                child: ListView.builder(
                                    itemCount: _filteredadmits.length,
                                    itemBuilder: (context, index) {
                                      final admitdata = _filteredadmits[index];

                                      return Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  4), // Add vertical spacing here
                                          child: Appointmentshowtile(
                                              issurgery: false,
                                              appointmentdata: admitdata,
                                              userdata: userdata));
                                    }),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class Appointmentshowtile extends StatefulWidget {
  final bool issurgery;
  final Map<String, dynamic> appointmentdata;

  final Future<Map<String, dynamic>> userdata;
  const Appointmentshowtile({
    super.key,
    required this.issurgery,
    required this.appointmentdata,
    required this.userdata,
  });

  @override
  State<Appointmentshowtile> createState() => _MedicalRecordTileState();
}

class _MedicalRecordTileState extends State<Appointmentshowtile> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: const Color.fromARGB(136, 79, 34, 163),
        shadowColor: const Color.fromARGB(24, 99, 69, 165),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Condition: ",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.appointmentdata['reason'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  widget.issurgery
                      ? Text(
                          'R.no:${widget.appointmentdata['room']}',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          'Ward:${widget.appointmentdata['ward']}',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Scheduled Date:  ',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.issurgery
                        ? widget.appointmentdata['date']
                        : widget.appointmentdata['admissionDate'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.issurgery
                            ? "Anesthesia type:  "
                            : "Duration Of Stay: ",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.issurgery
                            ? widget.appointmentdata['anesthesiaType']
                            : widget.appointmentdata['durationOfStay'],
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
                      Text(
                        "Note: ",
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.issurgery
                            ? widget.appointmentdata['preSurgeryInstructions']
                            : widget.appointmentdata['specialInstructions'],
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
