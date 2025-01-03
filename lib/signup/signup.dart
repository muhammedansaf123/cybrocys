import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:first_app/components/components.dart';

import 'package:first_app/login/login_page.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  var formKey = GlobalKey<FormState>();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  String? imageurl;
  File? _image;
  File? _image2;
  final picker = ImagePicker();
  ScrollController scrollController = ScrollController();
bool isloading=false;
  void signup() async {
setState(() {
  isloading=true;
});
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    } else {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        final imagedata = prefs.getString('currentimage');
        prefs.setString(credential.user!.uid, imagedata!);
        print('image resaved');

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'name': fullnameController.text,
          'email': emailController.text,
          'phone': phonenumberController.text,
          'address': addressController.text,
          'imageurl': imagedata,
          'roles': "",
          'authentication': false,
          'uid': credential.user!.uid
        });
        setState(() {
  isloading=false;
});

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Succesfully Signed up')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginDemo()),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        storeimage(pickedFile!);
      }
    });
  }

  void loadimage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final imagedata = prefs.getString('currentimage');
    setState(() {
      _image2 = File(imagedata!);
    });
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        storeimage(pickedFile!);
      }
    });
  }

  Future<String> storeimage(XFile pickedFile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('currentimage', pickedFile.path);
    print('imagestored');

    return pickedFile.path;
  }

  void printdata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.getString('image');
    print('image:${prefs.getString('image')}');
  }

  Future showOptions() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () {
                    showOptions();
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: const Color(0xFFECE5B6), width: 2)),
                    child: ClipOval(
                      child: _image == null
                          ? Image.asset(
                              'assets/patient.png',
                              scale: 11,
                            )
                          : Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: fullnameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    hintText: 'Enter your Fullname',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(width: 3, color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter a valid name!';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    hintText: 'Enter your Email',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(width: 3, color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty ||
                        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                      return 'Enter a valid email!';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    hintText: 'Enter your Password',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(width: 3, color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 7) {
                      return 'Password must be higher than 7 of length';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: phonenumberController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    hintText: 'Enter your Number',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(width: 3, color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value!.length != 10) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  minLines: 2,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: addressController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      hintText: 'Enter your Address',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(width: 3, color: Colors.black))),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account'),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginDemo()));
                        },
                        child: Text(
                          'Log in',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
                SizedBox(height: 10),
               Mybutton(load: isloading, onPressed: (){
                signup();
               }, text: 'Sign Up')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
