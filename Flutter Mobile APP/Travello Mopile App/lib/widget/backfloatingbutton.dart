import 'package:flutter/material.dart';

class BackFButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final double bottom;
  final double left;

  const BackFButton({
    Key? key,
    required this.onPressed,
    this.backgroundColor = Colors.black,
    this.icon = Icons.arrow_back_ios_new,
    this.iconColor = Colors.white,
    this.bottom = 16.0,
    this.left = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottom,
      left: left,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        shape: const CircleBorder(),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}
