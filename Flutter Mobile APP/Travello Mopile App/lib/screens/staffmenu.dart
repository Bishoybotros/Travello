import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:Travello/widget/menubuttons.dart';
import 'package:Travello/widget/staffmenubuttons.dart';

class StaffMenu extends StatefulWidget {
  const StaffMenu({Key? key}) : super(key: key);

  @override
  _StaffMenuState createState() => _StaffMenuState();
}

class _StaffMenuState extends State<StaffMenu> {
  @override
  void initState() {
    super.initState();
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
        title: const Text("Staff", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/Login');
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 10, top: 30, right: 10),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 220,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          children: [
            SMenuButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/qrgen');
              },
              buttonText: "Qr Generator",
              iconData: Icons.qr_code,
            ),
            SMenuButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/staffscanner');
              },
              buttonText: "Bag Scanning",
              iconData: Icons.luggage,
            ),
            SMenuButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/agent');
              },
              buttonText: "Support",
              iconData: Icons.support_agent_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
