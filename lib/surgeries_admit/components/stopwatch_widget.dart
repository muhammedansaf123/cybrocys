import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hospital_managment/surgeries_admit/components/invoice_widget.dart';
import 'package:hospital_managment/surgeries_admit/provider/surgeryandadmit_provider.dart';
import 'package:provider/provider.dart';

class MyStopwatch extends StatefulWidget {
  final String type;
  final int index;
  const MyStopwatch({Key? key, required this.type, required this.index})
      : super(key: key);

  @override
  State<MyStopwatch> createState() => _MyStopwatchState();
}

final CountDownController _controller = CountDownController();

class _MyStopwatchState extends State<MyStopwatch> {
  @override
  void initState() {
    super.initState();
    Provider.of<SurgeryandadmitProvider>(context, listen: false)
        .fetchsurgeriesandadmits(
            widget.type == "Surgery" ? "surgeries" : "admits");
  }

  int timeToSeconds(String time) {
    List<String> parts = time.split(':');
    if (parts.length != 3) {
      throw FormatException('Invalid time format. Expected HH:mm:ss');
    }
    return (int.parse(parts[0]) * 3600) +
        (int.parse(parts[1]) * 60) +
        int.parse(parts[2]);
  }

  void updateFirestore(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) {
    FirebaseFirestore.instance.collection(collection).doc(docId).update(data);
    Provider.of<SurgeryandadmitProvider>(context, listen: false)
        .fetchsurgeriesandadmits(collection);
  }

  void startTimer(Map<String, dynamic> admitData) {
    updateFirestore(
        widget.type == "Surgery" ? "surgeries" : "admits", admitData['id'], {
      'isstarted': true,
      'starttime': Timestamp.now(),
      'status': "Ongoing",
    });

    _controller.restart();
  }

  void resumeTimer(Map<String, dynamic> admitData) {
    _controller.resume();
    final seconds = timeToSeconds(_controller.getTime()!);
    final DateTime startTime =
        DateTime.now().subtract(Duration(seconds: seconds));
    updateFirestore(
        widget.type == "Surgery" ? "surgeries" : "admits", admitData['id'], {
      'starttime': Timestamp.fromDate(startTime),
      'ispaused': false,
    });
  }

  void pauseTimer(Map<String, dynamic> admitData) {
    _controller.pause();
    updateFirestore(
        widget.type == "Surgery" ? "surgeries" : "admits", admitData['id'], {
      'ispaused': true,
      'pausedseconds': timeToSeconds(_controller.getTime()!),
    });
  }

