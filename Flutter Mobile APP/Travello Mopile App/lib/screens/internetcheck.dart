import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InternetCheck {
  static bool isDialogShown = false;

  Future<bool> checkInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void checkConnection(BuildContext context) async {
    const Duration checkInterval = Duration(seconds: 3);
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      print("Connected to the Internet");
    } else {
      print("No Internet Connection");
      if (!isDialogShown) {
        isDialogShown = true;
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
                          'No Internet Connection.',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ADLaMDisplay'),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [          
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
                                  'Retry',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'ADLaMDisplay'),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  isDialogShown = false;
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
    }
    Future.delayed(checkInterval, () => checkConnection(context));
  }
}
