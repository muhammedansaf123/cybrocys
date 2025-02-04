import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hospital_managment/surgeries_admit/components/invoice_widget.dart';
import 'package:hospital_managment/surgeries_admit/components/stopwatch_widget.dart';
import 'package:hospital_managment/surgeries_admit/provider/surgeryandadmit_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SurgerAdmitTile extends StatefulWidget {
  final bool issurgery;
  final Map<String, dynamic> surgeryadmitdata;
  final Map userdata;
  final int index;
  final Widget child;
  const SurgerAdmitTile({
    super.key,
    required this.index,
    required this.issurgery,
    required this.surgeryadmitdata,
    required this.child,
    required this.userdata,
  });

  @override
  State<SurgerAdmitTile> createState() => _MedicalRecordTileState();
}

bool isloading = false;
void paymentFunction(
    String id, String payment, BuildContext context, String status) {
  try {
    FirebaseFirestore.instance
        .collection('invoice')
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists && status == "Completed") {
        final data = documentSnapshot.data() as Map<String, dynamic>;

        final String role = 'patient';
        final String id = data['id'];
        final String type = data['type'];

        final String invoiceNumber = data['invoiceNumber'];
        final String patientName = data['patientName'];
        final String patientAddress = data['patientAddress'];
        final String patientPhone = data['patientPhone'];
        final DateTime invoiceDate = DateTime.parse(data['invoiceDate']);
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
      } else if (status == "Ongoing") {
        print("no document exist");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The session is not finished yet')));
      } else if (status == "Pending") {
        print("no document exist");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The session is not started yet')));
      } 
      
       else {
        print("no document exist");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invoice hasnt been generated yet')));
      }
    });
  } catch (e) {
    print(e);
  }
}

class _MedicalRecordTileState extends State<SurgerAdmitTile> {
  @override
  Widget build(BuildContext context) {
    DateTime admissionDateadmits = !widget.issurgery
        ? (widget.surgeryadmitdata['admissionDate'] as Timestamp).toDate()
        : DateTime.now();
    DateTime dateSurgery = widget.issurgery
        ? (widget.surgeryadmitdata['date'] as Timestamp).toDate()
        : DateTime.now();
    String formattedDateadmit =
        DateFormat('dd/MM/yyyy').format(admissionDateadmits);
    String formattedDatesurgey = DateFormat('dd/MM/yyyy').format(dateSurgery);
    return Consumer<SurgeryandadmitProvider>(
        builder: (context, provider, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Material(
            color: Colors.deepPurple,
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              onTap: () {
                if (widget.surgeryadmitdata['status'] != 'Completed' &&
                    widget.issurgery == true &&
                    widget.userdata['roles'] == 'doctor') {
                  print("1");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyStopwatch(
                                index: widget.index,
                                type: 'Surgery',
                              )));
                }
                if (widget.issurgery == false &&
                    widget.userdata['roles'] == 'doctor' &&
                    widget.surgeryadmitdata['status'] != 'Completed') {
                  print("2");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyStopwatch(
                                index: widget.index,
                                type: 'Admit',
                              )));
                }

                if (widget.userdata['roles'] == 'patient') {
                  print("3");
                  paymentFunction(
                      widget.surgeryadmitdata['id'],
                      widget.surgeryadmitdata['payment'],
                      context,
                      widget.surgeryadmitdata['status']);
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
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
                                  ? formattedDatesurgey
                                  : formattedDateadmit,
                              icon: Icons.date_range,
                            ),
                            const SizedBox(height: 8),
                            DisplayRow(
                              title: 'Note',
                              value: widget.issurgery
                                  ? widget.surgeryadmitdata[
                                      'preSurgeryInstructions']
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
                                flex: 2,
                                child: Container(
                                  height: 100,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (widget.userdata['roles'] ==
                                              'patient' &&
                                          widget.surgeryadmitdata['status'] ==
                                              "Completed") ...[
                                        ElevatedButton(
                                            onPressed: () {
                                              paymentFunction(
                                                  widget.surgeryadmitdata['id'],
                                                  widget.surgeryadmitdata[
                                                      'payment'],
                                                  context,
                                                  widget.surgeryadmitdata[
                                                      'status']);
                                            },
                                            child: Text("Pay"))
                                      ],
                                      if (widget.surgeryadmitdata['status'] !=
                                          "Completed") ...[
                                        Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
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
                                                  height: 5,
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          widget.surgeryadmitdata[
                                                                      'status'] ==
                                                                  'Pending'
                                                              ? Colors.red
                                                              : Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      widget.surgeryadmitdata[
                                                          'status'],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Spacer(),
                                      ],
                                      if (widget.userdata['roles'] ==
                                              'doctor' &&
                                          widget.surgeryadmitdata['status'] ==
                                              "Completed") ...[
                                        ElevatedButton(
                                          onPressed: () {
                                            final totalAmount =
                                                widget.surgeryadmitdata[
                                                    'finishedseconds']??100;
                                            print(
                                                totalAmount); // Debugging print to check the value
                                            DateTime date = DateTime.now();
                                            String invdate =
                                                "${date.day}/${date.month}/${date.year}";
                                            double taxes = totalAmount * 0.07;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      InvoiceWidget(
                                                        payment: 'notpaid',
                                                        role: 'doctor',
                                                        id: widget
                                                                .surgeryadmitdata[
                                                            'id'],
                                                        type: widget.issurgery
                                                            ? "Surgery"
                                                            : "Admit",
                                                        invoiceNumber:
                                                            'INV${invdate}',
                                                        patientName: widget
                                                                .surgeryadmitdata[
                                                            'patientsname'],
                                                        patientAddress:
                                                            '123 Main Street, Springfield',
                                                        patientPhone:
                                                            '123-456-7890',
                                                        invoiceDate: DateTime(
                                                            2025, 1, 14),
                                                        dueDate: DateTime(
                                                            2025, 1, 21),
                                                        items: [
                                                          {
                                                            'item':
                                                                widget.issurgery
                                                                    ? "Surgery"
                                                                    : "Admit",
                                                            'description':
                                                                widget.issurgery
                                                                    ? "Surgery"
                                                                    : "Admit",
                                                            'amount':
                                                                totalAmount
                                                          },
                                                        ],
                                                        subTotal: totalAmount
                                                            .toDouble(),
                                                        taxRate: 7,
                                                        taxAmount: taxes,
                                                        totalAmount:
                                                            totalAmount + taxes,
                                                        notes:
                                                            'Thank you for your prompt payment!',
                                                      )),
                                            );
                                          },
                                          child: Text(
                                            "invoice",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              )
                            : Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
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
                                    ),
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
    });
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
