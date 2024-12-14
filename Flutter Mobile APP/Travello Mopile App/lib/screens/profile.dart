import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Travello/widget/backfloatingbutton.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isExpanded = false;

  // Add three TextEditingController
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _password = TextEditingController();

  String nametext = "";
  String emailtext = "";

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF01497C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
          ),
        ),
        leading: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(bottom: 5, left: 5),
            child: const CircleAvatar(
              radius: 20.0,
              backgroundImage: AssetImage('images/avatar.png'),
            ),
          ),
        ),
        title: FutureBuilder<String>(
          future: getName(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text(
                snapshot.data!,
                style: const TextStyle(color: Colors.white),
              );
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFF01497C),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _roundedTextField(nametext, Icons.person,
                    controller: _nameController),
                const SizedBox(height: 10),
                _roundedTextField(emailtext, Icons.email,
                    controller: _emailController),
                const SizedBox(height: 10),
                _roundedTextField('Password', Icons.lock,
                    obscureText: true, controller: _password),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/Login');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'SignOut',
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'ADLaMDisplay'),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: BackFButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/menu');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundedTextField(String hintText, IconData icon,
      {bool obscureText = false,
      required TextEditingController controller,
      bool readOnly = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
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
                readOnly: readOnly, // Set the readOnly property here
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

  Future<String> getName() async {
    try {
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('passenger')
          .doc(currentUserUid) // Use current user's UID as document ID
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        nametext = data['username'];
        _nameController.text = nametext;
        return nametext;
      } else {
        // Handle the case where the document doesn't exist
        throw Exception("Document does not exist");
      }
    } catch (e) {
      print("Error: $e");
      // You can choose to return a default value or rethrow the exception
      throw e;
    }
  }

  Future<String> getUserEmail() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        emailtext = currentUser.email!;
        return currentUser.email ??
            ""; // Return user email or an empty string if null
      } else {
        throw Exception("No user is currently signed in.");
      }
    } catch (e) {
      print("Error: $e");
      // You can choose to return a default value or rethrow the exception
      throw e;
    }
  }

  Future<void> initializeData() async {
    try {
      // Run both functions concurrently
      await Future.wait([
        getName(),
        getUserEmail(),
      ]);
      // Both functions completed successfully
      print('Initialization complete');
    } catch (e) {
      print('Initialization error: $e');
    }
  }
}
