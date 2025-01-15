

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Doctordetails {
  final String image;
  final String name;
  final double rating;
  final String expertise;

  Doctordetails(
      {required this.image,
      required this.name,
      required this.rating,
      required this.expertise});
}

class Appointmentdetails {
  final String name;
  

  final String expertise;
  final String date;
  final String time;
  Appointmentdetails(
      {
      required this.date,
      required this.time,
      required this.name,
      required this.expertise});
}


List<Doctordetails> docotDetails = [
      Doctordetails(
          image: 'assets/doctor.png',
          name: 'vivek',
          rating: 2.5,
          expertise: 'Cardiologist'),
      Doctordetails(
          image: 'assets/doctor.png',
          name: 'Rajesh',
          rating: 3.4,
          expertise: 'Dermatologist'),
      Doctordetails(
          image: 'assets/doctor.png',
          name: 'Sumesh',
          rating: 4.5,
          expertise: 'Pediatrician'),
      Doctordetails(
          image: 'assets/doctor.png',
          name: 'Jithish',
          rating: 5,
          expertise: 'Oncologist'),
      Doctordetails(
          image: 'assets/doctor.png',
          name: 'Suresh',
          rating: 1.5,
          expertise: 'Orthopedist'),
      Doctordetails(
          image: 'assets/doctor.png',
          name: 'Ratheesh',
          rating: 5,
          expertise: 'Neurologist'),
      Doctordetails(
          image: 'assets/doctor.png',
          name: 'Subash',
          rating: 3.4,
          expertise: 'Phsychaitrist'),
      Doctordetails(
          image: 'assets/doctor.png',
          name: 'vivek',
          rating: 4.5,
          expertise: 'Gynacolist')
    ];

    List<Appointmentdetails> appointmentdetails=[
      Appointmentdetails( date: '12/12/2024', time: '9:00 AM', name: 'Ratheesh', expertise: 'Neurologist'),
      Appointmentdetails( date: '6/12/2024', time: '12:00 pm', name: 'Ratheesh', expertise: 'Neurologist'),
      Appointmentdetails( date: '10/11/2024', time: '4:00 pm', name: 'Ratheesh', expertise: 'Neurologist'),
      Appointmentdetails( date: '4/11/2024', time: '2:00 pm', name: 'Ratheesh', expertise: 'Neurologist'),
    ];


        List<Appointmentdetails> currentappointments=[
      Appointmentdetails( date: 'Tomorrow', time: '9:00 AM', name: 'Subash', expertise: 'Neurologist'),
      Appointmentdetails( date: '30/12/2024', time: '12:00 pm', name: 'Ratheesh', expertise: 'Neurologist'),
       Appointmentdetails( date: '7/1/2024', time: '12:00 pm', name: 'Suresh', expertise: 'Orthopedist'),
    
    
    ];

    _AppointmentDataSource getCalendarDataSource() {
  List<Appointment> appointments = <Appointment>[];
  appointments.add(Appointment(
    startTime: DateTime.now(),
    endTime: DateTime.now().add(Duration(minutes: 10)),
    subject: 'appointmen with Doctor vivek(Cardiologist)',
    color: Colors.blue,
    startTimeZone: '',
    endTimeZone: '',
  ));
 appointments.add(Appointment(
    startTime: DateTime.now(),
    endTime: DateTime.now().add(Duration(hours: 1)),
    subject: 'appointmen with Doctor vivek(Cardiologist)',
    color: Colors.blue,
    startTimeZone: '',
    endTimeZone: '',
  ));

  return _AppointmentDataSource(appointments);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source){
   appointments = source; 
  }
}

