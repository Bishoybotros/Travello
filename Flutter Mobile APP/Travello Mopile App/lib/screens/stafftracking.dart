// import 'dart:math';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class StaffTracking extends StatefulWidget {
  const StaffTracking({super.key});

  @override
  _StaffTrackingState createState() => _StaffTrackingState();
}

class _StaffTrackingState extends State<StaffTracking> {
  List<ScanResult> scanResultList = [];
  List<FlSpot> spots = [];
  List<Point> trilaterationResults = [];
  List<Map> data = [];
  Timer? _timer;
  var scanMode = 0;
  var isCalculating = false;
  var isScanning = false;
  final mp = -65.0;
  final List<String> macAddressesToTrack = [
    '40:22:D8:77:2E:26',
    '40:22:D8:77:26:E6',
    'A0:B7:65:61:74:2A'
  ];
  var myController1 = TextEditingController();
  var myController2 = TextEditingController();
  var myController3 = TextEditingController();
  var myController4 = TextEditingController();
  var myController5 = TextEditingController();
  List<List<double>> dataPointsList = [];


  @override
  void initState() {
    setLocation();
    super.initState();
    // Listen to scan results in the initState method
    FlutterBluePlus.scanResults.listen((results) {
      // Sort the list by RSSI
      results.sort((a, b) => b.rssi.compareTo(a.rssi));

      // Update state
      if (isScanning) {
        setState(() {
          scanResultList = results;
        });
      }
    });
  }

  /* Start, Stop */
  void toggleState() {
    isScanning = !isScanning;

    if (isScanning) {
      print("Start Scan");
      FlutterBluePlus.startScan(
          continuousUpdates: true,
          androidScanMode: const AndroidScanMode(0),
          androidUsesFineLocation: true);
    } else {
      print("Stop Scan");
      FlutterBluePlus.stopScan();
    }

    setState(() {});
  }

  /* Scan Mode */
  void scan() async {
    // Remove the FlutterBluePlus.scanResults.listen from here
    // This method is only used to clear the existing list.
    if (isScanning) {
      // Clear the existing list of scan results
      scanResultList.clear();
    }
  }

  /* device TxPower */
  Widget deviceTX(ScanResult r) {
    return Text('Tx: ${r.advertisementData.txPowerLevel.toString()}');
  }

  /* device RSSI */
  Widget deviceSignal(ScanResult r) {
    return Text(r.rssi.toString());
  }

  /* device MAC address */
  Widget deviceMacAddress(ScanResult r) {
    return Text(r.device.remoteId.str);
  }

  /* device name */
  Widget deviceName(ScanResult r) {
    String name;

    if (r.device.platformName.isNotEmpty) {
      name = r.device.platformName;
    } else if (r.advertisementData.advName.isNotEmpty) {
      name = r.advertisementData.advName;
    } else {
      name = 'N/A';
    }
    return Text(name);
  }

  /* Calculate Distance */
  double calculateDistance(double measuredPower, double rssi) {
    var distance = pow(10, ((measuredPower - rssi) / (10 * 3))).toDouble();
    return distance;
  }

  // /* Get Position */
  // Point<double> trilateration(double d1, double d2, double d3) {
  //   // Known points in the room
  //   // ignore: unused_local_variable
  //   var p1 = const Point<double>(0, 0);
  //   var p2 = const Point<double>(3, 0);
  //   var p3 = const Point<double>(0, 3);

  //   // Calculate the position of the mobile device
  //   var x = (pow(d1, 2) - pow(d2, 2) + pow(p2.x, 2)) / (2 * p2.x);
  //   var y =
  //       ((pow(d1, 2) - pow(d3, 2) + pow(p3.x, 2) + pow(p3.y, 2)) / (2 * p3.y)) -
  //           ((p3.x / p3.y) * x);

  //   return Point(x, y);
  // }

  Point<double> trilateration(double d1, double d2, double d3) {
    // Known points in the room
    var p1 = const Point<double>(0, 0);
    var p2 = const Point<double>(3, 0);
    var p3 = const Point<double>(0, 3);

    // Calculate the position of the mobile device
    var A = 2 * p2.x - 2 * p1.x;
    var B = 2 * p2.y - 2 * p1.y;
    var C = pow(d1, 2) -
        pow(d2, 2) -
        pow(p1.x, 2) +
        pow(p2.x, 2) -
        pow(p1.y, 2) +
        pow(p2.y, 2);
    var D = 2 * p3.x - 2 * p2.x;
    var E = 2 * p3.y - 2 * p2.y;
    var F = pow(d2, 2) -
        pow(d3, 2) -
        pow(p2.x, 2) +
        pow(p3.x, 2) -
        pow(p2.y, 2) +
        pow(p3.y, 2);

    var x = (C * E - F * B) / (E * A - B * D);
    var y = (C * D - A * F) / (B * D - A * E);

    return Point(x, y);
  }

