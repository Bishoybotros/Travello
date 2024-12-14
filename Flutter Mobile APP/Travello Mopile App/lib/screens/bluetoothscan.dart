// import 'dart:math';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class BluetoothScanner extends StatefulWidget {
  const BluetoothScanner({super.key});

  @override
  _BluetoothScannerState createState() => _BluetoothScannerState();
}

class _BluetoothScannerState extends State<BluetoothScanner> {
  List<String> locations = [
    'Gate 1',
    'Passport F1',
    'Luggage Office',
    'WC F1',
    'Food Court',
    'Security Office F1',
    'Gate 2',
    'Passport F2',
    'Food Court',
    'Security Office F2',
    'Information Office',
    'WC F2'
  ];
  List<ScanResult> scanResultList = [];
  List<FlSpot> spots = [];
  List<Point> trilaterationResults = [];
  List<Map> data = [];
  Timer? _timer;
  Timer? timerL;
  var scanMode = 0;
  var isCalculating = false;
  var isScanning = false;
  final mp = -60.0;
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
  List<FlSpot> wc = [const FlSpot(4.5, 1.5)];
  List<FlSpot> luggage = [const FlSpot(0.5, 1.2)];
  List<FlSpot> spotsLocations = [];
  String locationselected = "";
  double pointX = 0;
  double pointY = 0;
  String imagepath = 'images/airport.png';
  double d1 = 0;
  double d2 = 0;
  double d3 = 0;
  List<FlSpot> luggageToPassport = [
    const FlSpot(0.5, 1.2),
    const FlSpot(1.5, 1.2),
    const FlSpot(1.5, 2.8),
  ];
  List<FlSpot> luggageToGate1 = [
    const FlSpot(0.5, 1.2),
    const FlSpot(1.9, 1.2),
    const FlSpot(1.9, 4),
    const FlSpot(4, 4),
    const FlSpot(4, 4.55)
  ];
  List<FlSpot> luggageToSecurity = [
    const FlSpot(0.5, 1.2),
    const FlSpot(1.9, 1.2),
    const FlSpot(1.9, 4),
    const FlSpot(0.7, 4),
    const FlSpot(0.7, 4.55)
  ];
  List<FlSpot> luggageToWC = [
    const FlSpot(0.5, 1.2),
    const FlSpot(4.5, 1.2),
  ];
  List<FlSpot> wcToPassport = [
    const FlSpot(4.5, 1.2),
    const FlSpot(1.9, 1.2),
    const FlSpot(1.9, 2.8),
  ];
  List<FlSpot> wcToGate1 = [
    const FlSpot(4.5, 1.2),
    const FlSpot(1.9, 1.2),
    const FlSpot(1.9, 4),
    const FlSpot(4, 4),
    const FlSpot(4, 4.55)
  ];
  List<FlSpot> wcToSecurity = [
    const FlSpot(4.5, 1.2),
    const FlSpot(1.9, 1.2),
    const FlSpot(1.9, 4),
    const FlSpot(0.7, 4),
    const FlSpot(0.7, 4.55)
  ];
  List<FlSpot> passportToGate1 = [
    const FlSpot(1.5, 3.25),
    const FlSpot(1.5, 4),
    const FlSpot(4, 4),
    const FlSpot(4, 4.55)
  ];
  List<FlSpot> passportToSecurity = [
    const FlSpot(1.5, 3.25),
    const FlSpot(1.5, 4),
    const FlSpot(0.7, 4),
    const FlSpot(0.7, 4.55)
  ];
  List<FlSpot> securityToGate1 = [
    const FlSpot(0.7, 4.55),
    const FlSpot(0.7, 4),
    const FlSpot(4, 4),
    const FlSpot(4, 4.55)
  ];
  List<FlSpot> route = [];
  List<FlSpot> defaultRoute = [];

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

  @override
  void dispose() {
    if (BluetoothAdapterState.unavailable == false) {
      FlutterBluePlus.stopScan();
    }
    _timer?.cancel();
    timerL?.cancel();
    super.dispose();
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
    var distance = pow(10, ((measuredPower - rssi) / (10 * 2.7))).toDouble();
    return distance;
  }

