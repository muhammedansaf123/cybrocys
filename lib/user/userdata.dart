import 'package:cloud_firestore/cloud_firestore.dart';

class Userdata {
  final String uid;
  Userdata({required this.uid});

  Future<Map<String, dynamic>> getData() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      return data;
    } else {
      throw Exception('User not found');
    }
  }
}

class Appointmendata {
  final String appointmentid;
  Appointmendata({required this.appointmentid});
  Future<Map<String, dynamic>> getappointmenData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentid)
        .get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      return data;
    } else {
      throw Exception('no data found');
    }
  }
}
