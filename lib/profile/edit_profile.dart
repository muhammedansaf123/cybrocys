import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hospital_managment/components/components.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

TextEditingController fullname = TextEditingController();
TextEditingController phonenumber = TextEditingController();
TextEditingController addresscontroller = TextEditingController();
TextEditingController emailcontroller = TextEditingController();
String? roles = '';
String? name;
String position = '';

Map? _userdata;
bool isedit = false;

String userid = '';
String? imageurl;
File? _image;
File? _image2;
final picker = ImagePicker();
bool _isloading = false;

class _EditProfileState extends State<EditProfile> {
  @override
  void initState() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (mounted) {
      setState(() {
        _image = null;
        userid = user!.uid;
      });
    }
    super.initState();
  }

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imageurl = pickedFile.path;
      });
    }
  }

  Future<void> imageUpload() async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/dqskhange/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'hospital_managment'
        ..files.add(await http.MultipartFile.fromPath('file', imageurl!));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);

        setState(() {
          imageurl = jsonMap['url'];
        });
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imageurl = pickedFile.path;
      });
    }
  }

  Future<void> showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('Photo Gallery'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  void updateUser() async {
    setState(() {
      _isloading = true;
    });
    try {
      await imageUpload();

      if (imageurl != null) {
        FirebaseFirestore.instance.collection('users').doc(userid).update({
          'name': fullname.text,
          'phone': phonenumber.text,
          'address': addresscontroller.text,
          'imageurl': imageurl,
          'email': emailcontroller.text,
        });
      }
      setState(() {
        _isloading = true;
      });
    } catch (e) {
    } finally {
      setState(() {
        _isloading = false;
        isedit = false;
      });
    }
  }

  Future<String> getUrl(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return imageurl ?? prefs.getString(uid)!;
  }

  @override
  void dispose() {
    super.dispose();
  }

  late Stream<DocumentSnapshot<Map<String, dynamic>>>? personnalData =
      FirebaseFirestore.instance.collection('users').doc(userid).snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isedit = !isedit;
                  print(isedit);
                });
              },
              icon: isedit ? Icon(Icons.close) : Icon(Icons.edit)),
        ],
        leading: IconButton(
            onPressed: () {
              fullname.clear();
              phonenumber.clear();
              addresscontroller.clear();
              emailcontroller.clear();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder(
          stream: personnalData,
          builder: (context, userssnapshot) {
            final data = userssnapshot.data;
            if (userssnapshot.hasData) {
              fullname.text = data!['name'];
              phonenumber.text = data['phone'];
              addresscontroller.text = data['address'];
              emailcontroller.text = data['email'];
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border:
                              Border.all(color: Colors.deepPurple, width: 2)),
                      child: ClipOval(
                        child: _image == null
                            ? Image.network(
                                data['imageurl'],
                                fit: BoxFit.cover,
                              )
                            : Image.file(fit: BoxFit.cover, _image!),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    isedit
                        ? TextButton(
                            onPressed: () {
                              showOptions();
                            },
                            child: Text(
                              'Edit profile',
                              style: TextStyle(color: Colors.blue),
                            ))
                        : SizedBox(),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'User Details',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            isedit
                                ? Edittile(
                                    onTap: () {},
                                    controller: fullname,
                                    title: 'Full Name',
                                    autofocus: true,
                                  )
                                : Showtile(
                                    icons: Icons.person,
                                    data: data!['name'],
                                    title: 'Full Name'),
                            SizedBox(
                              height: 15,
                            ),
                            isedit
                                ? Edittile(
                                    onTap: () {},
                                    controller: phonenumber,
                                    title: 'Phone Number',
                                    autofocus: false,
                                  )
                                : Showtile(
                                    icons: Icons.phone,
                                    data: phonenumber.text,
                                    title: 'Phone Number'),
                            SizedBox(
                              height: 15,
                            ),
                            isedit
                                ? Edittile(
                                    onTap: () {},
                                    controller: addresscontroller,
                                    title: 'Address',
                                    autofocus: false,
                                  )
                                : Showtile(
                                    icons: Icons.location_city,
                                    data: addresscontroller.text,
                                    title: 'Address'),
                            SizedBox(
                              height: 15,
                            ),
                            isedit
                                ? Edittile(
                                    onTap: () {},
                                    controller: emailcontroller,
                                    title: 'Email',
                                    autofocus: false,
                                  )
                                : Showtile(
                                    icons: Icons.email,
                                    data: emailcontroller.text,
                                    title: 'Email'),
                            SizedBox(
                              height: 20,
                            ),
                            isedit
                                ? Mybutton(
                                    load: _isloading,
                                    onPressed: () {
                                      updateUser();
                                    },
                                    text: "Save")
                                : SizedBox(),
                            SizedBox(
                              height: 50,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else if (userssnapshot.connectionState ==
                ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              return Scaffold(
                body: Center(
                  child: Text('unexpected error occured'),
                ),
              );
            }
          }),
    );
  }
}

class Showtile extends StatelessWidget {
  final String title;
  final String data;
  final IconData icons;
  const Showtile(
      {super.key,
      required this.data,
      required this.title,
      required this.icons});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(
          height: 15,
        ),
        Container(
          height: 50,
          width: 400,
          padding: EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [Text(data), Spacer(), Icon(icons)],
          ),
        )
      ],
    );
  }
}

class Edittile extends StatelessWidget {
  final String title;
  final bool autofocus;
  final TextEditingController controller;
  final String hintText;
  final bool isIcon;
  final IconData icn;
  final bool istitle;
  final void Function()? onTap;
  const Edittile(
      {super.key,
      this.icn = Icons.abc,
      this.istitle = true,
      this.isIcon = false,
      required this.onTap,
      required this.controller,
      required this.title,
      this.hintText = "",
      required this.autofocus});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        istitle ? Text(title) : SizedBox(),
        SizedBox(
          height: 15,
        ),
        TextFormField(
          showCursor: true,
          autofocus: autofocus,
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: isIcon
                ? GestureDetector(
                    onTap: onTap,
                    child: Icon(icn),
                  )
                : SizedBox(),
            filled: true,
            hintText: hintText,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(width: 3, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
