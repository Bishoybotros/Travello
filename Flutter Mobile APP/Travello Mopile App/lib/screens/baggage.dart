import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Travello/screens/newbag.dart';
import 'package:Travello/widget/nextfloatingbutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Baggage extends StatefulWidget {
  const Baggage({Key? key}) : super(key: key);

  @override
  State<Baggage> createState() => _BaggageState();
}

class _BaggageState extends State<Baggage> {
  @override
  void initState() {
    getBags();
    super.initState();
  }

  List<QueryDocumentSnapshot> data = [];
  List<QueryDocumentSnapshot> status = [];
  StreamSubscription<QuerySnapshot>? statusSubscription;

  @override
  void dispose() {
    statusSubscription?.cancel();
    super.dispose();
  }

  Future<void> getBags() async {
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
        QuerySnapshot bagsQuery = await passengerRef.collection('bags').get();
        setState(() {
          data = bagsQuery.docs;
        });
      } else {
        print('Passenger document not found for user: $currentUserUid');
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Please enter Ticket number to track luggages");
    }
  }

  Future<void> getStatus(String docId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference passengerDocRef =
          firestore.collection('passenger').doc(currentUserUid);

      // Listening for changes in the passenger document
      passengerDocRef.snapshots().listen((passengerDocSnapshot) async {
        if (passengerDocSnapshot.exists) {
          Map<String, dynamic> current =
              passengerDocSnapshot.data() as Map<String, dynamic>;
          String name = current['currentflight'];
          DocumentReference passengerRef =
              firestore.collection('passengerflights').doc(name);
          DocumentReference statusRef =
              passengerRef.collection('bags').doc(docId);

          // Listening for changes in the status document
          statusSubscription = statusRef
              .collection('status')
              .snapshots()
              .listen((statusSnapshot) {
            setState(() {
              status = statusSnapshot.docs;
            });
          });
        } else {
          print('Passenger document not found for user: $currentUserUid');
        }
      });
    } catch (e) {
      print('Error retrieving current flight: $e');
    }
  }

  Future<String> getName() async {
    try {
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('passenger')
          .doc(currentUserUid)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> userData =
            documentSnapshot.data() as Map<String, dynamic>;
        String name = userData['username'];
        return name;
      } else {
        throw Exception("Document does not exist");
      }
    } catch (e) {
      print("Error: $e");
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
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
        title: Builder(
          builder: (context) => FutureBuilder<String>(
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
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Bags',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ADLaMDisplay'),
                  ),
                  IconButton(
                    onPressed: getBags,
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: screenSize.width * 0.8,
                height: screenSize.height * 0.3,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    String docId = data[index].id;
                    int itemNumber = index + 1;
                    String description = data[index]['description'];
                    return GestureDetector(
                      onTap: () {
                        getStatus(docId);
                        print(docId);
                        print('Tapped on Bag $itemNumber: $description');
                        for (var item in status) {
                          print(item.data());
                        }
                      },
                      child: ListTile(
                        title: Text('Bag $itemNumber: $description'),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: const Color(0xFF01497C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Are you sure you want to delete this bag?',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'ADLaMDisplay'),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 10),
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF61A5C2),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'ADLaMDisplay'),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF61A5C2),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Done',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'ADLaMDisplay'),
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      FirebaseFirestore
                                                          firestore =
                                                          FirebaseFirestore
                                                              .instance;
                                                      String currentUserUid =
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid;
                                                      DocumentSnapshot
                                                          passengerDoc =
                                                          await firestore
                                                              .collection(
                                                                  'passenger')
                                                              .doc(
                                                                  currentUserUid)
                                                              .get();
                                                      if (passengerDoc.exists) {
                                                        Map<String, dynamic>
                                                            current =
                                                            passengerDoc.data()
                                                                as Map<String,
                                                                    dynamic>;
                                                        String name = current[
                                                            'currentflight'];
                                                        DocumentReference
                                                            bagRef = firestore
                                                                .collection(
                                                                    'passengerflights')
                                                                .doc(name)
                                                                .collection(
                                                                    'bags')
                                                                .doc(data[index]
                                                                    .id);
                                                        await bagRef.delete();
                                                        setState(() {
                                                          data.removeAt(index);
                                                        });
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Bag is Deleted!");
                                                        Navigator.pop(context);
                                                      }
                                                    } catch (e) {
                                                      print(
                                                          'Error deleting bag: $e');
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Please try again!");
                                                    }
                                                  },
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Status:',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ADLaMDisplay'),
              ),
              Container(
                height: screenSize.height * 0.3,
                child: ListView.builder(
                  itemCount: status.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        status[index].data() as Map<String, dynamic>;
                    String location = data['location'];
                    String time = data['time'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: const Icon(
                          Icons.circle,
                          size: 12,
                          color: Colors.green,
                        ),
                        title: Text(
                          location,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          time,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Positioned(
        bottom: 20,
        right: 20,
        child: NextFButton(
          icon: Icons.add,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const NewBag();
              },
            );
          },
        ),
      ),
    );
  }
}
