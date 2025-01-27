import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hospital_managment/appointments/appointments_provider.dart';
import 'package:hospital_managment/appointments/appointmentshow.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Appointmentshowtile extends StatefulWidget {
  final Map appointmentdata;

  final void Function()? onPressed;
  final void Function()? ontap;
  final Map userdata;
  const Appointmentshowtile({
    super.key,
    required this.appointmentdata,
    required this.userdata,
    required this.onPressed,
    required this.ontap,
  });

  @override
  State<Appointmentshowtile> createState() => _MedicalRecordTileState();
}

class _MedicalRecordTileState extends State<Appointmentshowtile> {
  @override
  Widget build(BuildContext context) {
    final date = widget.appointmentdata['date'].toDate();

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        color: const Color.fromARGB(136, 79, 34, 153),
        shadowColor: const Color.fromARGB(24, 99, 69, 155),
        elevation: 15,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DialogAppointmentcontainer(
                          patentname: widget.appointmentdata['patientname'],
                          doctorsname: widget.appointmentdata['doctorsname'],
                          patientid: widget.appointmentdata['patientid'],
                          reason: widget.appointmentdata['reason'],
                          appointmentid:
                              widget.appointmentdata['appointmentid'],
                          note: widget.appointmentdata['note'],
                          status: widget.appointmentdata['status'],
                          userdata: widget.userdata,
                          date: date,
                          age: widget.appointmentdata['patientage'],
                          gender: widget.appointmentdata['gender'],
                          description: widget.appointmentdata['description'],
                          rating: widget.appointmentdata['rating'],
                          url: widget.appointmentdata['doctorimageurl'],
                          name: widget.userdata['roles'] == 'patient'
                              ? widget.appointmentdata['doctorsname']
                              : widget.appointmentdata['patientname'],
                          type: widget.appointmentdata['type'],
                          approved: widget.appointmentdata['approved'],
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userdata['roles'] == 'patient'
                          ? widget.appointmentdata['doctorsname']
                          : widget.appointmentdata['patientname'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.appointmentdata['reason'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month),
                            Text(
                              DateFormat("dd-MM-yyyy").format(date),
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
                            Icon(Icons.alarm),
                            Text(
                              widget.appointmentdata['timeslot'],
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                (widget.appointmentdata['approved'] ||
                        widget.appointmentdata['status'] != "null")
                    ? Column(
                        children: [
                          Text(
                            widget.appointmentdata['status'],
                            style: TextStyle(
                                color: widget.appointmentdata['status'] ==
                                        "Approved"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 19),
                          ),
                          widget.appointmentdata['prescribed'] == 'null'
                              ? 
                               widget.appointmentdata['status']=='Approved'?
                              Text(
                                  'Nothing selected',
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold),
                                ):SizedBox()
                              : Text(
                                  widget.appointmentdata['prescribed'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                        ],
                      )
                    : widget.userdata['roles'] == 'patient'
                        ? ElevatedButton(
                            onPressed: widget.onPressed,
                            child: Text(
                              'Delete',
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 20,
                                  child: IconButton(
                                    tooltip: "Accept",
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      try {
                                        FirebaseFirestore.instance
                                            .collection("appointments")
                                            .doc(widget.appointmentdata[
                                                'appointmentid'])
                                            .update({
                                          'status': "Approved",
                                          'approved': true,
                                          'code': 'b',
                                        });
                                        Provider.of<AppointmentsProvider>(
                                                context,
                                                listen: false)
                                            .fetchAppointmentsPatients();
                                        print("status updated");
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 20,
                                  child: IconButton(
                                    tooltip: "Reject",
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      try {
                                        FirebaseFirestore.instance
                                            .collection("appointments")
                                            .doc(widget.appointmentdata[
                                                'appointmentid'])
                                            .update({
                                          'status': "Rejected",
                                          'approved': false,
                                          'code': 'c'
                                        });
                                        Provider.of<AppointmentsProvider>(
                                                context,
                                                listen: false)
                                            .fetchAppointmentsPatients();
                                        print("status updated");
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
