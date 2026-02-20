import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/company_profile.dart';
import '../models/invoice.dart';

class PdfService {
  static const String _appFolderName = 'BuildX';

  Future<File> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();

    final profile = invoice.companyProfile;
    final logoBytes = await _loadLogoBytes(profile.logoPath);
    final displayDate = DateFormat('dd MMMM yyyy').format(invoice.date);
    final amount = NumberFormat('#,##,##0.00', 'en_IN').format(invoice.totalAmount);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        // Explicit A4 page configuration to keep invoice at A4 length/size.
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 42),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _buildHeader(displayDate, profile, logoBytes),
            pw.SizedBox(height: 40),
            _buildCompanyBlock(profile),
            pw.SizedBox(height: 46),
            pw.Center(
              child: pw.Text(
                'Acknowledgement Receipt',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.blueGrey800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            pw.SizedBox(height: 60),
            pw.Text(
              'This is to acknowledgement the receipt from ${invoice.client.name}, '
              '${invoice.client.address}, the amount of Rs. $amount /- '
              'as payment for House Construction.',
              textAlign: pw.TextAlign.justify,
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.blueGrey700,
                lineSpacing: 1.6,
              ),
            ),
            if (invoice.notes != null && invoice.notes!.trim().isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Text(
                'Notes: ${invoice.notes!.trim()}',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.blueGrey600,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final appFolder = await _ensureAppFolder();
    final dateFolder = await _ensureDateFolder(appFolder);

    final safeClient = _sanitizeFileName(invoice.client.name);
    final day = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final file = File('${dateFolder.path}/${safeClient}_$day.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildHeader(
    String displayDate,
    CompanyProfile profile,
    Uint8List? logoBytes,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            _buildLogo(logoBytes),
            pw.SizedBox(width: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  profile.name,
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.blueGrey800,
                  ),
                ),
                pw.Text(
                  profile.tagline,
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.blueGrey500,
                  ),
                ),
              ],
            )
          ],
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 14),
          child: pw.Text(
            'Date: $displayDate',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.blueGrey700,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildLogo(Uint8List? logoBytes) {
    if (logoBytes != null) {
      return pw.Container(
        width: 56,
        height: 56,
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(12),
        ),
        clipBehavior: pw.Clip.antiAlias,
        child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.cover),
      );
    }

    return pw.Container(
      width: 56,
      height: 56,
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#DDF0FD'),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      alignment: pw.Alignment.center,
      child: pw.Text(
        'LOGO',
        style: pw.TextStyle(
          color: PdfColor.fromHex('#42A5F5'),
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildCompanyBlock(CompanyProfile profile) {
    return pw.Column(
      children: [
        pw.Text(
          '${profile.name} ${profile.tagline}'.trim(),
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          profile.address,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.blueGrey600,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'GSTIN/UIN : ${profile.gstinUin}',
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.blueGrey600,
          ),
        ),
        pw.Text(
          'State Name : ${profile.stateName}, Code : ${profile.stateCode}',
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.blueGrey600,
          ),
        ),
        pw.Text(
          'E-Mail : ${profile.emailId}',
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.blueGrey600,
            decoration: pw.TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Future<Uint8List?> _loadLogoBytes(String? logoPath) async {
    if (logoPath == null || logoPath.trim().isEmpty) {
      return null;
    }

    final file = File(logoPath);
    if (!await file.exists()) {
      return null;
    }

    return file.readAsBytes();
  }

  String _sanitizeFileName(String input) {
    final cleaned = input.trim().replaceAll(RegExp(r'[^a-zA-Z0-9 _-]'), '');
    final normalized = cleaned.replaceAll(RegExp(r'\s+'), '_');
    return normalized.isEmpty ? 'client' : normalized;
  }

  Future<Directory> _ensureAppFolder() async {
    final root = await getApplicationDocumentsDirectory();
    final appFolder = Directory('${root.path}/$_appFolderName');
    if (!await appFolder.exists()) {
      await appFolder.create(recursive: true);
    }
    return appFolder;
  }

  Future<Directory> _ensureDateFolder(Directory appFolder) async {
    final day = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dateFolder = Directory('${appFolder.path}/$day');
    if (!await dateFolder.exists()) {
      await dateFolder.create(recursive: true);
    }
    return dateFolder;
  }
}
