import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:circular_countdown_timer/countdown_text_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hospital_managment/surgeries_admit/invoice_stopwatch.dart';
import 'package:hospital_managment/surgeries_admit/surgeryandadmit_provider.dart';
import 'package:hospital_managment/user/userdata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
//import 'package:intl/intl.dart';

class SurgeryAdmit extends StatefulWidget {
  const SurgeryAdmit({super.key});

  @override
  State<SurgeryAdmit> createState() => _SurgeryAdmitState();
}

class _SurgeryAdmitState extends State<SurgeryAdmit>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    Provider.of<SurgeryandadmitProvider>(context, listen: false)
        .initialisation(this);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurgeryandadmitProvider>(
        builder: (context, provider, child) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () {
                      WidgetsBinding.instance.focusManager.primaryFocus
                          ?.unfocus();
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
                                              padding:
                                                  EdgeInsets.only(left: 15),
                                              width: 150,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: DropdownButton<String>(
                                                underline:
                                                    DropdownButtonHideUnderline(
                                                        child: SizedBox()),
                                                value: provider.currentfilter,
                                                items: <String>[
                                                  'Date',
                                                  'Status',
                                                ].map((String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    provider.currentfilter =
                                                        value!;
                                                    print(
                                                        provider.currentfilter);
                                                  });
                                                },
                                              ),
                                            ),
                                            Spacer(),
                                            ElevatedButton(
                                                onPressed: () {
                                                  if (provider.tabController
                                                          .index ==
                                                      0) {
                                                    provider
                                                        .clearQuerySuergey();
                                                  } else {
                                                    provider.clearQueryAdmits();
                                                  }
                                                },
                                                child: Text("Clear Filter"))
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        if (provider.currentfilter ==
                                            'Status') ...[
                                          Container(
                                            height: 200,
                                            child: Column(
                                              children: [
                                                Card(
                                                  child: ListTile(
                                                    onTap: () {
                                                      if (provider.tabController
                                                              .index ==
                                                          0) {
                                                        provider.surgeryStatus =
                                                            'success';
                                                        provider
                                                            .filtersurgery();
                                                      } else {
                                                        provider.admitStatus =
                                                            'success';
                                                        provider.filteradmits();
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
                                                      if (provider.tabController
                                                              .index ==
                                                          0) {
                                                        provider.surgeryStatus =
                                                            'pending';
                                                        provider
                                                            .filtersurgery();
                                                      } else {
                                                        provider.admitStatus =
                                                            'pending';
                                                        provider.filteradmits();
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
                                        if (provider.currentfilter ==
                                            'Date') ...[
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.grey[200],
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(
                                              child: provider.tabController
                                                          .index ==
                                                      0
                                                  ? TableCalendar(
                                                      selectedDayPredicate:
                                                          (day) {
                                                        if (day ==
                                                            provider
                                                                .datesurgery) {
                                                          return true;
                                                        } else {
                                                          return false;
                                                        }
                                                      },
                                                      onDaySelected:
                                                          (start, selected) {
                                                        provider.selectedDatesurgery =
                                                            DateFormat(
                                                                    "dd-MM-yyyy")
                                                                .format(
                                                                    selected);

                                                        setState(() {
                                                          provider.datesurgery =
                                                              selected;
                                                          provider.selectedDatesurgery =
                                                              DateFormat(
                                                                      "dd-MM-yyyy")
                                                                  .format(
                                                                      selected);
                                                        });
                                                        provider
                                                            .filtersurgery();
                                                        //print('selected:$selected');
                                                      },
                                                      calendarFormat:
                                                          CalendarFormat.month,
                                                      focusedDay: provider
                                                              .datesurgery ??
                                                          DateTime.now(),
                                                      firstDay: DateTime(2000),
                                                      lastDay: DateTime(2100))
                                                  : TableCalendar(
                                                      selectedDayPredicate:
                                                          (day) {
                                                        if (day ==
                                                            provider
                                                                .dateadmit) {
                                                          return true;
                                                        } else {
                                                          return false;
                                                        }
                                                      },
                                                      onDaySelected:
                                                          (start, selected) {
                                                        provider.selectedDateadmit =
                                                            DateFormat(
                                                                    "dd-MM-yyyy")
                                                                .format(
                                                                    selected);
                                                        setState(() {
                                                          provider.dateadmit =
                                                              selected;
                                                          provider.selectedDateadmit =
                                                              DateFormat(
                                                                      "dd-MM-yyyy")
                                                                  .format(
                                                                      selected);
                                                          provider
                                                              .filteradmits();
                                                        });

                                                        //print('selected:$selected');
                                                      },
                                                      calendarFormat:
                                                          CalendarFormat.month,
                                                      focusedDay:
                                                          provider.dateadmit ??
                                                              DateTime.now(),
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
                  controller: provider.tabController,
                  tabs: [
                    Tab(child: Text("Surgeries")),
                    Tab(child: Text("Admit")),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: provider.tabController,
                    children: [
                      // Surgeries tab
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
                                    provider.filtersurgery();
                                  },
                                  controller: provider.searchControllersurgery,
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(Icons.search),
                                    hintText: "Search...",
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: Colors.deepPurple,
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.deepPurple,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (provider.filteredsurgeries.isEmpty &&
                                provider.allsurgeries.isNotEmpty) ...[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    Image.asset('assets/nodata1.png'),
                                  ],
                                ),
                              ),
                            ],
                            if (provider.filteredsurgeries.isEmpty &&
                                provider.allsurgeries.isEmpty) ...[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                              ),
                              Center(
                                child: CircularProgressIndicator(),
                              ),
                            ],
                            if (provider.filteredsurgeries.isNotEmpty &&
                                provider.allsurgeries.isNotEmpty) ...[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.75,
                                child: ListView.builder(
                                  itemCount: provider.filteredsurgeries.length,
                                  itemBuilder: (context, index) {
                                    final surgerydata =
                                        provider.filteredsurgeries[index];
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4),
                                      child: SurgerAdmitTile(
                                        index: index,
                                        time: 0,
                                        trigger: () {},
                                        issurgery: true,
                                        surgeryadmitdata: surgerydata,
                                        userdata: provider.userdata,
                                        child: SizedBox(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Admits tab
                      SingleChildScrollView(
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 60,
                              child: TextField(
                                onChanged: (value) {
                                  provider.filteradmits();
                                },
                                controller: provider.searchControlleradmits,
                                decoration: InputDecoration(
                                  suffixIcon: Icon(Icons.search),
                                  hintText: "Search...",
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurple,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (provider.filteredadmits.isEmpty &&
                              provider.alladmites.isNotEmpty) ...[
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
                          if (provider.filteredadmits.isEmpty &&
                              provider.alladmites.isEmpty) ...[
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                            ),
                            Center(
                              child: CircularProgressIndicator(),
                            ),
                          ],
                          if (provider.filteredadmits.isNotEmpty &&
                              provider.alladmites.isNotEmpty) ...[
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.73,
                                child: ListView.builder(
                                  itemCount: provider.filteredadmits.length,
                                  itemBuilder: (context, index) {
                                    final admitdata =
                                        provider.filteredadmits[index];
                                    final int durationInSeconds =
                                        admitdata['durationinseconds'];

                                    // Parse start time and stopped time
                                    final Timestamp startTimeTimestamp =
                                        admitdata['starttime'];
                                    final DateTime startTime =
                                        startTimeTimestamp.toDate();

                                    final Timestamp? stoppedTimeTimestamp =
                                        admitdata['stoppedtime'];
                                    final DateTime? stoppedTime =
                                        stoppedTimeTimestamp?.toDate();

                                    // Calculate initial offset
                                    final int elapsedTimeSinceStart =
                                        DateTime.now()
                                            .difference(startTime)
                                            .inSeconds;

                                    int initialDuration;

                                    initialDuration = elapsedTimeSinceStart >
                                            durationInSeconds
                                        ? durationInSeconds
                                        : elapsedTimeSinceStart;

                                    // Timer widget
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4),
                                      child: SurgerAdmitTile(
                                        index: index,
                                        time: provider.currentseconds == null
                                            ? 0
                                            : provider.currentseconds!,
                                        trigger: () {},
                                        issurgery: false,
                                        surgeryadmitdata: admitdata,
                                        userdata: provider.userdata,
                                        child: Row(
                                          children: [
                                            CircularCountDownTimer(
                                              duration: durationInSeconds,
                                              initialDuration: admitdata[
                                                      'ispaused']
                                                  ? admitdata['pausedseconds']
                                                  : initialDuration,
                                              controller:
                                                  provider.controllers[index],
                                              width: 100,
                                              height: 100,
                                              ringColor: Colors.grey[300]!,
                                              fillColor:
                                                  Colors.purpleAccent[100]!,
                                              backgroundColor:
                                                  Colors.deepPurple[500],
                                              strokeWidth: 4.0,
                                              strokeCap: StrokeCap.round,
                                              textStyle: const TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textFormat:
                                                  CountdownTextFormat.HH_MM_SS,
                                              isReverse: false,
                                              isTimerTextShown: true,
                                              autoStart: true,
                                              onStart: () {
                                                debugPrint(
                                                    'Countdown Started: ${admitdata['isstarted']}');
                                              },
                                              onComplete: () {
                                                FirebaseFirestore.instance
                                                    .collection("admits")
                                                    .doc(admitdata['id'])
                                                    .update({
                                                  'isstarted': false,
                                                  'status': "Completed",
                                                });
                                                debugPrint('Countdown Ended');
                                              },
                                              onChange: (String timeStamp) {
                                                if (admitdata['ispaused'] ==
                                                    true) {
                                                  provider.controllers[index]
                                                      .pause();
                                                }
                                                if (admitdata['ispaused'] ==
                                                    false) {
                                                  provider.controllers[index]
                                                      .resume();

                                               
                                                }
                                              },
                                            ),
                                            // Pause or Resume Timer
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ))
                          ],
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      );
    });
  }
}

class SurgerAdmitTile extends StatefulWidget {
  final bool issurgery;
  final int time;
  final Map<String, dynamic> surgeryadmitdata;
  final void Function()? trigger;
  final Map userdata;
  final int index;
  final Widget child;
  const SurgerAdmitTile({
    super.key,
    required this.index,
    required this.time,
    required this.trigger,
    required this.issurgery,
    required this.surgeryadmitdata,
    required this.child,
    required this.userdata,
  });

  @override
  State<SurgerAdmitTile> createState() => _MedicalRecordTileState();
}

bool isloading = false;

class _MedicalRecordTileState extends State<SurgerAdmitTile> {
  @override
  Widget build(BuildContext context) {
    DateTime admissionDate = !widget.issurgery
        ? (widget.surgeryadmitdata['admissionDate'] as Timestamp).toDate()
        : DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(admissionDate);
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
                              fulldata: widget.surgeryadmitdata,
                              duration: 0,
                              startingtime: widget.time,
                              patientname:
                                  widget.surgeryadmitdata['patientsname'],
                              id: widget.surgeryadmitdata['id'],
                              surgerytype:
                                  widget.surgeryadmitdata['typeofsurgery'],
                              type: 'Surgery',
                            )));
              }
              if (widget.issurgery == false &&
                  widget.userdata['roles'] == 'doctor') {
                Provider.of<SurgeryandadmitProvider>(context, listen: false)
                    .fetchsurgeriesandadmits("admits");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyStopwatch(
                              fulldata: widget.surgeryadmitdata,
                              duration:
                                  widget.surgeryadmitdata['durationinseconds'],
                              startingtime: widget.time,
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
                                : formattedDate,
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
                    if (widget.surgeryadmitdata['status'] == "Completed" ||
                        widget.surgeryadmitdata['status'] == "Pending") ...[
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
                                            horizontal: 5, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: widget.surgeryadmitdata[
                                                      'status'] ==
                                                  'Pending'
                                              ? Colors.orange
                                              : Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                    if (widget.surgeryadmitdata['status'] == "Ongoing") ...[
                      widget.child
                    ]
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
        Icon(icon, color: Colors.blueAccent, size: 20),
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
