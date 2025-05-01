// === components/add_service_button.dart ===
import 'package:flutter/material.dart';

class AddServiceButton extends StatelessWidget {
  final VoidCallback onPressed;
  const AddServiceButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: const Text('Tambah Layanan'),
    );
  }
}