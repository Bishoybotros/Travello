import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key});
  
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() {
    var duration = const Duration(seconds: 4, milliseconds: 0);
    return Timer(duration, route);
  }

  route() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Navigator.pushReplacementNamed(context, '/welcome1');
    } else {
      String? email = currentUser.email;
      if (email != null && email == 'staff@travello.com') {
        Navigator.pushReplacementNamed(context, '/staffmenu');
      } else if (email!.contains('.security@travello.com')) {
        Navigator.pushReplacementNamed(context, '/securitytracking');
      } else {
        Navigator.pushReplacementNamed(context, '/menu');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF014F86),
      body: SingleChildScrollView(
        child: content(),
      ),
    );
  }

  Widget content() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.scale(
            scale: 0.75,
            child: Container(
              margin: EdgeInsets.only(top: 50.0, bottom: 20.0),
              child: Lottie.asset('lib/raw/splash.json'),
            ),
          ),
          const Text(
            'Travello',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFamily: 'ADLaMDisplay',
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}
