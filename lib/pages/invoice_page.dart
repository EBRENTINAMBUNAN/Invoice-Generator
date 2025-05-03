// === pages/invoice_page.dart ===
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final _paymentMethodController = TextEditingController();
  String _selectedPaymentMethod = 'Transfer Bank';

  final List<String> _paymentMethods = [
    'Transfer Bank',
    'E-Wallet (OVO/DANA/GoPay)',
    'Cash',
    'Kartu Kredit',
  ];

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
  final itemController = TextEditingController();
  final priceController = TextEditingController();

  // Tambahkan listener agar total update saat harga diketik
  priceController.addListener(() {
    setState(() {}); // Update tampilan (agar total & DP berubah otomatis)
  });

  setState(() {
    _services.add({
      'item': itemController,
      'price': priceController,
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

  int _calculateTotal() {
    int total = 0;
    for (var service in _services) {
      final priceText = service['price']?.text.replaceAll('.', '') ?? '0';
      if (priceText.isNotEmpty) {
        total += int.tryParse(priceText) ?? 0;
      }
    }
    return total;
  }

  String _formatCurrency(int number) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final totalHarga = _calculateTotal();
    final dp30 = (totalHarga * 0.3).round();

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

            // Metode Pembayaran
            const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'Pilih Metode Pembayaran', 
                border: OutlineInputBorder(),
              ),
              items: _paymentMethods.map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),


            // Total dan DP
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Total Harga:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_formatCurrency(totalHarga)),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('DP (30%):', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_formatCurrency(dp30)),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol PDF
          const SizedBox(height: 24),
          GeneratePdfButton(
          clientController: _clientController,
          projectController: _projectController,
          services: _services,
          selectedPaymentMethod: _selectedPaymentMethod,  
        ),
          ],
        ),
      ),
    );
  }
}
