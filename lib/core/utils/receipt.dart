import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/content.dart';
import '../../data/models.dart';
import 'format.dart';

const _amber = PdfColor.fromInt(0xFFE9A23B);
const _ink = PdfColor.fromInt(0xFF1D1A16);
const _muted = PdfColor.fromInt(0xFF756C60);
const _line = PdfColor.fromInt(0xFFE9E0D2);
const _success = PdfColor.fromInt(0xFF2E7D4F);

const _methodEn = {
  PayMethod.juice: 'Juice by MCB',
  PayMethod.cash: 'Cash (manual entry)',
  PayMethod.bank: 'Bank transfer (manual entry)',
};

/// Builds the PDF receipt (US-06: CHI logo, member number, months, amount, date, Juice ref).
/// Receipts are issued in English; the society's official language for financial records.
Future<Uint8List> buildReceiptPdf(Payment p) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Inter_400Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Inter_600SemiBold.ttf'),
  );
  final fund = fundById(p.fund);
  final rows = <(String, String)>[
    ('Receipt no.', p.receiptNo),
    if (!p.anonymous) ('Member', '${member.name} (${member.number})'),
    p.kind == PaymentKind.subscription
        ? ('Months', monthsLabel(p.monthKeys, Lang.en))
        : ('Fund', fund?.label.en ?? 'General'),
    ('Payment method', _methodEn[p.method]!),
    (p.method == PayMethod.juice ? 'Juice reference' : 'Reference', p.ref),
    ('Date', longDate(Lang.en, ymdOf(p.date))),
  ];

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(48),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _amber, width: 3)),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 56,
                  height: 56,
                  alignment: pw.Alignment.center,
                  decoration: const pw.BoxDecoration(
                    color: _amber,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Text(
                    'CHI',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: _ink,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      societyName,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Port Louis, Mauritius · ${Contacts.email}',
                      style: const pw.TextStyle(fontSize: 11, color: _muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 32),
          pw.Text(
            p.kind == PaymentKind.donation
                ? 'Donation receipt'
                : 'Subscription receipt',
            style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Paid · confirmed by server',
            style: pw.TextStyle(
              color: _success,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          for (final (k, v) in rows)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 10),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: _line)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(k),
                  pw.Text(
                    v,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Amount paid', style: const pw.TextStyle(fontSize: 16)),
              pw.Text(
                mur(p.amount),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Text(
            'This receipt was issued automatically after the payment was confirmed server-side with MCB. '
            'Keep it as proof of payment. Demo document, not a valid tax receipt.',
            style: const pw.TextStyle(fontSize: 10, color: _muted),
          ),
        ],
      ),
    ),
  );
  return doc.save();
}

/// Opens the system share sheet (save, email, WhatsApp) with the receipt PDF.
Future<void> shareReceipt(Payment p) async => Printing.sharePdf(
  bytes: await buildReceiptPdf(p),
  filename: '${p.receiptNo}.pdf',
);
