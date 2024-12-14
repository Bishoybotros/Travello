import 'package:flutter/material.dart';

class SMenuButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final IconData? iconData;

  const SMenuButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
    this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF01497C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconData != null) // Show icon only if iconData is provided
            Icon(
              iconData,
              size: 100,
              color: Colors.white,
            ),
          Text(
            buttonText,
            style: const TextStyle(fontSize: 20,color: Colors.white,
            fontFamily: 'ADLaMDisplay'),
          ),
        ],
      ),
    );
  }
}