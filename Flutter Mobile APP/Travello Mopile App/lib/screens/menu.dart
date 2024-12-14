import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Travello/screens/ticket.dart';
import 'package:Travello/widget/nextfloatingbutton.dart';
import 'package:Travello/widget/menubuttons.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _isExpanded = false;
  Map<String, dynamic> flightInfo = {};

  @override
  void initState() {
    getName();
    getFlightData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF01497C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/Profile');
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(bottom: 5, left: 5),
            child: const CircleAvatar(
              radius: 20.0,
              backgroundImage: AssetImage('images/avatar.png'),
            ),
          ),
        ),
        title: FutureBuilder<String>(
          future: getName(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text(
                snapshot.data!,
                style: const TextStyle(color: Colors.white),
              );
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.height * 0.7,
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
                                          fontFamily: 'ADLaMDisplay'),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  _roundedTextField('Enter Ticket ID',
                                      Icons.airplane_ticket_outlined,
                                      controller: ticketno),
                                  const SizedBox(height: 22),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0),
                                      backgroundColor: const Color(0xFF01497C),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      minimumSize: Size(130, 45),
                                    ),
                                    onPressed: () {
                                      getFlightData();
                                      addFlightToPassenger();
                                      currentFlight();
                                      Navigator.pop(context);
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
                },
              );
            },
            icon: const Icon(
              Icons.airplane_ticket_outlined,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50.0),
                    MenuButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      text: 'Flight Information',
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: _isExpanded ? 200.0 : 0.0,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.orange[300],
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 20),
                                      Text(
                                        'From: ${flightInfo['departure']}',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'To: ${flightInfo['arrival']}',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Terminal: ${flightInfo['terminal']}',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 20),
                                      Text(
                                        'Date: ${flightInfo['departure_date']}',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Departure: ${flightInfo['departure_time']}',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Gate: ${flightInfo['gate']}',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    MenuButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/bluetooth');
                      },
                      text: 'Navigation Options',
                    ),
                    const SizedBox(height: 12.0),
                    MenuButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/baggage');
                      },
                      text: 'Baggage Tracking',
                    ),
                    const SizedBox(height: 12.0),
                    MenuButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/guestscreen');
                      },
                      text: 'Find Family and Friends',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: NextFButton(
        onPressed: () async {
          Navigator.popAndPushNamed(context, '/client');
        },
        icon: Icons.contact_support,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<String> getName() async {
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

  Future<void> initializeData() async {
    try {
      await Future.wait([
        getName(),
      ]);
      print('Initialization complete');
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> getFlightData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot passengerDoc =
          await firestore.collection('passenger').doc(currentUserUid).get();

      if (passengerDoc.exists) {
        Map<String, dynamic> current =
            passengerDoc.data() as Map<String, dynamic>;
        if (current.containsKey('currentflight') &&
            current['currentflight'] != null &&
            current['currentflight'].isNotEmpty) {
          String name = current['currentflight'];
          DocumentSnapshot ticketDoc =
              await firestore.collection('ticket').doc(name).get();
          if (ticketDoc.exists) {
            Map<String, dynamic> data =
                ticketDoc.data() as Map<String, dynamic>;
            int ticket = data['flightID'];

            DocumentSnapshot flightDoc = await firestore
                .collection('flight')
                .doc(ticket.toString())
                .get();
            if (flightDoc.exists) {
              Map<String, dynamic> flightData =
                  flightDoc.data() as Map<String, dynamic>;
              flightInfo = {
                'arrival': flightData['arrival'],
                'arrival_time': flightData['arrival_time'],
                'departure': flightData['departure'],
                'departure_date': flightData['departure_date'],
                'departure_time': flightData['departure_time'],
                'gate': flightData['gate'],
                // 'seat': flightData['seat'],
                'terminal': flightData['terminal']
              };
            } else {
              Fluttertoast.showToast(msg: "Flight is not exists");
            }
          } else {
            Fluttertoast.showToast(msg: "Please Enter Valid Ticket");
          }
        } else {
          Fluttertoast.showToast(msg: "Please Enter Your Ticket number");
        }
      } else {
        Fluttertoast.showToast(msg: "Error occured. Please try again later");
      }
    } catch (e) {
      print("Error: $e");
      Fluttertoast.showToast(msg: "Flight not exists");
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
}
