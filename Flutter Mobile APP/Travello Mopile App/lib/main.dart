import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:Travello/screens/Splash.dart';
import 'package:Travello/screens/Welcome1.dart';
import 'package:Travello/screens/Welcome2.dart';
import 'package:Travello/screens/Welcome3.dart';
import 'package:Travello/screens/BluetoothScan.dart';
import 'package:Travello/screens/Register.dart';
import 'package:Travello/screens/Login.dart';
import 'package:Travello/screens/Verification.dart';
import 'package:Travello/screens/Menu.dart';
import 'package:Travello/screens/agentchat.dart';
import 'package:Travello/screens/baggage.dart';
import 'package:Travello/screens/bagqrgen.dart';
import 'package:Travello/screens/bluetoothcheck.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Travello/screens/securitytracking.dart';
import 'package:Travello/screens/userchat.dart';
import 'package:Travello/screens/findff.dart';
import 'package:Travello/screens/profile.dart';
import 'package:Travello/screens/staffmenu.dart';
import 'package:Travello/screens/staffscanner.dart';
import 'package:Travello/screens/internetcheck.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyAs5pu-La60fsbgpDu2ZVHWbElLnGMfjcw',
            appId: '1:930623352397:android:9c7e34b734d40440123604',
            messagingSenderId: '930623352397',
            projectId: 'travello-2ed88'));
  } else if (Platform.isWindows) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: "AIzaSyAeQZJnBJk2PBBC-GCd36vgMgNyFxlvSHo",
      authDomain: "travello-2ed88.firebaseapp.com",
      databaseURL: "https://travello-2ed88-default-rtdb.firebaseio.com",
      projectId: "travello-2ed88",
      storageBucket: "travello-2ed88.appspot.com",
      messagingSenderId: "930623352397",
      appId: "1:930623352397:web:80f8196bb14f8623123604",
    ));
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothCheck bluetoothCheck = BluetoothCheck();
  final _firebasemessaging = FirebaseMessaging.instance;
  InternetCheck internetCheck = InternetCheck();

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('user is currently signed out!');
      } else {
        print('user signed in');
        if (!Platform.isWindows) {
          getToken();
        }
      }
    });

    super.initState();
    if (Platform.isAndroid) {
      BluetoothCheck.startBluetoothCheck(context);
    }
    internetCheck.checkConnection(context);
  }

  Future<void> getToken() async {
    String? token = await _firebasemessaging.getToken();
    try {
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('passenger')
          .doc(currentUserUid)
          .update({
        "token": token,
      });
      print("Document added successfully!");
      print(token);
    } catch (e) {
      print("Error: $e");
    }
  }

  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();

    if (statuses[Permission.bluetooth]!.isGranted &&
        statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted &&
        statuses[Permission.location]!.isGranted) {
      // All required permissions are granted
    } else {
      // ignore: use_build_context_synchronously
      BluetoothCheck.startBluetoothCheck(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const Splash(),
        '/welcome1': (context) => const Welcome1(),
        '/welcome2': (context) => const Welcome2(),
        '/welcome3': (context) => const Welcome3(),
        '/bluetooth': (context) => const BluetoothScanner(),
        '/Register': (context) => RegistrationScreen(),
        '/Login': (context) => LoginScreen(),
        '/Verification': (context) => Verification(),
        '/menu': (context) => const MenuScreen(),
        '/Profile': (context) => const Profile(),
        '/baggage': (context) => const Baggage(),
        '/qrgen': (context) => const QRGen(),
        '/staffmenu': (context) => const StaffMenu(),
        '/staffscanner': (context) => const StaffScanner(),
        '/guestscreen': (context) => GuestSrceen(),
        '/client': (context) => const ClientScreen(),
        '/agent': (context) => const AgentScreen(),
        '/securitytracking': (context) => const SecurityTracking(),
      },
    );
  }
}
