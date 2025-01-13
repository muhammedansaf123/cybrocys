import 'package:first_app/medical_records/medicalrecords.dart';
import 'package:first_app/surgeries_admit/surgery_admit.dart';
import 'package:first_app/components/components.dart';
import 'package:flutter/material.dart';

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
                  child: Container(padding: EdgeInsets.all(30),
                    height: 100,
                    color: Colors.deepPurple,
                    child: Text(
                      "Menu",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25,color: Colors.white),
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Medicalrecords()));
                }),
            Customrow(
                icons: Icons.local_hospital_outlined,
                title: 'Surgeries and admits',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SurgeryAdmit()));
                }),
            Customrow(
                icons: Icons.apartment,
                title: 'Departments & doctor',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Medicalrecords()));
                })
          ],
        ),
      ),
    );
  }
}
