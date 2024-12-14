import 'package:flutter/material.dart';
import 'package:Travello/widget/nextfloatingbutton.dart';
import 'package:Travello/widget/introscreens.dart';
import 'package:Travello/widget/roundedrectangle.dart';

class Welcome2 extends StatefulWidget {
  const Welcome2({Key? key}) : super(key: key);

  @override
  State<Welcome2> createState() => _Welcome2State();
}

class _Welcome2State extends State<Welcome2> {
  Color SecondRec = Colors.red; // Change variable name to camelCase

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: content(),
        ),
      ),
    );
  }

  Widget content() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(top: 10.0),
                child: Transform.scale(
                  scale: 0.7,
                  child: Image.asset('images/People.png'),
                ),
              ),
              const CustomTextWidget(
                text: 'Locate Friends &\nFamily Instantly',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                margin: EdgeInsets.only(left: 10.0, top: 10),
              ),
              const CustomTextWidget(
                text: 'Connect Effortlessly at\nEvery Step',
                color: Color(0xFF848897),
                fontSize: 20,
                fontWeight: FontWeight.normal,
                letterSpacing: 1,
                margin: EdgeInsets.only(left: 10.0),
              ),
            ],
          ),
        ),
        // Positioned widget for the floating button
        Positioned(
          bottom: 20,
          right: 20,
          child: NextFButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/welcome3');
              setState(() {
                SecondRec = const Color(0xFFFFC7C7);
              });
            },
          ),
        ),
        // Positioned widget for rectangles
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First additional rectangle
              RoundedRectangle(
                color: const Color(0xFFFFC7C7),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/welcome1'),
              ),
              SizedBox(width: 2), // Adjust spacing as needed

              // Second additional rectangle
              RoundedRectangle(
                color: SecondRec,
              ),
              SizedBox(width: 2), // Adjust spacing as needed

              // Third additional rectangle
              RoundedRectangle(
                color: const Color(0xFFFFC7C7),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/welcome3'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
