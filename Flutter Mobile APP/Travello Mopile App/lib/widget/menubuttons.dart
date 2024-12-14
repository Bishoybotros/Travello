import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final String text;
  final double fontSize;
  
  const MenuButton({
    Key? key,
    required this.onPressed,
    this.backgroundColor = Colors.black,
    this.text = '',
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Set width to screen width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF01497C),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10.0), // Adjust radius as needed
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, color: Colors.white,fontFamily: 'ADLaMDisplay'),
        ),
      ),
    );
  }
}
