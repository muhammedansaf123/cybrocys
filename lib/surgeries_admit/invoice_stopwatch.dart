import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/components/components.dart';
import 'package:first_app/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MyStopwatch extends StatefulWidget {
  final String type;
  final String surgerytype;
  final String id;
  final String patientname;
  const MyStopwatch(
      {Key? key,
      required this.patientname,
      required this.type,
      required this.surgerytype,
      required this.id})
      : super(key: key);

  @override
  State<MyStopwatch> createState() => _MyStopwatchState();
}

class _MyStopwatchState extends State<MyStopwatch> {
  final Stopwatch _stopwatch = Stopwatch();
  late Duration _elapsedTime;
  late String _elapsedTimeString;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    _elapsedTime = Duration.zero;
    _elapsedTimeString = _formatElapsedTime(_elapsedTime);

    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      if (_stopwatch.isRunning) {
        _updateElapsedTime();
      }
    });
  }

  void _startStopwatch() {
    setState(() {
      if (!_stopwatch.isRunning) {
        _stopwatch.start();
      } else {
        _stopwatch.stop();
      }
    });
  }

  void _resetStopwatch() {
    setState(() {
      double totalAmount = _elapsedTime.inSeconds.toDouble();
      print(totalAmount); // Debugging print to check the value
      DateTime date = DateTime.now();
      String invdate = "${date.day}/${date.month}/${date.year}";
      double taxes = totalAmount * 0.07;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => InvoiceWidget(
                  id: widget.id,
                  type: widget.type,
                  invoiceNumber: 'INV${invdate}',
                  patientName: widget.patientname,
                  patientAddress: '123 Main Street, Springfield',
                  patientPhone: '123-456-7890',
                  invoiceDate: DateTime(2025, 1, 14),
                  dueDate: DateTime(2025, 1, 21),
                  items: [
                    {
                      'item': widget.type,
                      'description': widget.surgerytype,
                      'amount': totalAmount
                    },
                  ],
                  subTotal: totalAmount,
                  taxRate: 7,
                  taxAmount: taxes,
                  totalAmount: totalAmount + taxes,
                  notes: 'Thank you for your prompt payment!',
                )),
      );
    });

    _stopwatch.reset(); // Reset after calculation
    _stopwatch.stop();
    _updateElapsedTime();
  }

  void _updateElapsedTime() {
    setState(() {
      _elapsedTime = _stopwatch.elapsed;
      _elapsedTimeString = _formatElapsedTime(_elapsedTime);
    });
  }

  String _formatElapsedTime(Duration time) {
    return '${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(time.inSeconds.remainder(60)).toString().padLeft(2, '0')}.${(time.inMilliseconds % 1000 ~/ 100).toString()}';
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.type} Timer',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _elapsedTimeString,
                style: const TextStyle(
                    fontSize: 40.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _startStopwatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text(_stopwatch.isRunning ? 'Stop' : 'Start'),
                  ),
                  const SizedBox(width: 20.0),
                  ElevatedButton(
                    onPressed: _resetStopwatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text('Done'),
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

class InvoiceWidget extends StatelessWidget {
  final String type;
  final String invoiceNumber;
  final String patientName;
  final String patientAddress;
  final String patientPhone;

  final DateTime invoiceDate;
  final DateTime dueDate;
  final List<Map<String, dynamic>> items;
  final double subTotal;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String notes;
  final String id;
  InvoiceWidget({
    required this.id,
    required this.type,
    required this.invoiceNumber,
    required this.patientName,
    required this.patientAddress,
    required this.patientPhone,
    required this.invoiceDate,
    required this.dueDate,
    required this.items,
    required this.subTotal,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    required this.notes,
  });

  void updatestatus(BuildContext context) {
    try {
      print(type);
      if (type == 'Surgery') {
        FirebaseFirestore.instance
            .collection('surgeries')
            .doc(id)
            .update({'status': 'Success'});
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
          (Route<dynamic> route) => false,
        );

        Map<String, dynamic> invoiceData = {
          'id': id,
          'type': type,
          'invoiceNumber': invoiceNumber,
          'patientName': patientName,
          'patientPhone': patientPhone,
          'patientAddress': patientAddress,
          'invoiceDate': invoiceDate.toIso8601String(),
          'dueDate': dueDate.toIso8601String(),
          'items': items,
          'subTotal': subTotal,
          'taxRate': taxRate,
          'taxAmount': taxAmount,
          'totalAmount': totalAmount,
          'notes': notes,
        };

        // Adding the data to the 'invoice' collection
        FirebaseFirestore.instance
            .collection('invoice')
            .doc(id)
            .set(invoiceData);
      }
      if (type == 'Admit') {
        FirebaseFirestore.instance
            .collection('admits')
            .doc(id)
            .update({'status': 'Success'});
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
          (Route<dynamic> route) => false,
        );

        Map<String, dynamic> invoiceData = {
          'id': id,
          'type': type,
          'invoiceNumber': invoiceNumber,
          'patientName': patientName,
          'patientPhone': patientPhone,
          'patientAddress': patientAddress,
          'invoiceDate': invoiceDate.toIso8601String(),
          'dueDate': dueDate.toIso8601String(),
          'items': items,
          'subTotal': subTotal,
          'taxRate': taxRate,
          'taxAmount': taxAmount,
          'totalAmount': totalAmount,
          'notes': notes,
        };

        // Adding the data to the 'invoice' collection
        FirebaseFirestore.instance
            .collection('invoice')
            .doc(id)
            .set(invoiceData);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Invoice Preview',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(),
              Divider(thickness: 2),
              SizedBox(height: 10),
              invoiceDetails(),
              Divider(thickness: 2),
              itemsTable(),
              SizedBox(height: 10),
              _buildSummary(),
              Divider(thickness: 2),
              Footer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('City General Hospital',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Kakkanchery, Calicut', style: TextStyle(fontSize: 16)),
        Text('www.citygeneral.com',
            style: TextStyle(fontSize: 16, color: Colors.blue)),
        SizedBox(height: 16),
        Text('Invoice',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Text('TO:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(patientName, style: TextStyle(fontSize: 16)),
        Text(patientAddress, style: TextStyle(fontSize: 16)),
        Text(patientPhone, style: TextStyle(fontSize: 16)),
        SizedBox(height: 16),
      ],
    );
  }

  // Widget customcolumn(String title, List<String> details) {
  //   return Expanded(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(title,
  //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //         for (String detail in details)
  //           Text(detail, style: TextStyle(fontSize: 16)),
  //       ],
  //     ),
  //   );
  // }

  Widget invoiceDetails() {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        children: [
          invoiceRow('Invoice Number', invoiceNumber),
          invoiceRow('Invoice Date', '${invoiceDate.toLocal()}'.split(' ')[0]),
          invoiceRow('Invoice Due Date', '${dueDate.toLocal()}'.split(' ')[0]),
        ],
      ),
    );
  }

  Widget invoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget itemsTable() {
    return Column(
      children: [
        tableRow('ITEM', 'DESCRIPTION', 'AMOUNT', isHeader: true),
        for (var item in items)
          tableRow(item['item'], item['description'],
              '\₹${item['amount'].toStringAsFixed(2)}'),
        Divider(
          thickness: 2,
        )
      ],
    );
  }

  Widget tableRow(String label, String description, String amount,
      {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
          Text(description, style: TextStyle(fontSize: 16)),
          Text(amount, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        invoiceRow('SUB TOTAL', '\₹${subTotal.toStringAsFixed(2)}'),
        invoiceRow('TAX RATE', '${taxRate.toStringAsFixed(1)}%'),
        invoiceRow('TAX', '\₹${taxAmount.toStringAsFixed(2)}'),
        invoiceRow('TOTAL', '\₹${totalAmount.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget Footer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Thank you for choosing City General Hospital.',
            style: TextStyle(fontSize: 16)),
        SizedBox(height: 20),
       Mybutton(load: false, onPressed: (){
        updatestatus(context);
       }, text: "Send")
      ],
    );
  }
}
