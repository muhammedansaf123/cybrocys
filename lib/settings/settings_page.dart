import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_managment/appointments/appointments_provider.dart';
import 'package:hospital_managment/components/components.dart';
import 'package:hospital_managment/login/login_page.dart';
import 'package:hospital_managment/profile/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

TextEditingController oldpasswordController = TextEditingController();
TextEditingController passwordController = TextEditingController();
ExpansionTileController controller = ExpansionTileController();
int count = 0;
bool? authentication;

class _SettingsPageState extends State<SettingsPage> {
  FocusNode focus = FocusNode();
  FocusNode focus2 = FocusNode();

  @override
  void initState() {
    getdata();

    super.initState();
  }

  @override
  void dispose() {
    count = 0;
    oldpasswordController.clear();
    passwordController.clear();
    // TODO: implement dispose
    super.dispose();
  }

  void getdata() {
    User user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            authentication = data!['authentication'];
            print('auth$authentication');
          });
        }
      }
    });
  }

  void changePassword(String oldPassword, String newPassword) async {
    User user = FirebaseAuth.instance.currentUser!;
    AuthCredential credential =
        EmailAuthProvider.credential(email: user.email!, password: oldPassword);

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      controller.collapse();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Succesfully Changed Password')));
      }

      return null;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('error:$e')));
      print(e);
    }
  }

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  @override
  Widget build(BuildContext context) {
    if (authentication == null) {
      return Scaffold(
        body: Center(
          child: Container(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Settings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.deepPurple,
        ),
        body: Customcontainer(
          widget: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Text(
                        'General Settings',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Spacer(),
                      Icon(Icons.settings),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Theme(
                    data: Theme.of(context)
                        .copyWith(splashColor: Colors.grey[100]),
                    child: ExpansionTile(
                      shape: Border.all(width: 2, color: Colors.transparent),
                      controller: controller,
                      childrenPadding: EdgeInsets.all(0),
                      tilePadding: EdgeInsets.all(0),
                      onExpansionChanged: (value) {
                        setState(() {
                          count = 0;
                        });
                        passwordController.clear();
                        oldpasswordController.clear();
                      },
                      title: Text(
                        "Change your password",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      children: [
                        TextField(
                          focusNode: focus,
                          onTapOutside: (event) {
                            focus.unfocus();
                          },
                          onChanged: (_) {
                            print(passwordController.text.length);
                            setState(() {
                              count = oldpasswordController.text.length;
                            });
                          },
                          controller: oldpasswordController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            hintText: 'Enter Old Password',
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  BorderSide(width: 3, color: Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextField(
                          focusNode: focus2,
                          onTapOutside: (event) {
                            focus2.unfocus();
                          },
                          onChanged: (_) {
                            print(passwordController.text.length);
                            setState(() {
                              count = passwordController.text.length;
                            });
                          },
                          controller: passwordController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            hintText: 'Enter New Password',
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  BorderSide(width: 3, color: Colors.black),
                            ),
                          ),
                        ),
                        if (count > 0) ...[
                          Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                height: 65,
                                width: 360,
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.deepPurple)),
                                      child: Text(
                                        'Change password',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () {
                                        changePassword(
                                            oldpasswordController.text,
                                            passwordController.text);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ],
                        SizedBox(
                          height: 15,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Two Step Authentication',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Enable biometrics auth on loggin in to the app',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      Spacer(),
                      Switch(
                        value: authentication!,
                        onChanged: (auth) {
                          User user = FirebaseAuth.instance.currentUser!;
                          final uid = user.uid;
                          setState(() {
                            authentication = auth;

                            users.doc(uid).update({
                              'authentication': auth,
                            }).then((value) {
                              print("changed authentication to $auth");
                            });
                          });
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Theme(
                    data: Theme.of(context)
                        .copyWith(splashColor: Colors.grey[100]),
                    child: ExpansionTile(
                      shape: Border.all(color: Colors.transparent),
                      tilePadding: EdgeInsets.all(0),
                      title: Text(
                        'privacy policy',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      children: [
                        Customtile(
                          title: '1.Introduction',
                          subtitle: [
                            BulletText(
                                'This Privacy Policy explains how we collects, uses, and protects your personal information when you use our App.')
                          ],
                        ),
                        Customtile(
                            title: '2. Information We Collect',
                            subtitle: [
                              BulletText(
                                  'Name, email address, phone number, payment details, and medical history')
                            ]),
                        Customtile(
                            title: '3. How We Use Your Information',
                            subtitle: [
                              BulletText('To provide and improve our services'),
                              BulletText('To provide and improve our services'),
                              BulletText(
                                  'To connect you with medical professionals.'),
                              BulletText(
                                  'To communicate with you regarding your account or consultations.')
                            ]),
                        Customtile(
                          title: '4. Cookies',
                          subtitle: [
                            BulletText(
                                'We use cookies to enhance your experience. You can manage cookie preferences in your browser settings'),
                          ],
                        )
                      ],
                    ),
                  ),
                  Theme(
                    data: Theme.of(context)
                        .copyWith(splashColor: Colors.grey[100]),
                    child: ExpansionTile(
                      shape: Border.all(color: Colors.transparent),
                      tilePadding: EdgeInsets.all(0),
                      title: Text(
                        'terms and conditions',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      children: [
                        Customtile(
                          title: '1.Introduction',
                          subtitle: [
                            BulletText(
                                'Welcome to Dr Co , These Terms and Conditions ("Terms") govern your use of our doctor consultation application (the "App"). By using the App, you agree to these Terms. If you do not agree, please do not use the App.')
                          ],
                        ),
                        Customtile(title: '2.Servives', subtitle: [
                          BulletText(
                              'Our App provides a platform for connecting users with licensed medical professionals for consultations. The App does not provide medical advice, diagnosis, or treatment. All medical advice is provided directly by the consulting medical professional.')
                        ]),
                        Customtile(title: '3.User Responsibilities', subtitle: [
                          BulletText(
                              'You must be at least 18 years old to use the App.'),
                          BulletText(
                              'You agree to provide accurate and complete information when registering and using the App.'),
                          BulletText(
                              'You are responsible for maintaining the confidentiality of your account credentials.'),
                        ]),
                        Customtile(
                          title: '4.Fees & Payments',
                          subtitle: [
                            BulletText(
                                'Fees for consultations are displayed in the App.'),
                            BulletText(
                                'Payments are processed through secure third-party payment gateways.'),
                            BulletText(
                                'All payments are final and non-refundable, except as required by law.'),
                          ],
                        ),
                        Customtile(title: '5.Governing Law', subtitle: [
                          BulletText(
                              'These Terms are governed by the laws of [Jurisdiction].')
                        ]),
                      ],
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    onTap: () {
                      Provider.of<AppointmentsProvider>(context, listen: false)
                          .clearAll();
                      FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => LoginDemo(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    leading: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    trailing: Icon(Icons.logout),
                  ),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

class Customtile extends StatelessWidget {
  final String title;
  final List<Widget> subtitle;
  const Customtile({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(
            height: 4,
          ),
          Column(
            children: subtitle,
          )
        ],
      ),
    );
  }
}

class BulletText extends StatelessWidget {
  late String txt;
  BulletText(String t) {
    txt = t;
  }

  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('\u2022'),
        SizedBox(width: 5),
        Expanded(child: Text(txt))
      ],
    );
  }
}
