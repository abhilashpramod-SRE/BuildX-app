import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/invoice.dart';

class PdfService {
  Future<File> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('BUILDX CONSTRUCTIONS',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('42 Industrial Layout, Bengaluru'),
                  pw.Text('support@buildx.com'),
                ],
              ),
              pw.Container(
                width: 56,
                height: 56,
                color: PdfColors.blueGrey900,
                alignment: pw.Alignment.center,
                child: pw.Text('LOGO',
                    style: const pw.TextStyle(color: PdfColors.white)),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('INVOICE',
              style:
                  pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.Text('Invoice No: ${invoice.invoiceNumber}'),
          pw.Text('Invoice Date: ${DateFormat('dd MMM yyyy').format(invoice.date)}'),
          pw.SizedBox(height: 12),
          pw.Text('Bill To: ${invoice.client.name}'),
          pw.Text(invoice.client.address),
          pw.Text('Phone: ${invoice.client.phone}'),
          pw.SizedBox(height: 12),
          pw.Text('Project: ${invoice.projectName}'),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['Item', 'Date', 'Amount'],
            data: invoice.items
                .map((e) => [
                      e.item,
                      DateFormat('dd/MM/yyyy').format(e.date),
                      e.amount.toStringAsFixed(2),
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 12),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total: ₹${invoice.totalAmount.toStringAsFixed(2)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
          ),
          if (invoice.notes != null && invoice.notes!.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 16),
              child: pw.Text('Notes: ${invoice.notes}'),
            ),
          pw.SizedBox(height: 36),
          pw.Opacity(
            opacity: 0.15,
            child: pw.Center(
              child: pw.Text(
                'SYSTEM GENERATED INVOICE',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${invoice.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
