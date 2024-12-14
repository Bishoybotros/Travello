import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Travello/widget/menubuttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import QR flutter package

class QRGen extends StatefulWidget {
  const QRGen({Key? key}) : super(key: key);

  @override
  State<QRGen> createState() => _QRGenState();
}

class _QRGenState extends State<QRGen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String docId = '';
  List<QueryDocumentSnapshot> data = [];
  TextEditingController ticketno = TextEditingController();
  String qrData = ''; // Variable to hold QR data

  Future<void> getBags() async {
    try {
      DocumentSnapshot flightDoc = await firestore
          .collection('passengerflights')
          .doc(ticketno.text)
          .get();
      if (flightDoc.exists) {
        docId = flightDoc.id;
        DocumentReference flightRef =
            firestore.collection('passengerflights').doc(ticketno.text);
        QuerySnapshot bagsQuery = await flightRef.collection('bags').get();
        setState(() {
          data = bagsQuery.docs;
        });
      } else {
        Fluttertoast.showToast(msg: "Incorrect Ticket or not exists");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Incorrect Ticket or not exists");
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
        title: Text(
          "Qr Generator",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/staffmenu');
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _roundedTextField(
                "Enter Ticket Number",
                Icons.airplane_ticket,
                controller: ticketno,
              ),
              SizedBox(height: 10),
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
                    int itemNumber = index + 1;
                    String description = data[index]['description'];
                    String docid = data[index].id.toString();
                    String qrid = '$docid,$docId';
                    return ListTile(
                      title: Text('Bag $itemNumber: $description'),
                      trailing: IconButton(
                        icon: Icon(Icons.print, color: Colors.blue),
                        onPressed: () {
                          // Generate QR code based on description
                          setState(() {
                            qrData = qrid;
                          });
                          // Show QR code in dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('QR Code'),
                                content: Container(
                                  height: 320,
                                  width: 320,
                                  child: QrImageView(
                                    data: qrData,
                                    version: QrVersions.auto,
                                    size: 320,
                                    gapless: false,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: MenuButton(
                    onPressed: () {
                      if (ticketno.text != "") {
                        getBags();
                      } else {
                        Fluttertoast.showToast(
                            msg: "Please Enter Ticket Number");
                      }
                    },
                    text: 'Get Bags'),
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
}
