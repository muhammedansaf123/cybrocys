import 'package:hospital_managment/medical_records/medical_records_provider.dart';
import 'package:hospital_managment/medical_records/medicalrecords.dart';
import 'package:hospital_managment/surgeries_admit/provider/surgeryandadmit_provider.dart';
import 'package:hospital_managment/surgeries_admit/surgery_admit.dart';
import 'package:hospital_managment/components/components.dart';
import 'package:flutter/material.dart';
import 'package:hospital_managment/tester/tester.dart';
import 'package:provider/provider.dart';

class Drawerwidget extends StatelessWidget {
  final void Function()? onTap;
  const Drawerwidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepPurple.withAlpha(15),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(30),
                    height: 100,
                    color: Colors.deepPurple,
                    child: Text(
                      "Menu",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Customrow(
                icons: Icons.calendar_month_sharp,
                title: 'Appontments',
                onTap: onTap),
            Customrow(
                icons: Icons.medical_information,
                title: 'Medical Records',
                onTap: () {
                  Provider.of<MedicalRecordsProvider>(context, listen: false)
                      .fetchmedicalRecorddata();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Medicalrecords()));
                }),
            Customrow(
                icons: Icons.local_hospital_outlined,
                title: 'Surgeries and admits',
                onTap: () {
                  Provider.of<SurgeryandadmitProvider>(context, listen: false)
                      .clear();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SurgeryAdmit()));
                }),
            Customrow(
                icons: Icons.apartment,
                title: 'Departments & doctor',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyForm()));
                })
          ],
        ),
      ),
    );
  }
}
