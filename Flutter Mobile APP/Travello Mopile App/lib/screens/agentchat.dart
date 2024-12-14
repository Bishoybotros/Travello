import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  _AgentScreenState createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  final TextEditingController messageController = TextEditingController();
  final List<Map<String, String>> clientMessages = [];
  final List<Map<String, String>> agentMessages = [];
  List<String> docIds = [];
  List<String> usernames = [];
  final ScrollController _scrollController = ScrollController();
  String docId = "";
  late Timer timer;

  // Added variable to store selected index
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _getUsernames();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) => _getUsernames());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> sendMessage() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DateTime now = DateTime.now();
      String timestamp = DateFormat('dd/MM/yyyy hh:mm:ss.SSS a').format(now);
      DocumentReference agentMessagesRef = firestore
          .collection('messages')
          .doc(docId)
          .collection('agent')
          .doc('$docId a');
      await agentMessagesRef.set({
        timestamp: messageController.text,
      }, SetOptions(merge: true));
      messageController.clear();
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Please select chat first");
    }
  }

  Future<List<String>> _getUsernames() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('messages').get();

      if (querySnapshot.docs.isEmpty) {
        print('No documents found in the "messages" collection.');
      } else {
        for (var doc in querySnapshot.docs) {
          String doci = doc.id;
          if (!docIds.contains(doci)) {
            docIds.add(doc.id);
          }
        }

        for (var docId in docIds) {
          DocumentSnapshot docSnapshot =
              await _firestore.collection('passenger').doc(docId).get();
          if (docSnapshot.exists) {
            var data = docSnapshot.data() as Map<String, dynamic>;
            if (data.containsKey('username')) {
              String user = data['username'];
              if (!usernames.contains(user)) {
                usernames.add(data['username']);
              }
            }
          }
        }
        setState(() {});
      }
    } catch (e) {
      print('Error getting document IDs or usernames: $e');
    }
    return usernames;
  }

  void fetchMessages(String docId) {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      firestore
          .collection('messages')
          .doc(docId)
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

      firestore
          .collection('messages')
          .doc(docId)
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

  Future<String> getDocIdByUsername(String username) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection('passenger')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      docId = querySnapshot.docs.first.id;
    } else {
      Fluttertoast.showToast(msg: "not found");
    }
    return docId;
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
        titleTextStyle:
            const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/staffmenu');
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.35,
            color: Colors.grey[300],
            child: ListView.separated(
              itemCount: usernames.length,
              separatorBuilder: (context, index) => Divider(color: Colors.grey),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    usernames[index],
                    style: TextStyle(
                      fontFamily: 'ADLaMDisplay',
                      color:
                          index == selectedIndex ? Colors.blue : Colors.black,
                    ),
                  ),
                  onTap: () async {
                    String selectedDocId =
                        await getDocIdByUsername(usernames[index]);
                    setState(() {
                      docId = selectedDocId;
                      selectedIndex = index;
                    });
                    fetchMessages(docId);
                  },
                );
              },
            ),
          ),
          // Chat area
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: clientMessages.length + agentMessages.length,
                    itemBuilder: (context, index) {
                      List<Map<String, String>> allMessages = [
                        ...clientMessages,
                        ...agentMessages
                      ];
                      allMessages
                          .sort((a, b) => a.keys.first.compareTo(b.keys.first));

                      bool isClientMessage = clientMessages
                          .map((msg) => msg.keys.first)
                          .contains(allMessages[index].keys.first);

                      return Container(
                        alignment: isClientMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
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
          ),
        ],
      ),
    );
  }
}
