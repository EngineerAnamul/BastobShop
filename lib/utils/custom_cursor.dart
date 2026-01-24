import 'package:flutter/material.dart';

class CustomCursor extends StatelessWidget {
  final double x;
  final double y;

  const CustomCursor({super.key, required this.x, required this.y});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x - 12,
      top: y - 12,
      child: IgnorePointer(
        child: Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.blue.withAlpha(100), blurRadius: 10),
            ],
          ),
        ),
      ),
    );
  }
}