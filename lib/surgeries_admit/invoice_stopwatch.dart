import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:circular_countdown_timer/countdown_text_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospital_managment/bottomnavigation/bottomnav.dart';
import 'package:hospital_managment/components/components.dart';
import 'package:hospital_managment/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:hospital_managment/surgeries_admit/surgeryandadmit_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:lottie/lottie.dart';

class MyStopwatch extends StatefulWidget {
  final String type;
  final String surgerytype;
  final String id;
  final String patientname;
  final int startingtime;
  final Map fulldata;
  final int duration;
  const MyStopwatch(
      {Key? key,
      required this.fulldata,
      required this.duration,
      required this.patientname,
      required this.type,
      required this.startingtime,
      required this.surgerytype,
      required this.id})
      : super(key: key);

  @override
  State<MyStopwatch> createState() => _MyStopwatchState();
}

final CountDownController _controller = CountDownController();

class _MyStopwatchState extends State<MyStopwatch> {
  final Stopwatch _stopwatch = Stopwatch();

  int timeToSeconds(String time) {
    List<String> parts = time.split(':');
    if (parts.length != 3) {
      throw FormatException('Invalid time format. Expected HH:mm:ss');
    }

    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    // Convert the time to total seconds
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  @override
  Widget build(BuildContext context) {
    print('paused${widget.fulldata['ispaused']}');
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
              CircularCountDownTimer(
                duration: widget.duration,
                initialDuration: widget.fulldata['ispaused']
                    ? widget.startingtime
                    : widget.startingtime + 3,
                controller: _controller,
                width: 300,
                height: 300,
                ringColor: Colors.grey[300]!,
                ringGradient: null,
                fillColor: Colors.purpleAccent[100]!,
                fillGradient: null,
                backgroundColor: Colors.deepPurple[500],
                backgroundGradient: null,
                strokeWidth: 4.0,
                strokeCap: StrokeCap.round,
                textStyle: const TextStyle(
                  fontSize: 30.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textFormat: CountdownTextFormat.HH_MM_SS,
                isReverse: false,
                isReverseAnimation: false,
                isTimerTextShown: true,
                autoStart:
                    widget.fulldata['status'] == "Ongoing" ? true : false,
                onStart: () {},
                onComplete: () {},
                onChange: (String timeStamp) {
                  if (widget.fulldata['ispaused'] == true) {
                    _controller.pause();
                    Provider.of<SurgeryandadmitProvider>(context,listen: false).controllers[index].pause();
                  }
                },
              ),
              SizedBox(
                height: 30,
              ),
              if (widget.fulldata['status'] == "Pending" ||
                  widget.fulldata['status'] == "Ongoing") ...[
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("admits")
                              .doc(widget.fulldata['id'])
                              .update({
                            'isstarted': true,
                            'starttime': Timestamp.now(),
                            'status': "Ongoing"
                          });
                          Provider.of<SurgeryandadmitProvider>(context,
                                  listen: false)
                              .fetchsurgeriesandadmits('admits');
                          _controller.restart();
                           Provider.of<SurgeryandadmitProvider>(context,listen: false).controllers[index].restart();
                        },
                        child: Text("start first")),
                    Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                           
                            final seconds =
                                timeToSeconds(_controller.getTime()!);
                           
                            DateTime currentTime = DateTime.now();

                            DateTime startTime = currentTime
                                .subtract(Duration(seconds: seconds));

                            Timestamp firestoreTimestamp =
                                Timestamp.fromDate(startTime);

                            FirebaseFirestore.instance
                                .collection("admits")
                                .doc(widget.fulldata['id'])
                                .update({
                              'starttime': firestoreTimestamp,
                              'ispaused': false
                            });
                            Provider.of<SurgeryandadmitProvider>(context,
                                    listen: false)
                                .fetchsurgeriesandadmits('admits');
                          });
                          _controller.start();
                           Provider.of<SurgeryandadmitProvider>(context,listen: false).controllers[index].start();
                        },
                        child: Text("restart")),
                    Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            final seconds =
                                timeToSeconds(_controller.getTime()!);
                            _controller.pause();
 Provider.of<SurgeryandadmitProvider>(context,listen: false).controllers[index].pause();
                            FirebaseFirestore.instance
                                .collection("admits")
                                .doc(widget.fulldata['id'])
                                .update({
                              'ispaused': true,
                              'pausedseconds': seconds,
                            });
                          });
                          Provider.of<SurgeryandadmitProvider>(context,
                                  listen: false)
                              .fetchsurgeriesandadmits('admits');
                        },
                        child: Text("stop")),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          double totalAmount = widget.startingtime.toDouble();
                          print(
                              totalAmount); // Debugging print to check the value
                          DateTime date = DateTime.now();
                          String invdate =
                              "${date.day}/${date.month}/${date.year}";
                          double taxes = totalAmount * 0.07;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InvoiceWidget(
                                      onTriggerFunction: () {},
                                      payment: 'notpaid',
                                      role: 'doctor',
                                      id: widget.id,
                                      type: widget.type,
                                      invoiceNumber: 'INV${invdate}',
                                      patientName: widget.patientname,
                                      patientAddress:
                                          '123 Main Street, Springfield',
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
                                      notes:
                                          'Thank you for your prompt payment!',
                                    )),
                          );
                        },
                        child: Text("Done")),
                    Spacer()
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class InvoiceWidget extends StatefulWidget {
  final VoidCallback onTriggerFunction;
  final String type;
  final String invoiceNumber;
  final String patientName;
  final String patientAddress;
  final String patientPhone;
  final String role;
  final String payment;
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
    required this.onTriggerFunction,
    required this.role,
    required this.payment,
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

  @override
  State<InvoiceWidget> createState() => _InvoiceWidgetState();
}

