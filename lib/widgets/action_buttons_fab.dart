// lib/widgets/action_buttons_fab.dart
import 'package:flutter/material.dart';

class ActionFabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ActionFabButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: label,
          onPressed: onPressed,
          mini: true,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: Icon(icon),
        ),
        const SizedBox(height: 2.0),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }
}