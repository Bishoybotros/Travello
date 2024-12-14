import 'package:flutter/material.dart';
import 'package:Travello/widget/nextfloatingbutton.dart';
import 'package:Travello/widget/introscreens.dart';
import 'package:Travello/widget/roundedrectangle.dart';

class Welcome1 extends StatefulWidget {
  const Welcome1({Key? key}) : super(key: key);

  @override
  State<Welcome1> createState() => _Welcome1State();
}

class _Welcome1State extends State<Welcome1> {
  Color firstRec = Colors.red;

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
                  child: Image.asset('images/Plane.png'),
                ),
              ),
              const CustomTextWidget(
                text: 'Navigate airports\nwith ease',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                margin: EdgeInsets.only(left: 10.0, top: 10),
              ),
              const CustomTextWidget(
                text: 'Real-time guidance for\nstress-free travel!',
                color: Color(0xFF848897),
                fontSize: 20,
                fontWeight: FontWeight.normal,
                letterSpacing: 1,
                margin: EdgeInsets.only(left: 10.0),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: NextFButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/welcome2');
              setState(() {
                firstRec = const Color(0xFFFFC7C7);
              });
            },
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoundedRectangle(
                color: firstRec,
              ),
              SizedBox(width: 2),
              RoundedRectangle(
                color: const Color(0xFFFFC7C7),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/welcome2'),
              ),
              SizedBox(width: 2),
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
