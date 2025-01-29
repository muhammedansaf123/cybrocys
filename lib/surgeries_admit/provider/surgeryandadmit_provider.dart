import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_managment/user/userdata.dart';
import 'package:intl/intl.dart';

class SurgeryandadmitProvider extends ChangeNotifier {
  final TextEditingController searchControllersurgery = TextEditingController();
  final TextEditingController searchControlleradmits = TextEditingController();
  List<Map<String, dynamic>> filteredsurgeries = [];
  List<Map<String, dynamic>> allsurgeries = [];
  List<Map<String, dynamic>> filteredadmits = [];
  List<Map<String, dynamic>> alladmites = [];

  String currentfilter = 'Date';
  String? selectedDatesurgery;
  String? selectedDateadmit;
  final List<CountDownController> admitcontrollers = [];

  final List<CountDownController> surgeycontrollers = [];
  DateTime? datesurgery;
  DateTime? dateadmit;
  String? surgeryStatus;
  String? admitStatus;
  Map userdata = {};

  late TabController tabController;

  void initialisation(TickerProvider vsync) {
    fetchuserdata();

    tabController = TabController(length: 2, vsync: vsync);
    tabController.addListener(() {
      print('Current Tab Index: ${tabController.index}');
    });
  }

  void clear() {
    surgeycontrollers.clear();
    admitcontrollers.clear();
    allsurgeries.clear();
    alladmites.clear();
    filteredadmits.clear();
    filteredsurgeries.clear();
    notifyListeners();
  }

  void fetchuserdata() async {
    final data =
        await Userdata(uid: FirebaseAuth.instance.currentUser!.uid).getData();

    userdata = data;
    notifyListeners();
    fetchsurgeriesandadmits('surgeries');
    fetchsurgeriesandadmits('admits');
  }

