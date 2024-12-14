import 'dart:collection';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Travello/apis/access_token.dart';
import 'package:Travello/screens/newbag.dart';
import 'package:Travello/widget/staffmenubuttons.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class StaffScanner extends StatefulWidget {
  const StaffScanner({Key? key}) : super(key: key);

  @override
  _StaffScannerState createState() => _StaffScannerState();
}

class _StaffScannerState extends State<StaffScanner> {
  String? _selectedItem; // variable to store selected item in dropdown
  String? _scanResult;
  String? partOne;
  String? partTwo;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> setLocation() async {
    try {
      if (_selectedItem != null &&
          _scanResult != null &&
          partOne != null &&
          partTwo != null) {
        DocumentReference partTwoDocRef = firestore
            .collection('passengerflights')
            .doc(partTwo)
            .collection('bags')
            .doc(partOne);

        DateTime now = DateTime.now();
        String timestamp = DateFormat('dd/MM/yyyy hh:mm a').format(now);

        // Updating the document
        await partTwoDocRef.collection('status').doc().set({
          "location": _selectedItem,
          "time":timestamp
        }, SetOptions(merge: true));

        // Fetching passengerId
        DocumentSnapshot partTwoDoc =
            await firestore.collection('passengerflights').doc(partTwo).get();
        String passengerId =
            (partTwoDoc.data() as Map<String, dynamic>)['passengerid'];
        print(passengerId);

        // Fetching bag description
        DocumentSnapshot partOneDoc = await firestore
            .collection('passengerflights')
            .doc(partTwo)
            .collection('bags')
            .doc(partOne)
            .get();
        String bagDescription =
            (partOneDoc.data() as Map<String, dynamic>)['description'];
         
        String deviceToken= await getToken(passengerId);
        print(deviceToken);

        AccessToken accessToken = AccessToken();
        String token = await accessToken.getaccesstoken();
        print(token);
        // Constructing notification content
        String notificationTitle = 'Luggage Scanned';
        String notificationContent =
            'Luggage: $bagDescription scanned at $_selectedItem';

        // Sending notification
        await sendNotification(
            token, deviceToken, notificationTitle,notificationContent);

        print('Location set successfully!');
      } else {
        print(
            'Error: _selectedItem, _scanResult, partOne, or partTwo is null.');
      }
    } catch (e) {
      print('Error setting location: $e');
    }
  }

  Future<void> sendNotification(
      String accessToken, String deviceToken, String title, String message) async {
    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/travello-2ed88/messages:send');
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": title,
          "body": message,
        },
      },
    };

    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }

   Future<String> getToken(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('passenger')
          .doc(uid)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        final token = data['token'];
        return token;
      } else {
        throw Exception("Document does not exist");
      }
    } catch (e) {
      print("Error: $e");
      throw e;
    }
  }

  Future<void> scanCode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ffffff", "cancel", true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = "Failed";
    }
    setState(() {
      _scanResult = barcodeScanRes;
    });
    List<String> parts = barcodeScanRes.split(',');
    partOne = parts.isNotEmpty ? parts[0] : '';
    partTwo = parts.length > 1 ? parts[1] : '';
    setLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF01497C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        title: const Text("Bag Scanner", style: TextStyle(color: Colors.white,)),
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
      body: Column(
        children: [
          // Dropdown list
          Container(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedItem,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItem = newValue;
                });
              },
              items: <String>[
                'Security Checking',
                'Sorting Area',
                'Loading Area',
                
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Select Area',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Center(
            child: Container(
              alignment: Alignment.center,
              child: SMenuButton(
                onPressed: () {
                  scanCode();
                },
                buttonText: "SCAN",
                iconData: Icons.qr_code, // No icon provided
              ),
            ),
          ),
        ],
      ),
    );
  }
}