  void completeTimer(Map<String, dynamic> admitData) {
    try {
      if (admitData['isstarted'] == true) {
        updateFirestore(widget.type == "Surgery" ? "surgeries" : "admits",
            admitData['id'], {
          'isstarted': false,
          'status': "Completed",
          'finishedseconds': timeToSeconds(_controller.getTime()!)
        });
        _controller.pause();
        int totalAmount = timeToSeconds(_controller.getTime()!);
        double taxes = totalAmount * 0.07;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceWidget(
              payment: 'notpaid',
              role: 'doctor',
              id: admitData['id'],
              type: widget.type,
              invoiceNumber: 'INV${DateTime.now().toIso8601String()}',
              patientName: admitData['patientsname'],
              patientAddress: '123 Main Street, Springfield',
              patientPhone: '123-456-7890',
              invoiceDate: DateTime.now(),
              dueDate: DateTime.now().add(Duration(days: 7)),
              items: [
                {
                  'item': widget.type,
                  'description': widget.type,
                  'amount': totalAmount
                }
              ],
              subTotal: totalAmount.toDouble(),
              taxRate: 7,
              taxAmount: taxes,
              totalAmount: totalAmount + taxes,
              notes: 'Thank you for your prompt payment!',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please start the timer')));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurgeryandadmitProvider>(
      builder: (context, provider, child) {
        final admitData = widget.type == "Surgery"
            ? provider.filteredsurgeries[widget.index]
            : provider.filteredadmits[widget.index];
        final int durationInSeconds = admitData['durationinseconds'];

        int initialDuration = 0;
        if (admitData['starttime'] != null) {
          final Timestamp startTimeTimestamp = admitData['starttime'];
          final DateTime startTime = startTimeTimestamp.toDate();
          final int durationInSeconds = admitData['durationinseconds'];
          final int elapsedTimeSinceStart =
              DateTime.now().difference(startTime).inSeconds;
          initialDuration = elapsedTimeSinceStart > durationInSeconds
              ? durationInSeconds
              : elapsedTimeSinceStart;
        }

        return Scaffold(
          backgroundColor: Colors.deepPurple,
          body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(widget.type == "Surgery" ? "surgeries" : "admits")
                  .doc(admitData['id'])
                  .snapshots(),
              builder: (context, snapshots) {
                if (snapshots.hasData) {
                  final data = snapshots.data;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularCountDownTimer(
                            duration: durationInSeconds,
                            initialDuration: data!['starttime'] != null
                                ? data['ispaused']
                                    ? data['pausedseconds']
                                    : initialDuration
                                : 0,
                            controller: _controller,
                            width: 300,
                            height: 300,
                            ringColor: Colors.grey[300]!,
                            fillColor: Colors.purpleAccent[100]!,
                            backgroundColor: Colors.deepPurple[500],
                            strokeWidth: 10.0,
                            textStyle: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textFormat: CountdownTextFormat.HH_MM_SS,
                            autoStart: admitData['isstarted'],
                            onStart: () {
                              if (data['starttime'] == null) {
                                _controller.pause();
                              }
                            },
                            onChange: (value) {
                              print('initialduration $initialDuration');
                              print('dusationinseconds $durationInSeconds');
                              if (data['status'] == "Completed") {
                                _controller.pause();
                              }
                              if (data['ispaused'] == true &&
                                  !_controller.isPaused.value) {
                                provider.fetchsurgeriesandadmits("admits");
                                _controller.pause();
                              }
                              if (data['ispaused'] == false &&
                                  data['isstarted'] == true) {
                                _controller.resume();
                              }
                            },
                            onComplete: () {
                              final seconds = provider
                                  .convertTimeToSeconds(_controller.getTime()!);

                              if (seconds == data['durationinseconds']) {
                                if (widget.type == "Surgery") {
                                  FirebaseFirestore.instance
                                      .collection("surgeries")
                                      .doc(data['id'])
                                      .update({
                                    'isstarted': false,
                                    'status': "Completed",
                                    'finishedseconds': seconds
                                  });
                                  provider.fetchsurgeriesandadmits("surgeries");
                                  debugPrint('Countdown Ended');
                                } else {
                                  FirebaseFirestore.instance
                                      .collection("admits")
                                      .doc(data['id'])
                                      .update({
                                    'isstarted': false,
                                    'status': "Completed",
                                    'finishedseconds': seconds
                                  });
                                  provider.fetchsurgeriesandadmits("admits");
                                  debugPrint('Countdown Ended');
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Task Completed Successfully')));
                              }
                            }),
                        SizedBox(height: 30),
                        if (data!['status'] == "Pending" ||
                            data['status'] == "Ongoing")
                          Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!data['isstarted'])
                                ElevatedButton(
                                    onPressed: () {
                                      startTimer(admitData);
                                    },
                                    child: Text("Start")),
                              if (data['ispaused'])
                                ElevatedButton(
                                    onPressed: () {
                                      resumeTimer(admitData);
                                    },
                                    child: Text("Resume")),
                              if (data['isstarted'] && !data['ispaused'])
                                ElevatedButton(
                                    onPressed: () {
                                      pauseTimer(admitData);
                                    },
                                    child: Text("Pause")),
                              ElevatedButton(
                                  onPressed: () {
                                    completeTimer(admitData);
                                    provider
                                        .fetchsurgeriesandadmits("surgeries");
                                    provider.fetchsurgeriesandadmits("admits");
                                  },
                                  child: Text("Done")),
                            ],
                          ),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        );
      },
    );
  }
}
