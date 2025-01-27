import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hospital_managment/appointments/appointment_pdf.dart';
import 'package:hospital_managment/appointments/appointments_provider.dart';
import 'package:hospital_managment/appointments/components/appointmenttile.dart';
import 'package:hospital_managment/surgeries_admit/surgery_admit_forms.dart';
import 'package:hospital_managment/components/components.dart';
import 'package:hospital_managment/appointments/appointmentsbooking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Appointmentshowpage extends StatelessWidget {
  const Appointmentshowpage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            actions: [
              if (provider.userdata!['roles'] == 'patient')
                IconButton(
                    onPressed: () {
                      WidgetsBinding.instance.focusManager.primaryFocus
                          ?.unfocus();
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return SizedBox(
                              height: 500,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SingleChildScrollView(
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
                                      SizedBox(height: 5),
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
                                              value: provider.currentfilter,
                                              items: <String>[
                                                'Doctors name',
                                                'Date range',
                                              ].map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                provider.currentfilter = value!;
                                              },
                                            ),
                                          ),
                                          Spacer(),
                                          ElevatedButton(
                                              onPressed: () {
                                                provider.clearFilters();
                                              },
                                              child: Text("Clear Filter"))
                                        ],
                                      ),
                                      if (provider.currentfilter ==
                                          'Date range') ...[
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.grey[200],
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          child: SfDateRangePicker(
                                            onSelectionChanged:
                                                provider.onSelectionChanged,
                                            selectionMode:
                                                DateRangePickerSelectionMode
                                                    .range,
                                            initialSelectedRange:
                                                PickerDateRange(
                                              provider.startDate ??
                                                  DateTime.now().subtract(
                                                      const Duration(days: 1)),
                                              provider.endDate ??
                                                  DateTime.now().add(
                                                      const Duration(days: 1)),
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (provider.currentfilter ==
                                          'Doctors name') ...[
                                        Container(
                                          height: 300,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.grey[200],
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          child: StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('doctors')
                                                .snapshots(),
                                            builder: (context,
                                                AsyncSnapshot<QuerySnapshot>
                                                    snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }
                                              if (snapshot.hasError) {
                                                // ignore: avoid_print
                                                print(
                                                    'Error fetching data: ${snapshot.error}');
                                                return const Center(
                                                    child: Text(
                                                        'Error fetching data'));
                                              }

                                              if (snapshot.hasData &&
                                                  snapshot.data!.docs.isEmpty) {
                                                return const Center(
                                                    child: Text(
                                                        'No Doctors  found'));
                                              }
                                              return ListView.builder(
                                                  itemCount: snapshot
                                                      .data!.docs.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final doctorsdata = snapshot
                                                        .data!.docs[index];
                                                    final name =
                                                        doctorsdata['name'];

                                                    doctorsdata['rating'];

                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5),
                                                      child: Material(
                                                        elevation: 4,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        child: Card(
                                                          color: const Color
                                                              .fromARGB(
                                                              136, 79, 34, 153),
                                                          shadowColor:
                                                              const Color
                                                                  .fromARGB(24,
                                                                  99, 69, 155),
                                                          elevation: 15,
                                                          child: ListTile(
                                                              onTap: () {
                                                                print(provider
                                                                    .selectedName);

                                                                provider.selectedName =
                                                                    name;
                                                                provider
                                                                    .filter();
                                                              },
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          12),
                                                              leading: Text(
                                                                name,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              trailing:
                                                                  CircleAvatar(
                                                                radius: 10,
                                                                child: CircleAvatar(
                                                                    radius: 8,
                                                                    backgroundColor: provider.selectedName ==
                                                                            name
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .black),
                                                              )),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                        },
                      );
                    },
                    icon: Icon(Icons.tune))
            ],
            title: Text(
              'Appointments list',
              style: TextStyle(color: Colors.white),
            ),
            automaticallyImplyLeading: true,
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.deepPurple,
          ),
          body: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: provider.searchController,
                      onChanged: (value) {
                        provider.filter();
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.search),
                        hintText: "Search...",
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                BorderSide(color: Colors.deepPurple, width: 2)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.deepPurple, width: 3)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  if (provider.userdata!['roles'] == 'patient') ...[
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Container(
                                height: 50,
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.deepPurple)),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AppointmentsPage()));
                                    },
                                    child: Text(
                                      "book now",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              )),
                        )
                      ],
                    ),
                  ],
                  SizedBox(
                    height: 5,
                  ),
                  if (provider.filteredRecords.isEmpty &&
                      provider.allRecords.isNotEmpty) ...[
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
                  if (provider.filteredRecords.isEmpty &&
                      provider.allRecords.isEmpty) ...[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                    ),
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                  if (provider.filteredRecords.isNotEmpty) ...[
                    Container(
                      height:provider.userdata!['roles'] == 'patient'? MediaQuery.of(context).size.height * 0.75:MediaQuery.of(context).size.height * 0.85,
                      child: ListView.builder(
                        itemCount: provider.filteredRecords.length,
                        itemBuilder: (context, index) {
                          final appointmentData =
                              provider.filteredRecords[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Appointmentshowtile(
                              appointmentdata: appointmentData,
                              userdata: provider.userdata!,
                              ontap: () {},
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc(appointmentData['appointmentid'])
                                    .delete();
                                Provider.of<AppointmentsProvider>(context,
                                        listen: false)
                                    .fetchAppointmentsPatients();
                              },
                            ),
                          );
                        },
                      ),
                    )
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DialogAppointmentcontainer extends StatefulWidget {
  final Map userdata;
  final String patientid;
  final String patentname;
  final String doctorsname;
  final double rating;
  final String url;
  final String age;
  final String name;
  final String type;
  final String description;
  final String gender;
  final DateTime date;
  final String appointmentid;
  final void Function()? onPressed;
  final bool approved;
  final String status;
  final String note;
  final String reason;
  const DialogAppointmentcontainer({
    super.key,
    required this.patentname,
    required this.doctorsname,
    required this.patientid,
    required this.status,
    required this.age,
    required this.appointmentid,
    required this.note,
    required this.reason,
    required this.userdata,
    required this.date,
    required this.gender,
    required this.description,
    required this.rating,
    required this.url,
    required this.name,
    required this.type,
    required this.approved,
    required this.onPressed,
  });

  @override
  State<DialogAppointmentcontainer> createState() => _DialogContainerState();
}

class _DialogContainerState extends State<DialogAppointmentcontainer> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.status != "null"
          ? FloatingActionButton(
              child: Icon(
                Icons.download,
              ),
              onPressed: () {
                final pdf = pw.Document();

                pdf.addPage(pw.Page(
                    pageFormat: PdfPageFormat.a4,
                    build: (pw.Context context) {
                      return pw.Center(
                        child: pw.Text("Hello World"),
                      );
                    }));
               
                generatePdf(
                    reason: widget.reason,
                    appointmentid: widget.appointmentid,
                    note: widget.note,
                    status: widget.status,
                    userdata: widget.userdata,
                    date: widget.date,
                    age: widget.age,
                    gender: widget.gender,
                    description: widget.description,
                    rating: widget.rating,
                    url: widget.url,
                    name: widget.userdata['roles'] == 'patient'
                        ? widget.name
                        : widget.userdata['name'],
                    type: widget.type,
                    approved: widget.approved);
              })
          : SizedBox(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              if (widget.userdata['roles'] == 'patient')
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(widget.url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.type,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          (widget.status != "null")
                              ? Text(
                                  widget.status,
                                  style: TextStyle(
                                      color: widget.status == "Approved"
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                )
                              : Text(
                                  "Not Approved",
                                  style: TextStyle(color: Colors.red),
                                )
                        ]),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.rating} ★",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              const Text(
                "Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              DetailRow(label: "Full Name", value: widget.name),
              const SizedBox(height: 10),
              DetailRow(label: "Age", value: widget.age),
              const SizedBox(height: 10),
              DetailRow(label: "Gender", value: "Male"),
              const SizedBox(height: 10),
              DetailRow(label: "Purpose of Visit", value: widget.reason),
              const SizedBox(height: 10),
              DetailRow(
                  label: "Date",
                  value: DateFormat('dd-MM-yyyy').format(widget.date)),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.label,
                              color: Colors.deepPurple,
                              size: 24.0,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              "Describe Condition:",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (widget.userdata['roles'] == 'doctor' &&
                      widget.status == 'Approved' &&
                      widget.note == "") ...[
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Mybutton(
                              load: false,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SurgeryAdmitForms(
                                              patientname: widget.patentname,
                                              doctorsname: widget.doctorsname,
                                              patientid: widget.patientid,
                                              reason: widget.reason,
                                              userdata: widget.userdata,
                                              issurgery: true,
                                              appointmentid:
                                                  widget.appointmentid,
                                            )));
                              },
                              text: "Surgery"),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Mybutton(
                              load: false,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SurgeryAdmitForms(
                                              patientname: widget.patentname,
                                              doctorsname: widget.doctorsname,
                                              patientid: widget.patientid,
                                              reason: widget.reason,
                                              userdata: widget.userdata,
                                              issurgery: false,
                                              appointmentid:
                                                  widget.appointmentid,
                                            )));
                              },
                              text: "Admit"),
                        )
                      ],
                    )
                  ],
                  if (widget.status == 'Approved' && widget.note != "") ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.label,
                                color: Colors.deepPurple,
                                size: 24.0,
                              ),
                              Text(
                                "Prescribed:",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          if (widget.userdata['roles'] == 'doctor')
                            Text(
                              'you have ${widget.note}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          if (widget.userdata['roles'] == 'patient' &&
                              widget.status == 'Approved' &&
                              widget.note != '') ...[
                            Text(
                              "${widget.name} has requested for a surgery",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
