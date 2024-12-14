import 'package:flutter/material.dart';

class NextFButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final double bottom;
  final double right;

  const NextFButton({
    Key? key,
    required this.onPressed,
    this.backgroundColor = Colors.black,
    this.icon = Icons.arrow_forward_ios,
    this.iconColor = Colors.white,
    this.bottom = 16.0,
    this.right = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottom,
      right: right,
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
