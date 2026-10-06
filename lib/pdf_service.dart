import 'dart:typed_data';

import 'package:barcode/barcode.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'boleto_parser.dart';

class PdfService {
  static Future<Uint8List> generate(BoletoData boleto) async {
    final pdf = pw.Document();
    final barcode = Barcode.itf();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.black,
                    width: 0.8,
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'BOLETO BANCÁRIO',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    pw.Text(
                      boleto.codigoBarras.substring(0, 3),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _row(
                'Banco',
                boleto.banco,
              ),
              _row(
                'Vencimento',
                _formatDate(
                  boleto.vencimento,
                ),
              ),
              _row(
                'Valor',
                _formatCurrency(
                  boleto.valorCentavos,
                ),
              ),
              pw.SizedBox(
                height: 18,
              ),
              pw.Text(
                'Linha digitável',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.SizedBox(
                height: 5,
              ),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey700,
                    width: 0.6,
                  ),
                ),
                child: pw.Text(
                  boleto.linhaDigitavel,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              pw.SizedBox(
                height: 8,
              ),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: barcode,
                  data: boleto.codigoBarras,
                  width: 450,
                  height: 96,
                  drawText: false,
                ),
              ),
              pw.SizedBox(
                height: 5,
              ),
              pw.Center(
                child: pw.Text(
                  boleto.codigoBarras,
                  style: const pw.TextStyle(
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _row(
    String label,
    String value,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(
            color: PdfColors.black,
            width: 0.6,
          ),
          right: pw.BorderSide(
            color: PdfColors.black,
            width: 0.6,
          ),
          bottom: pw.BorderSide(
            color: PdfColors.black,
            width: 0.6,
          ),
        ),
      ),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(
    int centavos,
  ) {
    final reais = centavos ~/ 100;
    final centavosRestantes = centavos % 100;

    final reaisFormatados = reais.toString().replaceAllMapped(
          RegExp(
            r'(\d)(?=(\d{3})+(?!\d))',
          ),
          (match) => '${match[1]}.',
        );

    return 'R\$ $reaisFormatados,'
        '${centavosRestantes.toString().padLeft(2, '0')}';
  }

  static String _formatDate(
    DateTime? data,
  ) {
    if (data == null) {
      return 'Não informado';
    }

    final dia = data.day.toString().padLeft(
          2,
          '0',
        );

    final mes = data.month.toString().padLeft(
          2,
          '0',
        );

    return '$dia/$mes/${data.year}';
  }
}
