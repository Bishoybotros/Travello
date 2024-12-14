import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:url_launcher/url_launcher.dart';

class BluetoothCheck {
  static bool isDialogShown = false;
  static void startBluetoothCheck(BuildContext context) {
    checkBluetoothPermission();
    _checkBluetooth(context);
  }

  static void checkBluetoothPermission() async {
    if (Platform.isAndroid) {
      // On Android, check and request location permission
      var status = await Permission.bluetooth.request();
      if (status != PermissionStatus.granted) {
        // Handle the case where the user did not grant permission
        // You can show a dialog or UI to inform the user
        // and handle the situation accordingly.
      }
    }
  }

  static void _checkBluetooth(BuildContext context) async {
    const Duration checkInterval = Duration(seconds: 3);

    final BluetoothAdapterState state =
        await FlutterBluePlus.adapterState.first;

    if (!isDialogShown &&
        (state == BluetoothAdapterState.off ||
            state == BluetoothAdapterState.unknown ||
            state == BluetoothAdapterState.unavailable)) {
      isDialogShown = true;

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
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
                        'Bluetooth is turned off.\nTurn on Bluetooth to use the app.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ADLaMDisplay'),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF61A5C2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'ADLaMDisplay'),
                              ),
                              onPressed: () {
                                SystemNavigator.pop();
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF61A5C2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'ADLaMDisplay'),
                              ),
                              onPressed: () async {
                                final BluetoothAdapterState state1 =
                                    await FlutterBluePlus.adapterState.first;
                                if (state1 == BluetoothAdapterState.off ||
                                    state1 ==
                                        BluetoothAdapterState.unavailable ||
                                    state1 == BluetoothAdapterState.unknown) {
                                  Fluttertoast.showToast(
                                      msg: 'Please Enable Bluetooth');
                                } else {
                                  Navigator.pop(context);
                                  isDialogShown = false;
                                }
                              },
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
    }
    Future.delayed(checkInterval, () => _checkBluetooth(context));
  }
}
