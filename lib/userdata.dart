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
      print(data);
      return data;
    } else {
      throw Exception('User not found');
    }
  }
}