  /* Get Position */
  Point<double> trilateration(double d1, double d2, double d3) {
    var p1 = const Point<double>(0, 0);
    var p2 = const Point<double>(5, 0);
    var p3 = const Point<double>(0, 5);

    var x = (pow(d1, 2) - pow(d2, 2) + pow(p2.x, 2)) / (2 * p2.x);
    var y =
        ((pow(d1, 2) - pow(d3, 2) + pow(p3.x, 2) + pow(p3.y, 2)) / (2 * p3.y)) - ((p3.x / p3.y) * x);

    return Point(x, y);
  }

  // Point<double> trilateration(double d1, double d2, double d3) {
  //   // Known points in the room
  //   var p1 = const Point<double>(0, 0);
  //   var p2 = const Point<double>(5, 0);
  //   var p3 = const Point<double>(0, 5);

  //   // Calculate the position of the mobile device
  //   var A = 2 * p2.x - 2 * p1.x;
  //   var B = 2 * p2.y - 2 * p1.y;
  //   var C = pow(d1, 2) -
  //       pow(d2, 2) -
  //       pow(p1.x, 2) +
  //       pow(p2.x, 2) -
  //       pow(p1.y, 2) +
  //       pow(p2.y, 2);
  //   var D = 2 * p3.x - 2 * p2.x;
  //   var E = 2 * p3.y - 2 * p2.y;
  //   var F = pow(d2, 2) -
  //       pow(d3, 2) -
  //       pow(p2.x, 2) +
  //       pow(p3.x, 2) -
  //       pow(p2.y, 2) +
  //       pow(p3.y, 2);

  //   var x = (C * E - F * B) / (E * A - B * D);
  //   var y = (C * D - A * F) / (B * D - A * E);

  //   return Point<double>(x, y);
  // }

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

  String? locationRanges(double x, double y) {
    if (x >= 0 && x <= 2 && y >= 0 && y <= 2) {
      return "Luggage";
    } else if (x >= 4 && x <= 5 && y >= 0 && y <= 3) {
      return "WC";
    } else if (x >= 2.5 && x <= 5 && y >= 3.1 && y <= 5) {
      return "Gate 1";
    } else if (x >= 0 && x <= 2.5 && y >= 2.1 && y <= 4) {
      return "Passport";
    } else if (x >= 0 && x <= 2.5 && y >= 4.1 && y <= 5) {
      return "Secuirty Office";
    } else if (x >= 2.5 && x <= 3.9 && y >= 0 && y <= 3) {
      return "Rest Area";
    } else {
      return null;
    }
  }

  List<FlSpot>? getDirection() {
    String? location = locationRanges(pointX, pointY);
    if ((location == "Luggage" && locationselected == "Passport F1") ||
        (location == "Passport" && locationselected == "Luggage Office")) {
      return luggageToPassport;
    } else if ((location == "Luggage" && locationselected == "Gate 1") ||
        (location == "Gate 1" && locationselected == "Luggage Office")) {
      return luggageToGate1;
    } else if ((location == "Luggage" && locationselected == "WC F1") ||
        (location == "WC" && locationselected == "Luggage Office")) {
      return luggageToWC;
    } else if ((location == "Luggage" &&
            locationselected == "Security Office") ||
        (location == "Security Office" &&
            locationselected == "Luggage Office")) {
      return luggageToSecurity;
    } else if ((location == "WC" && locationselected == "Passport F1") ||
        (location == "Passport" && locationselected == "WC F1")) {
      return wcToPassport;
    } else if ((location == "WC" && locationselected == "Gate 1") ||
        (location == "Gate 1" && locationselected == "WC F1")) {
      return wcToGate1;
    } else if ((location == "WC" && locationselected == "Security Office") ||
        (location == "Security Office" && locationselected == "WC F1")) {
      return wcToSecurity;
    } else if ((location == "Passport" && locationselected == "Gate 1") ||
        (location == "Gate 1" && locationselected == "Passport F1")) {
      return passportToGate1;
    } else if ((location == "Passport" &&
            locationselected == "Security Office") ||
        (location == "Security Office" && locationselected == "Passport F1")) {
      return passportToSecurity;
    } else if ((location == "Security Office" &&
            locationselected == "Gate 1") ||
        (location == "Gate 1" && locationselected == "Security Office")) {
      return securityToGate1;
    } else {
      return defaultRoute;
    }
  }