  /* BLE icon widget */
  Widget leading(ScanResult r) {
    return const CircleAvatar(
      backgroundColor: Colors.cyan,
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
    );
  }

  void onTap(ScanResult r) {
    if (r.device.remoteId.str == '40:22:D8:77:2E:26') {
      // Check if the device is still in the list of scan results
      if (scanResultList.contains(r)) {
        // Update the text controller with the latest RSSI value
        double d1 = calculateDistance(mp, r.rssi.toDouble());
        myController1.text = d1.toString();
      } else {}
    }
  }

  Future<void> setLocation() async {
    Timer.periodic(Duration(seconds: 10), (timer) async {
      try {
        if (spots.isNotEmpty) {
          String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
          await FirebaseFirestore.instance
              .collection('staff')
              .doc(currentUserUid)
              .update({
            "currentlocation": spots,
          });
          DateTime time = DateTime.now();
          String timestamp = DateFormat('dd/MM/yyyy hh:mm a').format(time);
          await FirebaseFirestore.instance
              .collection('staff')
              .doc(currentUserUid)
              .collection('location')
              .doc()
              .set({
            timestamp: spots,
          }, SetOptions(merge: true));
          print("Document updated successfully!");
        }
      } catch (e) {
        print("Error: $e");
      }
    });
  }

  void ss(ScanResult r) {
    if (scanResultList.contains(r)) {
      if (r.device.remoteId.str == '40:22:D8:77:2E:26') {
        double d1 = calculateDistance(mp, r.rssi.toDouble());
        double d1near = double.parse(d1.toStringAsFixed(2));
        // myController1.text = r.rssi.toString();
        myController1.text = d1near.toString();
      }

      if (r.device.remoteId.str == '40:22:D8:77:26:E6') {
        double d2 = calculateDistance(mp, r.rssi.toDouble());
        double d2near = double.parse(d2.toStringAsFixed(2));
        // myController2.text = r.rssi.toString();
        myController2.text = d2near.toString();
      }

      if (r.device.remoteId.str == 'A0:B7:65:61:74:2A') {
        double d3 = calculateDistance(mp, r.rssi.toDouble());
        double d3near = double.parse(d3.toStringAsFixed(2));
        // myController3.text = r.rssi.toString();
        myController3.text = d3near.toString();
      }

      if (myController1.text.isNotEmpty &&
          myController2.text.isNotEmpty &&
          myController3.text.isNotEmpty) {
        double d1 = double.parse(myController1.text);
        double d1near = double.parse(d1.toStringAsFixed(2));
        double d2 = double.parse(myController2.text);
        double d2near = double.parse(d2.toStringAsFixed(2));
        double d3 = double.parse(myController3.text);
        double d3near = double.parse(d3.toStringAsFixed(2));

        Point p = trilateration(d1near, d2near, d3near);
        if (p.x.toDouble() <= 5 &&
            p.x.toDouble() >= 0 &&
            p.y.toDouble() <= 5 &&
            p.y.toDouble() >= 0) {
          setState(() {
            spots.clear();
            spots.add(FlSpot(p.x.toDouble(), p.y.toDouble()));
            setLocation();
          });
        }
        myController4.text = p.x.toStringAsFixed(2);
        myController5.text = p.y.toStringAsFixed(2);
        double x = p.x.toDouble();
        double y = p.y.toDouble();
        // Store the data in the list of lists
        List<double> dataPoint = [d1near, d2near, d3near, x, y];
        dataPointsList.add(dataPoint);
        for (List<double> records in dataPointsList) {
          for (double value in records) {
            print(value);
          }
          print('---');
        }
      }
    }
  }

  void calculaterealtimedist() {
    if (!isCalculating) {
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (scanResultList.isNotEmpty) {
          for (ScanResult scanResult in scanResultList) {
            ss(scanResult);
          }
        }
      });
      isCalculating = true;
    } else {
      _timer?.cancel();
      isCalculating = false;
    }
  }

  /* ble item widget */
  Widget? listItem(ScanResult r) {
    // List of MAC addresses you want to display
    var allowedMacAddresses = [
      '40:22:D8:77:2E:26',
      '40:22:D8:77:26:E6',
      'A0:B7:65:61:74:2A'
    ];

    // Check if the MAC address is in the allowed list
    if (allowedMacAddresses.contains(r.device.remoteId.str)) {
      return ListTile(
        onTap: () => onTap(r),
        leading: leading(r),
        title: deviceName(r),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            deviceMacAddress(r),
            deviceTX(r),
          ],
        ),
        trailing: deviceSignal(r),
      );
    } else {
      // If the MAC address is not in the allowed list, return null to neglect the device
      return Container();
    }
  }

  /* UI */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Beacons',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF01497C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
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
            ), // Change the icon as needed
          ),
        ],
      ),
    );
  }
}
