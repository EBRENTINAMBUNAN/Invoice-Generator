// === components/project_input.dart ===
import 'package:flutter/material.dart';

class ProjectInput extends StatelessWidget {
  final TextEditingController controller;
  const ProjectInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Nama Project',
        border: OutlineInputBorder(),
      ),
    );
  }
}