  Future<void> setLocation() async {
    timerL = Timer.periodic(const Duration(seconds: 20), (timer) async {
      try {
        if (spots.isNotEmpty) {
          String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
          await FirebaseFirestore.instance
              .collection('passenger')
              .doc(currentUserUid)
              .update({
            "currentlocation": locationRanges(pointX, pointY),
            "x":pointX,
            "y":pointY
          });
          DateTime time = DateTime.now();
          String timestamp = DateFormat('dd/MM/yyyy hh:mm a').format(time);
          await FirebaseFirestore.instance
              .collection('passenger')
              .doc(currentUserUid)
              .collection('locations')
              .doc()
              .set({
            "location": locationRanges(pointX, pointY),
            "time": timestamp,
            "x":pointX,
            "y":pointY
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
        setState(() {
          double d1 = double.parse(
              calculateDistance(mp, r.rssi.toDouble()).toStringAsFixed(2));
          // myController1.text = r.rssi.toString();
          myController1.text = d1.toString();
        });
      }

      if (r.device.remoteId.str == '40:22:D8:77:26:E6') {
        // double d2 = calculateDistance(mp, r.rssi.toDouble());

        setState(() {
          double d2 = double.parse(
              calculateDistance(mp, r.rssi.toDouble()).toStringAsFixed(2));
          myController2.text = d2.toString();
        });
        // myController2.text = r.rssi.toString();
      }

      if (r.device.remoteId.str == 'A0:B7:65:61:74:2A') {
        // double d3 = calculateDistance(mp, r.rssi.toDouble());
        setState(() {
          double d3 = double.parse(
              calculateDistance(mp, r.rssi.toDouble()).toStringAsFixed(2));
          myController3.text = d3.toString();
        });
        // myController3.text = r.rssi.toString();
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
        Point p = trilateration(d1, d2, d3);
        if (p.x.toDouble() <= 5 &&
            p.x.toDouble() >= 0 &&
            p.y.toDouble() <= 5 &&
            p.y.toDouble() >= 0) {
          setState(() {
            spots.clear();
            spots.add(FlSpot(p.x.toDouble(), p.y.toDouble()));
            pointX = p.x.toDouble();
            pointY = p.y.toDouble();
          });
        }
        myController4.text = p.x.toStringAsFixed(2);
        myController5.text = p.y.toStringAsFixed(2);
        double x = p.x.toDouble();
        double y = p.y.toDouble();
        // Store the data in the list of lists
        // List<double> dataPoint = [d1, d2, d3, x, y];
        // dataPointsList.add(dataPoint);
        // for (List<double> records in dataPointsList) {
        //   for (double value in records) {
        //     print(value);
        //   }
        //   print('---');
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

  void navigationSwitch(String value) {
    switch (value) {
      case 'Gate 1':
        setState(() {
          spotsLocations.clear();
          spotsLocations.add(const FlSpot(4, 4.52));
          imagepath = 'images/airport.png';
        });
        break;
      case 'Passport F1':
        setState(() {
          spotsLocations.clear();
          spotsLocations.add(const FlSpot(1.5, 2.79));
          imagepath = 'images/airport.png';
        });
        break;
      case 'Luggage Office':
        setState(() {
          spotsLocations.clear();
          spotsLocations.add(const FlSpot(0.5, 1.2));
          imagepath = 'images/airport.png';
        });
        break;
      case 'WC F1':
        setState(() {
          spotsLocations.clear();
          spotsLocations.add(const FlSpot(4.5, 1.2));
          imagepath = 'images/airport.png';
        });
        break;

      case 'Security Office F1':
        setState(() {
          spotsLocations.clear();
          spotsLocations.add(const FlSpot(0.7, 4.52));
          imagepath = 'images/airport.png';
        });
        
      case 'Gate 2':
        setState(() {
          spotsLocations.clear();
          spotsLocations.add(const FlSpot(4, 4.52));
          imagepath = 'images/airport2.png';
        });
        break;
      case 'Passport F2':
        setState(() {
          spotsLocations.clear();
          spotsLocations.add(const FlSpot(1.5, 2.79));
          imagepath = 'images/airport2.png';
        });
        break;
      case 'Food Court':
        setState(() {
          spotsLocations.clear();
          spotsLocations.add(const FlSpot(0.7, 1.2));
          imagepath = 'images/airport2.png';
        });
        break;
      case 'Security Office F2':
        setState(() {
          spotsLocations.clear();
          spotsLocations.add(const FlSpot(0.7, 4.52));
          imagepath = 'images/airport2.png';
        });
        break;

      case 'Information Office':
        setState(() {
          spotsLocations.clear();
          spotsLocations.add(const FlSpot(3.5, 0.6));
          imagepath = 'images/airport2.png';
        });
      case 'WC F2':
        setState(() {
          spotsLocations.clear();
          spotsLocations.add(const FlSpot(4.5, 1.2));
          imagepath = 'images/airport2.png';
        });
        break;
    }
  }

  /* UI */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'ADLaMDisplay')),
        backgroundColor: const Color(0xFF01497C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                imagepath), // Replace 'your_image_path_here.jpg' with your image path
            fit: BoxFit.fill,
          ),
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              horizontalInterval: 0.5,
              verticalInterval: 0.5,
              drawVerticalLine: true,
              drawHorizontalLine: true,
              checkToShowHorizontalLine: (value) => true,
              checkToShowVerticalLine: (value) => true,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.blue,
                  strokeWidth: 0.2,
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Colors.blue,
                  strokeWidth: 0.2,
                );
              },
            ),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: 5,
            minY: 0,
            maxY: 5,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                color: Colors.blue,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: route,
                isCurved: false,
                color: Colors.green, // Adjust color as needed
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: spotsLocations,
                isCurved: false,
                color: Colors.red,
                barWidth: 3,
                belowBarData: BarAreaData(show: false),
                isStrokeCapRound: true,
                preventCurveOverShooting: true,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 20,
            left: 15,
            child: FloatingActionButton(
              heroTag: UniqueKey(),
              onPressed: () {
                if (BluetoothAdapterState.unavailable != true) {
                  toggleState();
                  calculaterealtimedist();
                } else {
                  Fluttertoast.showToast(msg: "Please Enable Bluetooth");
                }
              },
              child: const Icon(Icons.navigation),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 45,
            child: FloatingActionButton(
              heroTag: UniqueKey(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFF01497C),
                      content: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.only(top: 20),
                                child: Text(
                                  'Where to',
                                  style: TextStyle(
                                      color: Colors.orange[300],
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'ADLaMDisplay'),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: locations.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            // print('Location selected: ${locations[index]}');
                                            locationselected = locations[index];
                                            navigationSwitch(locationselected);
                                            if (pointX != 0 && pointY != 0) {
                                              route = getDirection()!;
                                            }
                                          },
                                          child: ListTile(
                                            title: Text(
                                              locations[index],
                                              style: const TextStyle(
                                                color: Colors
                                                    .white, // Change color here
                                                fontSize: 18,
                                                fontFamily: 'ADLaMDisplay',
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Add a Divider with an incomplete line
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          height: 1.0,
                                          color: Colors.white.withOpacity(
                                              0.4), // Adjust opacity and color here
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Icon(Icons.place),
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: myController1,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: myController2,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: myController3,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: myController4,
                readOnly: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: myController5,
                readOnly: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
