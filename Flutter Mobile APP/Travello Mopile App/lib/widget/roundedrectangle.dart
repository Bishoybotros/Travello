import 'package:flutter/material.dart';

class RoundedRectangle extends StatelessWidget {
  final Color color;
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets margin;
  final VoidCallback? onPressed;

  RoundedRectangle({
    this.color = Colors.blue,
    this.width = 20.0,
    this.height = 10.0,
    this.borderRadius = 10.0,
    this.margin = const EdgeInsets.all(0),
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: margin,
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
