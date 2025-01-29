//clear notificatio seen=true
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicalRecordsProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredRecords = [];
  List<Map<String, dynamic>>allRecords = [];
  String currentfilter = 'None';
  DateTime? selectedDate;
  String? status;
  String? selectedName;
  Future<List<Map<String, dynamic>>> fetchmedicalRecorddata() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('medicalrecords').get();

    List<Map<String, dynamic>> appointments =
        querySnapshot.docs.map((doc) => doc.data()).toList();

   
      allRecords = appointments;
      filteredRecords =allRecords;
      print(filteredRecords);
    notifyListeners();
    return appointments;
  }


   List<Map<String, dynamic>> filterTasks({
    required List<Map<String, dynamic>> allRecords,
    required String query,
    String? selectedName,
    DateTime? date,
    String? status,
  }) {
    return allRecords.where((medicalrecords) {
      final matchesQuery =
          query.isEmpty || containsQuery(medicalrecords, query.toLowerCase());

      final matches_SelectedName = selectedName == null ||
          (medicalrecords['consultation']['doctor']['name'] as String)
              .toLowerCase()
              .contains(selectedName.toLowerCase());
      final matchesSelected_Status = status == null ||
          (medicalrecords['status'] as String)
              .toLowerCase()
              .contains(status!.toLowerCase());

      final matchesDateRange = date == null ||
          (medicalrecords['consultation']['lastConsultationDate'] as String)
              .toLowerCase()
              .contains(DateFormat('dd-MM-yyyy').format(date));

     
      return matchesQuery &&
          matches_SelectedName &&
          matchesSelected_Status &&
          matchesDateRange;
    }).toList();
  }

  bool containsQuery(dynamic data, String query) {
    if (data is String) {
      return data.toLowerCase().contains(query);
    } else if (data is Map) {
      return data.values.any((value) => containsQuery(value, query));
    } else if (data is List) {
      return data.any((element) => containsQuery(element, query));
    }
    return false;
  }

  void filter() {
   
      filteredRecords = filterTasks(
          allRecords: allRecords,
          query: searchController.text,
          selectedName: selectedName,
          date: selectedDate,
          status: status);
    notifyListeners();
  }

  void clearQuery() {
  
      status = null;
      selectedDate = null;
      selectedName = null;
      filteredRecords = filterTasks(
          allRecords: allRecords,
          query: searchController.text,
          selectedName: null,
          date: null,
          status: null);
    notifyListeners();
  }
}
