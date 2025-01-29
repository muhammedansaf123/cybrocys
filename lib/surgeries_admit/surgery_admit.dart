import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:circular_countdown_timer/countdown_text_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospital_managment/surgeries_admit/components/counter_widget.dart';
import 'package:hospital_managment/surgeries_admit/components/surgery_admit_tile.dart';
import 'package:hospital_managment/surgeries_admit/provider/surgeryandadmit_provider.dart';
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
    with TickerProviderStateMixin {
  @override
  void initState() {
    Provider.of<SurgeryandadmitProvider>(context, listen: false)
        .initialisation(this);

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
                                                  setState(
                                                    () {},
                                                  );
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
                                    provider.allsurgeries.isNotEmpty ||
                                provider.allsurgeries.isEmpty) ...[
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
                                    final durationInSeconds =
                                        surgerydata['durationinseconds'];
                                    int initialDuration =
                                        0; // Default value when starttime is null
                                    if (surgerydata['starttime'] != null) {
                                      // Calculate initial duration only if starttime is not null
                                      final Timestamp startTimeTimestamp =
                                          surgerydata['starttime'];
                                      final DateTime startTime =
                                          startTimeTimestamp.toDate();

                                      final int durationInSeconds =
                                          surgerydata['durationinseconds'];
                                      final int elapsedTimeSinceStart =
                                          DateTime.now()
                                              .difference(startTime)
                                              .inSeconds;

                                      initialDuration = elapsedTimeSinceStart >
                                              durationInSeconds
                                          ? durationInSeconds
                                          : elapsedTimeSinceStart;
                                    }
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4),
                                      child: SurgerAdmitTile(
                                        index: index,
                                        issurgery: true,
                                        surgeryadmitdata: surgerydata,
                                        userdata: provider.userdata,
                                        child: Row(
                                          children: [
                                            CustomCircularCountDownTimer(
                                              data: surgerydata,
                                              index: index,
                                              durationInSeconds:
                                                  durationInSeconds,
                                              initialDuration:
                                                  surgerydata['starttime'] !=
                                                          null
                                                      ? surgerydata['ispaused']
                                                          ? surgerydata[
                                                              'pausedseconds']
                                                          : initialDuration
                                                      : 0,
                                              controller: provider
                                                  .surgeycontrollers[index],
                                              onComplete: () {
                                                final seconds = provider
                                                    .convertTimeToSeconds(
                                                        provider
                                                            .surgeycontrollers[
                                                                index]
                                                            .getTime()!);
                                                if (seconds ==
                                                    surgerydata[
                                                        'durationinseconds']) {
                                                  FirebaseFirestore.instance
                                                      .collection("surgeries")
                                                      .doc(surgerydata['id'])
                                                      .update({
                                                    'isstarted': false,
                                                    'status': "Completed",
                                                    'finishedseconds': seconds
                                                  });
                                                }
                                                provider
                                                    .fetchsurgeriesandadmits(
                                                        "surgeries");
                                                debugPrint('Countdown Ended');
                                              },
                                              onChange: (String timeStamp) {
                                                if (surgerydata['ispaused'] ==
                                                        true &&
                                                    !provider
                                                        .surgeycontrollers[index]
                                                        .isPaused
                                                        .value) {
                                                  provider
                                                      .fetchsurgeriesandadmits(
                                                          "surgeries");
                                                  provider
                                                      .surgeycontrollers[index]
                                                      .pause();
                                                }
                                                if (surgerydata['ispaused'] ==
                                                    false) {
                                                  provider
                                                      .surgeycontrollers[index]
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
                                  provider.alladmites.isNotEmpty ||
                              provider.alladmites.isEmpty) ...[
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
                                    int initialDuration =
                                        0; // Default value when starttime is null
                                    if (admitdata['starttime'] != null) {
                                      // Calculate initial duration only if starttime is not null
                                      final Timestamp startTimeTimestamp =
                                          admitdata['starttime'];
                                      final DateTime startTime =
                                          startTimeTimestamp.toDate();

                                      final int durationInSeconds =
                                          admitdata['durationinseconds'];
                                      final int elapsedTimeSinceStart =
                                          DateTime.now()
                                              .difference(startTime)
                                              .inSeconds;

                                      initialDuration = elapsedTimeSinceStart >
                                              durationInSeconds
                                          ? durationInSeconds
                                          : elapsedTimeSinceStart;
                                    }
                                    // Timer widget
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4),
                                      child: SurgerAdmitTile(
                                        index: index,
                                        issurgery: false,
                                        surgeryadmitdata: admitdata,
                                        userdata: provider.userdata,
                                        child: Row(
                                          children: [
                                            CustomCircularCountDownTimer(
                                              data: admitdata,
                                              index: index,
                                              durationInSeconds:
                                                  durationInSeconds,
                                              initialDuration:
                                                  admitdata['starttime'] != null
                                                      ? admitdata['ispaused']
                                                          ? admitdata[
                                                              'pausedseconds']
                                                          : initialDuration
                                                      : 0,
                                              controller: provider
                                                  .admitcontrollers[index],
                                              onComplete: () {
                                                final seconds = provider
                                                    .convertTimeToSeconds(
                                                        provider
                                                            .admitcontrollers[
                                                                index]
                                                            .getTime()!);
                                                if (seconds ==
                                                    admitdata[
                                                        'durationinseconds']) {
                                                  FirebaseFirestore.instance
                                                      .collection("admits")
                                                      .doc(admitdata['id'])
                                                      .update({
                                                    'isstarted': false,
                                                    'status': "Completed",
                                                    'finishedseconds': seconds
                                                  });
                                                }
                                                provider
                                                    .fetchsurgeriesandadmits(
                                                        "admits");
                                                debugPrint('Countdown Ended');
                                              },
                                              onChange: (String timeStamp) {
                                                if (admitdata['ispaused'] ==
                                                        true &&
                                                    !provider
                                                        .admitcontrollers[index]
                                                        .isPaused
                                                        .value) {
                                                  provider
                                                      .fetchsurgeriesandadmits(
                                                          "admits");
                                                  provider
                                                      .admitcontrollers[index]
                                                      .pause();
                                                }
                                                if (admitdata['ispaused'] ==
                                                    false) {
                                                  provider
                                                      .admitcontrollers[index]
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
