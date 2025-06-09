// lib/widgets/bottom_action_buttons_row.dart
import 'package:flutter/material.dart';

class BottomActionButtonsRow extends StatelessWidget {
  final VoidCallback onMainActionPressed; // Bouton Envoyer
  final VoidCallback onSecondaryActionPressed; // Bouton Scan/Shake
  final String mainActionLabel;
  final String secondaryActionLabel;
  final IconData mainActionIcon;
  final IconData secondaryActionIcon;

  const BottomActionButtonsRow({
    super.key,
    required this.onMainActionPressed,
    required this.onSecondaryActionPressed,
    this.mainActionLabel = 'ENVOYER',
    this.secondaryActionLabel = 'SCAN',
    this.mainActionIcon = Icons.arrow_upward,
    this.secondaryActionIcon = Icons.screen_rotation_alt, // Icône pour secouer/scanner
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: mainActionLabel,
            onPressed: onMainActionPressed,
            child: Icon(mainActionIcon),
          ),
          const SizedBox(width: 32.0),
          FloatingActionButton(
            heroTag: secondaryActionLabel,
            onPressed: onSecondaryActionPressed,
            child: Icon(secondaryActionIcon),
          ),
        ],
      ),
    );
  }
}