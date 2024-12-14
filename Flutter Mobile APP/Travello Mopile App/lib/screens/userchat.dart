import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final TextEditingController messageController = TextEditingController();
  final List<Map<String, String>> clientMessages = [];
  final List<Map<String, String>> agentMessages = [];
  List<Map<String, String>> allMessages = [];
  final ScrollController _scrollController = ScrollController();
  late StreamSubscription clientMessagesSubscription;
  late StreamSubscription agentMessagesSubscription;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  @override
  void dispose() {
    clientMessagesSubscription.cancel();
    agentMessagesSubscription.cancel();
    super.dispose();
  }

  Future<void> sendMessage() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      DateTime now = DateTime.now();
      String timestamp = DateFormat('dd/MM/yyyy hh:mm:ss.SSS a').format(now);
      DocumentReference clientMessagesRef = firestore
          .collection('messages')
          .doc(currentUserUid)
          .collection('client')
          .doc('$currentUserUid c');
      await clientMessagesRef.set({
        timestamp: messageController.text,
      }, SetOptions(merge: true));

      DocumentReference clientAttribute =
          firestore.collection('messages').doc(currentUserUid);
      await clientAttribute.set({"date": timestamp});
      messageController.clear();
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "An error occurred, please try again");
    }
  }

  void fetchMessages() {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch client messages
      clientMessagesSubscription = firestore
          .collection('messages')
          .doc(currentUserUid)
          .collection('client')
          .snapshots()
          .listen((snapshot) {
        if (!mounted) return;
        setState(() {
          clientMessages.clear();
          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data();
            data.forEach((key, value) {
              clientMessages.add({key: value});
            });
          }
        });
      });

      // Fetch agent messages
      agentMessagesSubscription = firestore
          .collection('messages')
          .doc(currentUserUid)
          .collection('agent')
          .snapshots()
          .listen((snapshot) {
        if (!mounted) return;
        setState(() {
          agentMessages.clear();
          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data();
            data.forEach((key, value) {
              agentMessages.add({key: value});
            });
          }
        });
      });
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "An error occurred, please try again");
    }
  }

  Widget _roundedTextField(
      {TextEditingController? controller, required String hintText}) {
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
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    allMessages = [...clientMessages, ...agentMessages];
    allMessages.sort((a, b) => a.keys.first.compareTo(b.keys.first));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        title: const Text('Support'),
        titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'ADLaMDisplay'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/menu');
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: allMessages.length,
              itemBuilder: (context, index) {
                bool isClientMessage = clientMessages
                    .map((msg) => msg.keys.first)
                    .contains(allMessages[index].keys.first);

                return Container(
                  alignment: isClientMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isClientMessage ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      allMessages[index].values.first,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: _roundedTextField(
                    hintText: 'Type your message',
                    controller: messageController,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green[700]),
                  onPressed: () {
                    if (messageController.text != "") {
                      sendMessage();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
