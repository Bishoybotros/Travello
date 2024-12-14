import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Travello/widget/backfloatingbutton.dart';

class Verification extends StatefulWidget {
  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());
  int _timerCount = 30;
  bool _resendButtonEnabled = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser!.sendEmailVerification();
    _startTimer();
    checkVerification();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkVerification();
      if (_timerCount > 0) {
        if (mounted) {
          setState(() {
            _timerCount--;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _resendButtonEnabled = true;
          });
        }
        _timer.cancel();
      }
    });
  }

  Future<void> checkVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user?.emailVerified == true) {
      if (mounted) {
        Fluttertoast.showToast(msg: "Email Verified!");
        Navigator.pushReplacementNamed(context, '/Login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(
                height: double.infinity,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Almost There',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ADLaMDisplay'),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Please click on the link sent to your email.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 80),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Didn't receive a code?"),
                            TextButton(
                              onPressed: _resendButtonEnabled
                                  ? () {
                                      FirebaseAuth.instance.currentUser!
                                          .sendEmailVerification();
                                      setState(() {
                                        _resendButtonEnabled = false;
                                        _timerCount = 30;
                                        _timer.cancel();
                                        _startTimer();
                                      });
                                    }
                                  : null,
                              child: const Text('Resend'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Center(
                          child: Text(
                            'Resend a new code in $_timerCount seconds',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16.0,
                left: 16.0,
                child: BackFButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/Register');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
