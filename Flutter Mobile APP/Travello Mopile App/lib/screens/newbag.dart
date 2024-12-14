import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NewBag extends StatefulWidget {
  const NewBag({super.key});

  @override
  State<NewBag> createState() => _NewBagState();
}

TextEditingController bagdesc = TextEditingController();
TextEditingController ticketno = TextEditingController();

Map<String, dynamic> flightInfo = {};

class _NewBagState extends State<NewBag> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference bags = FirebaseFirestore.instance.collection('bags');

  Future<String> getUsernameName() async {
    try {
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('passenger')
          .doc(currentUserUid)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        String name = data['username'];
        return name;
      } else {
        throw Exception("Document does not exist");
      }
    } catch (e) {
      print("Error: $e");
      throw e;
    }
  }


  Future<void> addbag() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot passengerDoc =
          await firestore.collection('passenger').doc(currentUserUid).get();

      if (passengerDoc.exists) {
        Map<String, dynamic> current =
            passengerDoc.data() as Map<String, dynamic>;
        String name = current['currentflight'];
        DocumentReference passengerRef =
            firestore.collection('passengerflights').doc(name);
        await passengerRef
            .collection('bags')
            .add({"description": bagdesc.text});
        bagdesc.clear();
      } else {
        print('Passenger document not found for user: $currentUserUid');
      }
    } catch (e) {
      print('Error retrieving current flight: $e');
    }
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
                        'New Bag',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ADLaMDisplay'),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _roundedTextField('Enter Bag Description', Icons.luggage,
                        controller: bagdesc),
                    // _roundedTextField(
                    //     'Enter Ticket Number ', Icons.airplane_ticket,
                    //     controller: ticketno),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        backgroundColor: const Color(0xFF01497C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: const Size(
                            130, 45), // Set the minimumSize to increase width
                      ),
                      onPressed: () {
                        if (bagdesc.text.isNotEmpty) {
                          addbag();
                          Navigator.pop(context);
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please Enter Description");
                        }
                      },
                      child: const Text(
                        'Enter',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'ADLaMDisplay'),
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
}
