import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Travello/screens/ticket.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  void forgetPassword() async {
    if (email.text.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
        Fluttertoast.showToast(
          msg: "Password reset email sent successfully.",
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage =
            "Error sending password reset email. Please try again later.";
        if (e.code == 'user-not-found') {
          errorMessage = "Email address not found.";
        }
        Fluttertoast.showToast(
          msg: errorMessage,
        );
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: $e");
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please enter your email address.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 100.0),
              Container(
                alignment: Alignment.center,
                child: Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
              ),
              SizedBox(height: 50.0),
              _roundedTextField('Email', Icons.email, controller: email),
              SizedBox(height: 10.0),
              _roundedTextField('Password', Icons.lock,
                  obscureText: true, controller: password),
              Container(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    forgetPassword();
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF3951),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 120.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  backgroundColor: Color(0xFF01497C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  if (email.text.isEmpty || password.text.isEmpty) {
                    Fluttertoast.showToast(msg: 'Please fill your credentials');
                  } else {
                    try {
                      final credential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: email.text, password: password.text);
                      if (Platform.isWindows ||
                          Platform.isAndroid &&
                              email.text == "staff@travello.com") {
                        Navigator.pushReplacementNamed(context, '/staffmenu');
                      } else if (email.text
                          .contains('.security@travello.com')) {
                        Navigator.pushReplacementNamed(
                            context, '/securitytracking');
                      } else {
                        if (FirebaseAuth.instance.currentUser!.emailVerified ==
                            false) {
                          Navigator.pushReplacementNamed(
                              context, '/Verification');
                        } else {
                          Navigator.pushReplacementNamed(context, '/menu');
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      Fluttertoast.showToast(
                          msg: "email or password is incorrect");
                      if (e.code == 'user-not-found') {
                        Fluttertoast.showToast(
                            msg: 'No user found for that email.');
                      } else if (e.code == 'wrong-password') {
                        Fluttertoast.showToast(
                            msg: 'Wrong password provided for that user.');
                      }
                    }
                  }
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New member?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/Register');
                      },
                      child: Text(
                        'Register Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF3951),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/guestscreen');
                },
                child: Text(
                  'Continue as a Guest',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF3951),
                  ),
                ),
              ),
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
}