  Future<List<Map<String, dynamic>>> fetchsurgeriesandadmits(
      String collectionname) async {
    print("hello");
    if (userdata['roles'] == 'doctor') {
      print('doctor');
      QuerySnapshot<Map<String, dynamic>> alldata = await FirebaseFirestore
          .instance
          .collection(collectionname)
          .where('doctorid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('status', descending: false)
          .get();

      List<Map<String, dynamic>> datas =
          alldata.docs.map((doc) => doc.data()).toList();

      if (collectionname == 'surgeries') {
        allsurgeries = datas;
        filteredsurgeries = allsurgeries;
        for (int i = 0; i < datas.length; i++) {
          surgeycontrollers.add(CountDownController());
        }
      } else if (collectionname == 'admits') {
        for (int i = 0; i < datas.length; i++) {
          admitcontrollers.add(CountDownController());
        }

        alladmites = datas;
        filteredadmits = alladmites;
      }
      notifyListeners();
      return datas;
    } else {
      QuerySnapshot<Map<String, dynamic>> alldata = await FirebaseFirestore
          .instance
          .collection(collectionname)
          .where('patientid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('status', descending: false)
          .get();

      List<Map<String, dynamic>> datas =
          alldata.docs.map((doc) => doc.data()).toList();

      if (collectionname == 'surgeries') {
        print("hello");
        for (int i = 0; i < datas.length; i++) {
          surgeycontrollers.add(CountDownController());
        }
        allsurgeries = datas;
        filteredsurgeries = allsurgeries;
      } else if (collectionname == 'admits') {
        for (int i = 0; i < datas.length; i++) {
          admitcontrollers.add(CountDownController());
        }
        alladmites = datas;
        filteredadmits = alladmites;
      }
      notifyListeners();
      return datas;
    }
  }

  List<Map<String, dynamic>> filterTaskssurgery({
    required List<Map<String, dynamic>> allRecords,
    required String query,
    String? status,
    String? date,
  }) {
    return allRecords.where((surgerydata) {
      final matchesQuery = query.isEmpty ||
          surgerydata.values.any((value) {
            if (value is String) {
              return value.toLowerCase().contains(query.toLowerCase());
            }
            return false;
          });
      print('matchesQuery: $matchesQuery');

      final matchesSelectedName = status == null ||
          (surgerydata['status'] as String)
              .toLowerCase()
              .contains(status.toLowerCase());
      print('matchesSelectedName: $matchesSelectedName');

      // Convert Timestamp to DateTime and format it to match 'dd-MM-yyyy'
      String formattedDate = '';
      if (surgerydata['date'] is Timestamp) {
        DateTime dateTime = (surgerydata['date'] as Timestamp).toDate();
        formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      }

      print('Formatted Date: $formattedDate');
      print('Filter Date: $date');

      final matchesDateRange = date == null || formattedDate == date;
      print('matchesdate: $matchesDateRange');

      return matchesQuery && matchesSelectedName && matchesDateRange;
    }).toList();
  }

  List<Map<String, dynamic>> filterTasksadmits({
    required List<Map<String, dynamic>> allRecords,
    required String query,
    String? status,
    String? date,
  }) {
    return allRecords.where((admitdata) {
      final matchesQuery = query.isEmpty ||
          admitdata.values.any((value) {
            if (value is String) {
              return value.toLowerCase().contains(query.toLowerCase());
            }
            return false;
          });
      print('matchesQuery: $matchesQuery');

      final matchesSelectedName = status == null ||
          (admitdata['status'] as String)
              .toLowerCase()
              .contains(status.toLowerCase());
      print('matchesSelectedName: $matchesSelectedName');

      String formattedDate = '';
      if (admitdata['admissionDate'] is Timestamp) {
        DateTime dateTime = (admitdata['admissionDate'] as Timestamp).toDate();
        formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      }

      print('Formatted Date: $formattedDate');
      print('Filter Date: $date');

      final matchesDateRange = date == null || formattedDate == date;
      print('matchesdate: $matchesDateRange');
      return matchesQuery && matchesSelectedName && matchesDateRange;
    }).toList();
  }

  void filtersurgery() {
    filteredsurgeries = filterTaskssurgery(
        allRecords: allsurgeries,
        query: searchControllersurgery.text,
        status: surgeryStatus,
        date: selectedDatesurgery);
    notifyListeners();
  }

  void filteradmits() {
    filteredadmits = filterTasksadmits(
        allRecords: alladmites,
        query: searchControlleradmits.text,
        status: admitStatus,
        date: selectedDateadmit);
    notifyListeners();
  }

  void clearQuerySuergey() {
    selectedDatesurgery = null;
    surgeryStatus = null;
    datesurgery = null;
    filteredsurgeries = filterTaskssurgery(
        allRecords: allsurgeries,
        query: searchControllersurgery.text,
        status: null,
        date: null);
    notifyListeners();
  }

  void clearQueryAdmits() {
    selectedDateadmit = null;
    admitStatus = null;
    dateadmit = null;
    filteredadmits = filterTasksadmits(
        allRecords: alladmites,
        query: searchControlleradmits.text,
        status: null,
        date: null);
    notifyListeners();
  }

  String formatTimeDifference(Timestamp startTime) {
    DateTime start = startTime.toDate();
    DateTime now = DateTime.now();

    Duration difference = now.difference(start);

    int hours = difference.inHours;
    int minutes = difference.inMinutes % 60;
    int seconds = difference.inSeconds;

    return '${hours.toString().padLeft(2, '0')}.${minutes.toString().padLeft(2, '0')}';
  }

  int convertTimeToSeconds(String time) {
    try {
      print("Input time: $time");
      List<String> parts = time.split(':');

      if (parts.length != 3) {
        throw FormatException("Invalid time format. Expected HH:mm:ss");
      }

      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      int seconds = int.parse(parts[2]);

      // Convert the time to total seconds
      return (hours * 3600) + (minutes * 60) + seconds;
    } catch (e) {
      print("Error: ${e.toString()}");
      return 0; // Return a default value in case of an error
    }
  }

  String formatTime(int milliseconds) {
    final int seconds = (milliseconds / 1000).truncate();
    final int minutes = (seconds / 60).truncate();
    final int hours = (minutes / 60).truncate();

    final int displaySeconds = seconds % 60;
    final int displayMinutes = minutes % 60;
    final int displayHours = hours;

    return '${displayHours.toString().padLeft(2, '0')}:'
        '${displayMinutes.toString().padLeft(2, '0')}:'
        '${displaySeconds.toString().padLeft(2, '0')}';
  }
}
