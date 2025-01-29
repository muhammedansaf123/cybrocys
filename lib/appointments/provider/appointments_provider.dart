import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_managment/user/userdata.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AppointmentsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _allRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  DateTime? startDate;
  DateTime? endDate;
  String currentfilter = 'Doctors name';
  String? selectedName;
  Map<String, dynamic>? userdata;
  bool isFilter = false;
  bool issearch = false;
  bool isnamefilter = false;
  DateTime? filterdate = DateTime.now();
  String status = '';
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> get allRecords => _allRecords;
  List<Map<String, dynamic>> get filteredRecords => _filteredRecords;

  void filter() {
    _filteredRecords = filterTasks(
      allRecords: _allRecords,
      query: searchController.text,
      selectedName: selectedName,
      startDate: startDate,
      endDate: endDate,
    );
    notifyListeners();
  }

  void changedropdownValue(String val) {
    currentfilter = val;
    notifyListeners();
  }

  void clearFilters() {
    startDate = null;
    endDate = null;
    selectedName = null;
    _filteredRecords = filterTasks(
      allRecords: _allRecords,
      query: searchController.text,
      selectedName: null,
      startDate: DateTime.now().subtract(Duration(days: 300)),
      endDate: DateTime.now().add(Duration(days: 300)),
    );
    notifyListeners();
  }

  void onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      startDate = args.value.startDate;

      endDate = args.value.endDate ?? args.value.startDate;
      filter();
    }
    notifyListeners();
  }

  List<Map<String, dynamic>> filterTasks(
      {required List<Map<String, dynamic>> allRecords,
      required String query,
      String? selectedName,
      DateTime? startDate,
      DateTime? endDate}) {
    return allRecords.where((appointment) {
      final matchesQuery = query.isEmpty ||
          appointment.values.any((value) {
            if (value is String) {
              return value.toLowerCase().contains(query.toLowerCase());
            }
            return false;
          });
      print('matchesQuery: $matchesQuery');

      final matchesSelectedName = selectedName == null ||
          (appointment['doctorsname'] as String)
              .toLowerCase()
              .contains(selectedName.toLowerCase());
      print('matchesSelectedName: $matchesSelectedName');

      final matchesDateRange = (startDate == null && endDate == null) ||
          (startDate != null &&
              endDate != null &&
              (appointment['date'] as Timestamp).toDate().isAfter(startDate) &&
              (appointment['date'] as Timestamp).toDate().isBefore(endDate));
      print('matchesDateRange: $matchesDateRange');

      return matchesQuery && matchesSelectedName && matchesDateRange;
    }).toList();
  }

  void getuserdata() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final user = await Userdata(uid: uid).getData();
    userdata = user;
    print("userdatafetched");

    notifyListeners();
  }

  Future<void> fetchAppointmentsPatients() async {
    print('hello ${userdata!['roles']}');

    if (userdata!['roles'] == 'doctor') {
      print("hvvhvhjvcdjd");
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('appointments')
              .where('doctorid',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .orderBy('code', descending: false)
              .get();

      List<Map<String, dynamic>> appointments =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      print(appointments);

      _allRecords = appointments;
      _filteredRecords = _allRecords;
      notifyListeners();
    } else {
      print('patient');
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('appointments')
              .where('patientid',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .orderBy('code', descending: false)
              .get();

      List<Map<String, dynamic>> appointments =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      print(appointments);

      _allRecords = appointments;
      _filteredRecords = _allRecords;
      notifyListeners();
    }
  }

  void clearAll() {
    _allRecords.clear();
    _filteredRecords.clear();
    startDate = null;
    endDate = null;
    currentfilter = 'Doctors name';
    selectedName = null;
    userdata = null;
    isFilter = false;
    issearch = false;
    isnamefilter = false;
    filterdate = DateTime.now();
    status = '';
    searchController.clear();
    notifyListeners();
  }
}
