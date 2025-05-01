// === components/client_input.dart ===
import 'package:flutter/material.dart';

class ClientInput extends StatelessWidget {
  final TextEditingController controller;
  const ClientInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Nama Client',
        border: OutlineInputBorder(),
      ),
    );
  }
}