class _InvoiceWidgetState extends State<InvoiceWidget> {
  late Razorpay razorpay;

  void handlePaymentSucess(PaymentSuccessResponse response) {
    if (widget.type == 'Surgery') {
      FirebaseFirestore.instance
          .collection('surgeries')
          .doc(widget.id)
          .update({'payment': 'paid'});
    }
    if (widget.type == 'Admit') {
      FirebaseFirestore.instance
          .collection('admits')
          .doc(widget.id)
          .update({'payment': 'paid'});
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/success.json',
                width: 200,
                height: 200,
                fit: BoxFit.fill,
                repeat: false,
              ),
              SizedBox(height: 16),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Thank you for your payment.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onTriggerFunction();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void handlePaymentError(PaymentFailureResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/failure.json',
                width: 200,
                height: 200,
                fit: BoxFit.fill,
                repeat: false,
              ),
              SizedBox(height: 16),
              Text(
                'Payment failure!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please Try Again...',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void handleExternalWallet(ExternalWalletResponse response) {}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSucess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }

  void checkOut() async {
    final amount = (widget.totalAmount * 100).toString();
    var options = {
      'key': 'rzp_test_8MbPmlMbqzDj0w',
      'amount': amount,
      'name': 'Bank',
      'description': 'Savings',
      'prefill': {'contact': '9876789876', 'email': 'test@razorpay.com'},
    };

    try {
      razorpay?.open(options);
    } catch (e) {
      print(e);
    }
  }

  void updatestatus(BuildContext context) {
    try {
      print(widget.type);
      if (widget.type == 'Surgery') {
        FirebaseFirestore.instance
            .collection('surgeries')
            .doc(widget.id)
            .update({'status': 'Success'});
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
          (Route<dynamic> route) => false,
        );

        Map<String, dynamic> invoiceData = {
          'id': widget.id,
          'type': widget.type,
          'invoiceNumber': widget.invoiceNumber,
          'patientName': widget.patientName,
          'patientPhone': widget.patientPhone,
          'patientAddress': widget.patientAddress,
          'invoiceDate': widget.invoiceDate.toIso8601String(),
          'dueDate': widget.dueDate.toIso8601String(),
          'items': widget.items,
          'subTotal': widget.subTotal,
          'taxRate': widget.taxRate,
          'taxAmount': widget.taxAmount,
          'totalAmount': widget.totalAmount,
          'notes': widget.notes,
        };

        // Adding the data to the 'invoice' collection
        FirebaseFirestore.instance
            .collection('invoice')
            .doc(widget.id)
            .set(invoiceData);
      }
      if (widget.type == 'Admit') {
        FirebaseFirestore.instance
            .collection('admits')
            .doc(widget.id)
            .update({'status': 'Success'});
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
          (Route<dynamic> route) => false,
        );

        Map<String, dynamic> invoiceData = {
          'id': widget.id,
          'type': widget.type,
          'invoiceNumber': widget.invoiceNumber,
          'patientName': widget.patientName,
          'patientPhone': widget.patientPhone,
          'patientAddress': widget.patientAddress,
          'invoiceDate': widget.invoiceDate.toIso8601String(),
          'dueDate': widget.dueDate.toIso8601String(),
          'items': widget.items,
          'subTotal': widget.subTotal,
          'taxRate': widget.taxRate,
          'taxAmount': widget.taxAmount,
          'totalAmount': widget.totalAmount,
          'notes': widget.notes,
        };

        // Adding the data to the 'invoice' collection
        FirebaseFirestore.instance
            .collection('invoice')
            .doc(widget.id)
            .set(invoiceData);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> generateInvoicePdf(BuildContext context) async {
    final pdf = pw.Document();
    print('helklo');
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(16.0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeaderpdf(),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),
              _buildInvoiceDetailspdf(),
              pw.Divider(thickness: 2),
              _buildItemsTablepdf(),
              pw.SizedBox(height: 10),
              _buildSummarypdf(),
              pw.Divider(thickness: 2),
              _buildFooterpdf(),
            ],
          ),
        ),
      ),
    );
    print(widget.invoiceNumber);
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: '${widget.invoiceDate}.pdf');
  }

  pw.Widget _buildHeaderpdf() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('City General Hospital',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Text('Kakkanchery, Calicut', style: pw.TextStyle(fontSize: 16)),
        pw.Text('www.citygeneral.com',
            style: pw.TextStyle(fontSize: 16, color: PdfColors.blue)),
        pw.SizedBox(height: 16),
        pw.Text('Invoice',
            style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 16),
        pw.Text('TO:',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(widget.patientName, style: pw.TextStyle(fontSize: 16)),
        pw.Text(widget.patientAddress, style: pw.TextStyle(fontSize: 16)),
        pw.Text(widget.patientPhone, style: pw.TextStyle(fontSize: 16)),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildInvoiceDetailspdf() {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6.0),
      child: pw.Column(
        children: [
          _buildInvoiceRowpdf('Invoice Number', widget.invoiceNumber),
          _buildInvoiceRowpdf(
              'Invoice Date', '${widget.invoiceDate.toLocal()}'.split(' ')[0]),
          _buildInvoiceRowpdf(
              'Invoice Due Date', '${widget.dueDate.toLocal()}'.split(' ')[0]),
        ],
      ),
    );
  }

  pw.Widget _buildInvoiceRowpdf(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(value, style: pw.TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  pw.Widget _buildItemsTablepdf() {
    return pw.Column(
      children: [
        _buildTableRowpdf('ITEM', 'DESCRIPTION', 'AMOUNT', isHeader: true),
        for (var item in widget.items)
          _buildTableRowpdf(item['item'], item['description'],
              '\₹${item['amount'].toStringAsFixed(2)}'),
        pw.Divider(thickness: 2),
      ],
    );
  }

  pw.Widget _buildTableRowpdf(String label, String description, String amount,
      {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isHeader ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(description,
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isHeader ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(amount,
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isHeader ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  pw.Widget _buildSummarypdf() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        _buildInvoiceRowpdf(
            'SUB TOTAL', '\₹${widget.subTotal.toStringAsFixed(2)}'),
        _buildInvoiceRowpdf(
            'TAX RATE', '${widget.taxRate.toStringAsFixed(1)}%'),
        _buildInvoiceRowpdf('TAX', '\₹${widget.taxAmount.toStringAsFixed(2)}'),
        _buildInvoiceRowpdf(
            'TOTAL', '\₹${widget.totalAmount.toStringAsFixed(2)}'),
      ],
    );
  }

  pw.Widget _buildFooterpdf() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text('Thank you for choosing City General Hospital.',
            style: pw.TextStyle(fontSize: 16)),
        pw.SizedBox(height: 20),
        if (widget.role == 'doctor')
          pw.Text("Send", style: pw.TextStyle(fontSize: 16)),
        if (widget.role == 'patient')
          pw.Text("Pay", style: pw.TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          onPressed: () {
            generateInvoicePdf(context);
          },
          child: Icon(Icons.download),
        ),
      ),
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
              _buildSummarydetails(),
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
        Text(widget.patientName, style: TextStyle(fontSize: 16)),
        Text(widget.patientAddress, style: TextStyle(fontSize: 16)),
        Text(widget.patientPhone, style: TextStyle(fontSize: 16)),
        SizedBox(height: 16),
      ],
    );
  }

  // Widget customcolumn(String title, List<String> details) {
  Widget invoiceDetails() {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        children: [
          invoiceRow('Invoice Number', widget.invoiceNumber),
          invoiceRow(
              'Invoice Date', '${widget.invoiceDate.toLocal()}'.split(' ')[0]),
          invoiceRow(
              'Invoice Due Date', '${widget.dueDate.toLocal()}'.split(' ')[0]),
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
        for (var item in widget.items)
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
          Text(description,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
          Text(amount,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildSummarydetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        invoiceRow('SUB TOTAL', '\₹${widget.subTotal.toStringAsFixed(2)}'),
        invoiceRow('TAX RATE', '${widget.taxRate.toStringAsFixed(1)}%'),
        invoiceRow('TAX', '\₹${widget.taxAmount.toStringAsFixed(2)}'),
        invoiceRow('TOTAL', '\₹${widget.totalAmount.toStringAsFixed(2)}'),
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
        if (widget.role == 'doctor') ...[
          Mybutton(
              load: false,
              onPressed: () {
                updatestatus(context);
              },
              text: "Send")
        ],
        if (widget.role == 'patient' && widget.payment == 'notpaid') ...[
          Mybutton(
              load: false,
              onPressed: () {
                checkOut();
              },
              text: "Pay")
        ],
        if (widget.role == 'patient' && widget.payment == 'paid') ...[
          Mybutton(
              color: Colors.green, load: false, onPressed: () {}, text: "Paid")
        ]
      ],
    );
  }
}
