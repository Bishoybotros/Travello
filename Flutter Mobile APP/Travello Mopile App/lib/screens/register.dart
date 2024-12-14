import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Travello/screens/Ticket.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController rpassword = TextEditingController();
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  CollectionReference user = FirebaseFirestore.instance.collection('passenger');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 100),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ADLaMDisplay'),
                ),
              ),
              const SizedBox(height: 30),
              _roundedTextField('Username', Icons.person, controller: username),
              const SizedBox(height: 10),
              _roundedTextField('Email', Icons.email, controller: email),
              const SizedBox(height: 10),
              _roundedTextField('Password', Icons.lock,
                  obscureText: true, controller: password),
              const SizedBox(height: 10),
              const SizedBox(height: 120),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: const Color(0xFF01497C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  if (email.text.isEmpty ||
                      password.text.isEmpty ||
                      username.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please fill your credentials');
                  } else {
                    try {
                      final credential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: email.text,
                        password: password.text,
                      );
                      addName(username.text);
                      FirebaseAuth.instance.currentUser!.emailVerified
                          ? Navigator.pushReplacementNamed(context, '/Login')
                          : Navigator.pushReplacementNamed(
                              context, '/Verification');
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        Fluttertoast.showToast(
                            msg: 'The password provided is too weak.');
                      } else if (e.code == 'email-already-in-use') {
                        Fluttertoast.showToast(
                            msg: 'The account already exists for that email.');
                      }
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                child: const Text(
                  'SignUp',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ADLaMDisplay'),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already a member?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/Login');
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF3951),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/guestscreen');
                  },
                  child: const Text(
                    'Continue as a Guest',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFFFF3951)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundedTextField(String hintText, IconData icon,
      {bool obscureText = false, TextEditingController? controller}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                ),
              ),
            ),
            Icon(icon),
          ],
        ),
      ),
    );
  }

  Future<void> addName(String name) async {
    try {
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('passenger')
          .doc(currentUserUid) // Use current user's UID as document ID
          .set({"username": name, "passenger_id": currentUserUid});
      print("Document added successfully!");
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('passenger')
          .where('username', isEqualTo: username)
          .get();

      // If no documents are returned, then the username is unique
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print("Error checking username availability: $e");
      return false; // Return false in case of any error
    }
  }
}
