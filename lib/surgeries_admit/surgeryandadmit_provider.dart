import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_managment/user/userdata.dart';

class SurgeryandadmitProvider extends ChangeNotifier {
  final TextEditingController searchControllersurgery = TextEditingController();
  final TextEditingController searchControlleradmits = TextEditingController();
  List<Map<String, dynamic>> filteredsurgeries = [];
  List<Map<String, dynamic>> allsurgeries = [];
  List<Map<String, dynamic>> filteredadmits = [];
  List<Map<String, dynamic>> alladmites = [];
  int? currentseconds;
  String currentfilter = 'Date';
  String? selectedDatesurgery;
  String? selectedDateadmit;
  final List<CountDownController> controllers = [];

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
    print('doctor');

    if (userdata['roles'] == 'doctor') {
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
      } else if (collectionname == 'admits') {
        for (int i = 0; i < datas.length; i++) {
          controllers.add(CountDownController());
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
        allsurgeries = datas;
        filteredsurgeries = allsurgeries;
      } else if (collectionname == 'admits') {
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
      final matchesDateRange = date == null ||
          (surgerydata['date'] as String).toLowerCase().contains(date);
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

      final matchesDateRange = date == null ||
          (admitdata['admissionDate'] as String).toLowerCase().contains(date);
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
