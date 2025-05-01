// === pages/invoice_page.dart ===
import 'package:flutter/material.dart';
import '../components/client_input.dart';
import '../components/project_input.dart';
import '../components/service_list.dart';
import '../components/add_service_button.dart';
import '../components/generate_pdf_button.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final _clientController = TextEditingController();
  final _projectController = TextEditingController();
  final List<Map<String, TextEditingController>> _services = [];

  @override
  void dispose() {
    _clientController.dispose();
    _projectController.dispose();
    for (var service in _services) {
      service['item']?.dispose();
      service['price']?.dispose();
    }
    super.dispose();
  }

  void _addService() {
    setState(() {
      _services.add({
        'item': TextEditingController(),
        'price': TextEditingController(),
      });
    });
  }

  void _removeService(int index) {
    setState(() {
      _services[index]['item']?.dispose();
      _services[index]['price']?.dispose();
      _services.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ClientInput(controller: _clientController),
            const SizedBox(height: 12),
            ProjectInput(controller: _projectController),
            const SizedBox(height: 24),
            ServiceList(services: _services, onRemove: _removeService),
            const SizedBox(height: 8),
            AddServiceButton(onPressed: _addService),
            const SizedBox(height: 24),
            GeneratePdfButton(
              clientController: _clientController,
              projectController: _projectController,
              services: _services,
            ),
          ],
        ),
      ),
    );
  }
}