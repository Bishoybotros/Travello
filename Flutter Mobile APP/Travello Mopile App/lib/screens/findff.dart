import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Travello/widget/backfloatingbutton.dart';

class GuestSrceen extends StatefulWidget {
  @override
  _GuestSrceenState createState() => _GuestSrceenState();
}

class _GuestSrceenState extends State<GuestSrceen> {
  TextEditingController ticket = TextEditingController();
  String currentLocation = "";
  String passengerName = "";

  Future<void> getPassengerLocation() async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      DocumentSnapshot ticketDoc = await firebaseFirestore
          .collection('passengerflights')
          .doc(ticket.text)
          .get();

      if (ticketDoc.exists) {
        String passengerId = ticketDoc['passengerid'];

        firebaseFirestore
            .collection('passenger')
            .doc(passengerId)
            .snapshots()
            .listen((passengerInfo) {
          if (passengerInfo.exists) {
            setState(() {
              if (passengerInfo.data()!.containsKey('currentlocation')) {
                currentLocation = passengerInfo['currentlocation'];
              } else {
                Fluttertoast.showToast(msg: "Passenger information not found");
              }
              if (passengerInfo.data()!.containsKey('username')) {
                passengerName = passengerInfo['username'];
              } else {
                Fluttertoast.showToast(msg: "Passenger information not found");
              }
            });
          } else {
            Fluttertoast.showToast(msg: "Passenger information not found");
          }
        });
      } else {
        Fluttertoast.showToast(msg: "Incorrect Ticket or not exists");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  route() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      Navigator.pushReplacementNamed(context, '/Login');
    } else {
      Navigator.pushReplacementNamed(context, '/menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 10),
                      child: const Text(
                        'Find Family and Friends',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ADLaMDisplay'),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _roundedTextField(
                            'Ticket Number',
                            Icons.airplane_ticket,
                            controller: ticket,
                          ),
                        ),
                        const SizedBox(
                            width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: const Color(0xFF01497C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () async {
                            if (ticket.text != "") {
                              getPassengerLocation();
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please Enter Ticket Number");
                            }
                          },
                          child: const Text(
                            'Find',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ADLaMDisplay'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Text(
                                    'Passenger Name: ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF3951),
                                        fontFamily: 'ADLaMDisplay'),
                                  ),
                                  Text(
                                    passengerName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'ADLaMDisplay'),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  const Text(
                                    'Current Location: ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF3951),
                                        fontFamily: 'ADLaMDisplay'),
                                  ),
                                  Text(
                                    currentLocation,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'ADLaMDisplay'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                route();
              },
            ),
          ),
        ],
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
