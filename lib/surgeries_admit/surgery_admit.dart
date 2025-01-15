import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hospital_managment/surgeries_admit/invoice_stopwatch.dart';
import 'package:hospital_managment/user/userdata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
//import 'package:intl/intl.dart';

class SurgeryAdmit extends StatefulWidget {
  const SurgeryAdmit({super.key});

  @override
  State<SurgeryAdmit> createState() => _SurgeryAdmitState();
}

class _SurgeryAdmitState extends State<SurgeryAdmit>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchControllersurgery =
      TextEditingController();
  final TextEditingController _searchControlleradmits = TextEditingController();
  List<Map<String, dynamic>> filteredsurgeries = [];
  List<Map<String, dynamic>> allsurgeries = [];
  List<Map<String, dynamic>> filteredadmits = [];
  List<Map<String, dynamic>> alladmites = [];

  String currentfilter = 'Date';
  DateTime? selectedDatesurgery = DateTime.now();
  DateTime? selectedDateadmit = DateTime.now();
  bool isFiltersurgeries = false;
  bool isFilteradmits = false;
  DateTime? filterdate = DateTime.now();
  String status = '';
  Map userdata = {};
  Query? surgeyQuery;
  Query? admitQuery;
  late TabController _tabController;
  void _filtersurgeries() {
    isFiltersurgeries = true;
    final searchText = _searchControllersurgery.text.toLowerCase();
    setState(() {
      filteredsurgeries = allsurgeries.where((record) {
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
      filteredadmits = alladmites.where((record) {
        return record.values.any((value) {
          final stringValue = value.toString().toLowerCase();
          return stringValue.contains(searchText);
        });
      }).toList();
    });
  }

  void clearfiltersurgeries() {
    setState(() {
      filteredsurgeries = filteredadmits;
    });
  }

  void clearfilteradmits() {
    setState(() {
      filteredadmits = filteredsurgeries;
    });
  }

  void consultationfiltersurgery(String date) {
    setState(() {
      isFiltersurgeries = true;
      filteredsurgeries = allsurgeries.where((record) {
        return record.values.any((value) {
          final stringValue = value.toString().toLowerCase();
          return stringValue.contains(date);
        });
      }).toList();
      //print(filteredsurgeries);
    });
  }

  void consultationfilteradmit(String date) {
    setState(() {
      isFilteradmits = true;
      filteredadmits = alladmites.where((record) {
        return record.values.any((value) {
          final stringValue = value.toString().toLowerCase();
          return stringValue.contains(date);
        });
      }).toList();
      //print(filteredsurgeries);
    });
  }

  void statusFiltersurgeries(String status) {
    print(status);
    setState(() {
      isFiltersurgeries = true;
      filteredsurgeries = allsurgeries.where((record) {
        return record.values.any((value) {
          final stringValue = value.toString().toLowerCase();
          return stringValue.contains(status);
        });
      }).toList();
      // print(filteredadmits);
    });
  }

  void statusFilteradmits(String status) {
    print(status);
    setState(() {
      isFilteradmits = true;
      filteredadmits = alladmites.where((record) {
        return record.values.any((value) {
          final stringValue = value.toString().toLowerCase();
          return stringValue.contains(status);
        });
      }).toList();
      // print(filteredadmits);
    });
  }

  @override
  void initState() {
    super.initState();

    fetchuserdata();
    print('fetching data....${userdata['role']}');
    if (userdata['roles'] == 'patient') {
      print('');
      patientquery();
    }
    if (userdata['roles'] == 'doctor') {
      doctorQuery();
    }
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      print('Current Tab Index: ${_tabController.index}');
    });
  }

  void fetchuserdata() async {
    final data =
        await Userdata(uid: FirebaseAuth.instance.currentUser!.uid).getData();
    setState(() {
      userdata = data;

      if (userdata['roles'] == 'patient') {
        surgeyQuery = FirebaseFirestore.instance.collection('surgeries').where(
            'patientid',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid);
        admitQuery = FirebaseFirestore.instance.collection('admits').where(
            'patientid',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid);
      }
      if (userdata['roles'] == 'doctor') {
        surgeyQuery = FirebaseFirestore.instance.collection('surgeries').where(
            'doctorid',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid);
        admitQuery = FirebaseFirestore.instance.collection('admits').where(
            'doctorid',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid);
      }
    });
  }

  void patientquery() {
    setState(() {
      surgeyQuery = FirebaseFirestore.instance.collection('surgeries').where(
          'patientid',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    });
  }

  void doctorQuery() {
    setState(() {
      surgeyQuery = FirebaseFirestore.instance
          .collection('surgeries')
          .where('doctorid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    });
  }

  void clearQuery() {
    print('hello');
    setState(() {
      if (_tabController.index == 0) {
        filteredsurgeries = allsurgeries;
      }
      if (_tabController.index == 1) {
        filteredadmits = alladmites;
      }
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (admitQuery == null || surgeyQuery == null) {
      return Scaffold(
        body: CircularProgressIndicator(),
      );
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(left: 15),
                                            width: 150,
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
                                              value: currentfilter,
                                              items: <String>[
                                                'Date',
                                                'Status',
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
                                          ),
                                          Spacer(),
                                          ElevatedButton(
                                              onPressed: () {
                                                clearQuery();
                                              },
                                              child: Text("Clear Filter"))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      if (currentfilter == 'Status') ...[
                                        Container(
                                          height: 200,
                                          child: Column(
                                            children: [
                                              Card(
                                                child: ListTile(
                                                  onTap: () {
                                                    if (_tabController.index ==
                                                        0) {
                                                      statusFiltersurgeries(
                                                          'success');
                                                    } else {
                                                      statusFilteradmits(
                                                          'success');
                                                    }
                                                  },
                                                  leading: Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green),
                                                  title: Text(
                                                    'Success',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Card(
                                                child: ListTile(
                                                  onTap: () {
                                                    if (_tabController.index ==
                                                        0) {
                                                      statusFiltersurgeries(
                                                          'pending');
                                                    } else {
                                                      statusFilteradmits(
                                                          'pending');
                                                    }
                                                  },
                                                  leading: Icon(Icons.pending,
                                                      color: Colors.orange),
                                                  title: Text(
                                                    'Pending',
                                                    style: TextStyle(
                                                      color: Colors.orange,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                      if (currentfilter == 'Date') ...[
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.grey[200],
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: _tabController.index == 0
                                                ? TableCalendar(
                                                    selectedDayPredicate:
                                                        (day) {
                                                      if (day ==
                                                          selectedDatesurgery) {
                                                        return true;
                                                      } else {
                                                        return false;
                                                      }
                                                    },
                                                    onDaySelected:
                                                        (start, selected) {
                                                      selectedDatesurgery =
                                                          selected;
                                                      setState(() {
                                                        selectedDatesurgery =
                                                            selected;
                                                      });

                                                      consultationfiltersurgery(
                                                          DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(
                                                                  selectedDatesurgery!));

                                                      //print('selected:$selected');
                                                    },
                                                    calendarFormat:
                                                        CalendarFormat.month,
                                                    onFormatChanged:
                                                        (format) {},
                                                    focusedDay:
                                                        selectedDatesurgery!,
                                                    firstDay: DateTime(2000),
                                                    lastDay: DateTime(2100))
                                                : TableCalendar(
                                                    selectedDayPredicate:
                                                        (day) {
                                                      if (day ==
                                                          selectedDateadmit) {
                                                        return true;
                                                      } else {
                                                        return false;
                                                      }
                                                    },
                                                    onDaySelected:
                                                        (start, selected) {
                                                      selectedDateadmit =
                                                          selected;
                                                      setState(() {
                                                        selectedDateadmit =
                                                            selected;
                                                      });

                                                      consultationfilteradmit(
                                                          DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(
                                                                  selectedDateadmit!));

                                                      //print('selected:$selected');
                                                    },
                                                    calendarFormat:
                                                        CalendarFormat.month,
                                                    onFormatChanged:
                                                        (format) {},
                                                    focusedDay:
                                                        selectedDateadmit!,
                                                    firstDay: DateTime(2000),
                                                    lastDay: DateTime(2100)),
                                          ),
                                        ),
                                      ]
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
                controller: _tabController,
                tabs: [
                  Tab(child: Text("Surgeries")),
                  Tab(child: Text("Admit"))
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 60,
                              child: TextField(
                                autofocus: false,
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
                              stream: surgeyQuery!.snapshots(),
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
                                  allsurgeries = snapshot.data!.docs
                                      .map<Map<String, dynamic>>((doc) =>
                                          doc.data() as Map<String, dynamic>)
                                      .toList();
                                }

                                if (filteredsurgeries.isEmpty &&
                                    isFiltersurgeries == false) {
                                  print('second');

                                  filteredsurgeries = allsurgeries;
                                }
                                if (filteredsurgeries.isEmpty &&
                                    filterdate != null) {
                                  print('third');
                                  filteredsurgeries = allsurgeries;
                                  return const Center(
                                      child: Text('No records found'));
                                }
                                return SizedBox(
                                  child: ListView.builder(
                                      itemCount: filteredsurgeries.length,
                                      itemBuilder: (context, index) {
                                        final surgerydata =
                                            filteredsurgeries[index];

                                        return Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical:
                                                    4), // Add vertical spacing here
                                            child: SurgerAdmitTile(
                                                trigger: clearQuery,
                                                issurgery: true,
                                                surgeryadmitdata: surgerydata,
                                                userdata: userdata));
                                      }),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
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
                              stream: admitQuery!.snapshots(),
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
                                  alladmites = snapshot.data!.docs
                                      .map<Map<String, dynamic>>((doc) =>
                                          doc.data() as Map<String, dynamic>)
                                      .toList();
                                }

                                if (filteredadmits.isEmpty &&
                                    isFilteradmits == false) {
                                  print('second');

                                  filteredadmits = alladmites;
                                }
                                if (filteredadmits.isEmpty &&
                                    filterdate != null) {
                                  print('third');
                                  filteredadmits = alladmites;
                                  return const Center(
                                      child: Text('No records found'));
                                }
                                return SizedBox(
                                  child: ListView.builder(
                                      itemCount: filteredadmits.length,
                                      itemBuilder: (context, index) {
                                        final admitdata = filteredadmits[index];

                                        return Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical:
                                                    4), // Add vertical spacing here
                                            child: SurgerAdmitTile(
                                                trigger: clearQuery,
                                                issurgery: false,
                                                surgeryadmitdata: admitdata,
                                                userdata: userdata));
                                      }),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class SurgerAdmitTile extends StatefulWidget {
  final bool issurgery;
  final Map<String, dynamic> surgeryadmitdata;
  final void Function()? trigger;
  final Map userdata;
  const SurgerAdmitTile({
    super.key,
    required this.trigger,
    required this.issurgery,
    required this.surgeryadmitdata,
    required this.userdata,
  });

  @override
  State<SurgerAdmitTile> createState() => _MedicalRecordTileState();
}

bool isloading = false;

class _MedicalRecordTileState extends State<SurgerAdmitTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
          color: Colors.deepPurple,
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          child: GestureDetector(
            onTap: () {
              if (widget.surgeryadmitdata['status'] == 'Pending' &&
                  widget.issurgery == true &&
                  widget.userdata['roles'] == 'doctor') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyStopwatch(
                              patientname:
                                  widget.surgeryadmitdata['patientsname'],
                              id: widget.surgeryadmitdata['id'],
                              surgerytype:
                                  widget.surgeryadmitdata['typeofsurgery'],
                              type: 'Surgery',
                            )));
              }
              if (widget.issurgery == false &&
                  widget.surgeryadmitdata['status'] == 'Pending' &&
                  widget.userdata['roles'] == 'doctor') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyStopwatch(
                              patientname:
                                  widget.surgeryadmitdata['patientsname'],
                              id: widget.surgeryadmitdata['id'],
                              surgerytype: 'Admit',
                              type: 'Admit',
                            )));
              }

              if (widget.userdata['roles'] == 'patient') {
                try {
                  FirebaseFirestore.instance
                      .collection('invoice')
                      .doc('${widget.surgeryadmitdata['id']}')
                      .get()
                      .then((DocumentSnapshot documentSnapshot) {
                    if (documentSnapshot.exists) {
                      final data =
                          documentSnapshot.data() as Map<String, dynamic>;

                      final String role = 'patient';
                      final String id = data['id'];
                      final String type = data['type'];
                      final String payment = widget.surgeryadmitdata['payment'];
                      final String invoiceNumber = data['invoiceNumber'];
                      final String patientName = data['patientName'];
                      final String patientAddress = data['patientAddress'];
                      final String patientPhone = data['patientPhone'];
                      final DateTime invoiceDate =
                          DateTime.parse(data['invoiceDate']);
                      final DateTime dueDate = DateTime.parse(data['dueDate']);
                      final List<Map<String, dynamic>> items =
                          List<Map<String, dynamic>>.from(data['items']);
                      final double subTotal = data['subTotal'];
                      final double taxRate = data['taxRate'];
                      final double taxAmount = data['taxAmount'];
                      final double totalAmount = data['totalAmount'];
                      final String notes = data['notes'];

                      Navigator.push(
                        context,
                        MaterialPageRoute<bool>(
                          builder: (context) => InvoiceWidget(
                            onTriggerFunction: widget.trigger!,
                            role: role,
                            id: id,
                            payment: payment,
                            type: type,
                            invoiceNumber: invoiceNumber,
                            patientName: patientName,
                            patientAddress: patientAddress,
                            patientPhone: patientPhone,
                            invoiceDate: invoiceDate,
                            dueDate: dueDate,
                            items: items,
                            subTotal: subTotal,
                            taxRate: taxRate,
                            taxAmount: taxAmount,
                            totalAmount: totalAmount,
                            notes: notes,
                          ),
                        ),
                      );
                    } else {
                      print("no document exist");
                    }
                  });
                } catch (e) {
                  print(e);
                }
              }
            },
            child: Card(
              color: Colors.white,
              shadowColor: Colors.grey.withOpacity(0.2),
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_hospital,
                                  color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                "Condition: ${widget.surgeryadmitdata['reason']}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DisplayRow(
                            title: widget.userdata['roles'] == 'doctor'
                                ? "Patient"
                                : "Doctor",
                            value: widget.userdata['roles'] == 'doctor'
                                ? widget.surgeryadmitdata['patientsname']
                                : widget.surgeryadmitdata['doctorsname'],
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 8),
                          DisplayRow(
                            title: 'Scheduled Date',
                            value: widget.issurgery
                                ? widget.surgeryadmitdata['date']
                                : widget.surgeryadmitdata['admissionDate'],
                            icon: Icons.date_range,
                          ),
                          const SizedBox(height: 8),
                          DisplayRow(
                            title: 'Note',
                            value: widget.issurgery
                                ? widget
                                    .surgeryadmitdata['preSurgeryInstructions']
                                : widget
                                    .surgeryadmitdata['specialInstructions'],
                            icon: Icons.notes,
                          ),
                        ],
                      ),
                    ),
                    widget.surgeryadmitdata['payment'] == 'notpaid'
                        ? Expanded(
                            flex: 1,
                            child: Container(
                              height: 100,
                              child: Column(
                                children: [
                                  Text(
                                    widget.issurgery
                                        ? 'Room: ${widget.surgeryadmitdata['room']}'
                                        : 'Ward: ${widget.surgeryadmitdata['ward']}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            widget.surgeryadmitdata['status'] ==
                                                    'Pending'
                                                ? Colors.orange
                                                : Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.surgeryadmitdata['status'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer()
                                ],
                              ),
                            ),
                          )
                        : Expanded(
                            child: Column(
                            children: [
                              Container(
                                height: 50,
                                child: Center(
                                  child: Image.asset(
                                    'assets/success.png',
                                    scale: 4,
                                  ),
                                ),
                              ),
                              Text(
                                "Paid",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ))
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

class DisplayRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const DisplayRow({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 20), // Reduced icon size
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$title: ",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
