// === components/generate_pdf_button.dart ===
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class GeneratePdfButton extends StatelessWidget {
  final TextEditingController clientController;
  final TextEditingController projectController;
  final List<Map<String, TextEditingController>> services;
  final String selectedPaymentMethod; // Ganti dengan string untuk selectedPaymentMethod

  const GeneratePdfButton({
    super.key,
    required this.clientController,
    required this.projectController,
    required this.services,
    required this.selectedPaymentMethod, // Tambahkan parameter baru
  });

  String _formatRupiah(String value) {
    try {
      final number = int.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
      return number.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    } catch (_) {
      return value;
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _generatePdf(BuildContext context) async {
    if (clientController.text.isEmpty || projectController.text.isEmpty) {
      _showSnackbar(context, 'Mohon isi Nama Client dan Nama Project.');
      return;
    }
    if (services.isEmpty) {
      _showSnackbar(context, 'Mohon tambahkan minimal 1 layanan.');
      return;
    }
    for (var service in services) {
      if (service['item']!.text.isEmpty || service['price']!.text.isEmpty) {
        _showSnackbar(context, 'Mohon isi semua nama layanan dan harga.');
        return;
      }
    }

    // Gantilah pengecekan paymentMethodController.text.isEmpty
    if (selectedPaymentMethod.isEmpty) {
      _showSnackbar(context, 'Mohon pilih metode pembayaran.');
      return;
    }

    final pdf = pw.Document();
    final today = DateTime.now();
    final formattedDate = "${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}";

    final serviceData = services.map((service) {
      return [service['item']!.text, 'Rp ${_formatRupiah(service['price']!.text)}'];
    }).toList();

    final totalHarga = services.fold(0, (sum, service) {
      return sum + int.tryParse(service['price']!.text.replaceAll(RegExp(r'[^0-9]'), ''))!;
    });

    final dpAmount = (totalHarga * 0.3).round();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Text('Ebren Tinambunan', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.Text('bendev403@gmail.com | +6281263308247 | bendev.web.id', style: pw.TextStyle(fontSize: 10)),
          pw.Divider(),
          pw.SizedBox(height: 16),
          pw.Text('Invoice', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Tanggal: $formattedDate', style: pw.TextStyle(fontSize: 12)),
          pw.Text('Project: ${projectController.text}', style: pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 16),
          pw.Text('Invoice To:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.Text(clientController.text, style: pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['Layanan', 'Harga'],
            data: serviceData,
            border: pw.TableBorder.all(color: PdfColors.grey),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            cellStyle: pw.TextStyle(fontSize: 12),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
            },
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Total: ', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text('Rp ${_formatRupiah(totalHarga.toString())}', style: pw.TextStyle(fontSize: 14)),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('DP (30%): ', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('Rp ${_formatRupiah(dpAmount.toString())}', style: pw.TextStyle(fontSize: 12)),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text('Metode Pembayaran:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Text(selectedPaymentMethod, style: pw.TextStyle(fontSize: 12)),  // Gantilah dengan selectedPaymentMethod
          pw.SizedBox(height: 32),
          pw.Text('Terima kasih atas kepercayaannya!', style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/invoice_${today.millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    _showSnackbar(context, 'Invoice berhasil dibuat.');
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _generatePdf(context),
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text('Export Invoice PDF'),
    );
  }
}
