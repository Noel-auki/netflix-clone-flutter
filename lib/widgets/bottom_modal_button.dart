import 'package:flutter/material.dart';

class BottomSheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final double size;
  final bool light;
  final VoidCallback? onPressed;

  const BottomSheetButton({
    Key? key,
    required this.icon,
    required this.label,
    this.size = 20.0,
    this.light = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          CircleAvatar(
            radius: size / 2 + 8,
            backgroundColor: light ? Colors.white : Color(0xff3d3d3d),
            child: Icon(
              icon,
              size: size,
              color: light ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: light ? Colors.white : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
