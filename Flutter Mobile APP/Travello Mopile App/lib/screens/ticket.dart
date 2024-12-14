import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Travello/screens/menu.dart';

class TicketNumber extends StatefulWidget {
  const TicketNumber({super.key});


  @override
  State<TicketNumber> createState() => _TicketNumberState();
}

TextEditingController ticketno = TextEditingController();

class _TicketNumberState extends State<TicketNumber> {
   @override
     void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      content: SingleChildScrollView(
        child: Container(
          height: screenSize.height * 0.5,
          width: screenSize.height * 0.7,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.only(top: 20),
                      child: const Text(
                        'New Flight',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _roundedTextField(
                        'Enter Ticket ID', Icons.airplane_ticket_outlined,
                        controller: ticketno),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        backgroundColor: const Color(0xFF01497C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: Size(
                            130, 45), // Set the minimumSize to increase width
                      ),
                      onPressed: () {
                        // getFlightData();
                        addFlightToPassenger();
                        currentFlight();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Enter',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> addFlightToPassenger() async {
  try {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('passengerflights').doc(ticketno.text).set({
      "passengerid":currentUserUid
    });
    print("Document added successfully!");
  } catch (e) {
    print("Error: $e");
  }
}

Future<void> currentFlight() async {
  try {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('passenger').doc(currentUserUid).update({
      "currentflight": ticketno.text,
    });
    print("Document updated successfully!");
  } catch (e) {
    print("Error: $e");
  }
}

Widget _roundedTextField(String hintText, IconData icon,
    {bool obscureText = false, TextEditingController? controller}) {
  return Container(
    alignment: Alignment.bottomCenter,
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
