import 'package:flutter/material.dart';

class TicketInfo extends StatefulWidget {
  const TicketInfo({super.key});

  @override
  State<TicketInfo> createState() => _TicketInfoState();
}
  bool _isExpanded = false;

class _TicketInfoState extends State<TicketInfo> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
      10.0), // Adjust the border radius here
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: _isExpanded ? 200.0 : 0.0,
      width: MediaQuery.of(context).size.width,
      color: Color(0xFFA9D6E5),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Text(
        'Add Your Ticket Number',
         style: TextStyle(color: Colors.white ,fontSize: 24),
        ),
      ],
      ),
    ),
    );
  }
}