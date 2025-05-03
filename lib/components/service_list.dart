// === components/service_list.dart ===
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServiceList extends StatelessWidget {
  final List<Map<String, TextEditingController>> services;
  final Function(int) onRemove;
  const ServiceList({super.key, required this.services, required this.onRemove});

  String _formatNumber(String s) {
    if (s.isEmpty) return '';
    final number = int.parse(s.replaceAll('.', '')); // hilangkan titik dulu
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number).replaceAll(',', '.'); // pakai titik (format Indo)
  }

  void _onPriceChanged(TextEditingController controller, String value) {
    final newText = _formatNumber(value);
    if (newText != value) {
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daftar Layanan:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...services.asMap().entries.map((entry) {
          final index = entry.key;
          final service = entry.value;
          final priceController = service['price']!;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: service['item'],
                    decoration: const InputDecoration(labelText: 'Nama Layanan', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Harga', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _onPriceChanged(priceController, value),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onRemove(index),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
