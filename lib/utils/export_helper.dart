import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:muta_manager/models/muta_model.dart';
import 'package:muta_manager/theme/theme_provider.dart';
import 'package:muta_manager/widgets/muta_visualizer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ExportHelper {
  static Future<void> exportMutaAsPdf(Muta muta) async {
    final pdf = await _generatePdf(muta);
    final fileName = 'Muta_${muta.nomeMuta.replaceAll(' ', '_')}_${muta.anno}.pdf';
    await Printing.sharePdf(bytes: pdf, filename: fileName);
  }

  static Future<Uint8List> _generatePdf(Muta muta) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Muta: ${muta.nomeMuta}', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text('Anno: ${muta.anno}'),
              pw.Text('Cero: ${muta.ceroNome}'),
              pw.Text('Posizione: ${muta.posizione}'),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  children: [
                    _buildPdfParticipantRow(muta, RuoloMuta.puntaAvanti),
                    pw.SizedBox(height: 10),
                    _buildPdfParticipantRow(muta, RuoloMuta.ceppoAvanti),
                    pw.SizedBox(height: 10),
                    _buildPdfParticipantRow(muta, RuoloMuta.ceppoDietro),
                    pw.SizedBox(height: 10),
                    _buildPdfParticipantRow(muta, RuoloMuta.puntaDietro),
                  ],
                ),
              )
              if (muta.note != null && muta.note!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 20),
                  child: pw.Text('Note: ${muta.note}'),
                ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfParticipantRow(Muta muta, RuoloMuta ruolo) {
    final left = muta.getPersonaPerRuoloEStanga(ruolo, true);
    final right = muta.getPersonaPerRuoloEStanga(ruolo, false);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(left?.nomeCompleto ?? 'N/A'),
        pw.Text(ruolo.toString().split('.').last, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(right?.nomeCompleto ?? 'N/A'),
      ],
    );
  }

  static Future<void> exportMutaAsImage(BuildContext context, Muta muta, ThemeProvider themeProvider) async {
    final renderKey = GlobalKey();

    // This is a trick to render the widget off-screen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          try {
            RenderRepaintBoundary boundary = renderKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
            ui.Image image = await boundary.toImage(pixelRatio: 2.5);
            ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

            if (byteData == null) {
              throw Exception("Cannot convert image to ByteData.");
            }
            Uint8List pngBytes = byteData.buffer.asUint8List();

            Navigator.pop(dialogContext);

            final directory = await getTemporaryDirectory();
            final imagePath = '${directory.path}/Muta_${muta.nomeMuta.replaceAll(' ', '_')}_${muta.anno}.png';
            final imageFile = File(imagePath);
            await imageFile.writeAsBytes(pngBytes);
            await Share.shareXFiles([XFile(imageFile.path)], text: 'Muta: ${muta.nomeMuta} (${muta.anno}) - Cero di ${muta.ceroNome}');

          } catch (e) {
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error generating/sharing image: ${e.toString()}'), backgroundColor: Colors.red),
            );
          }
        });
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: RepaintBoundary(
            key: renderKey,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: MutaVisualizer(muta: muta, themeProvider: themeProvider, forExport: true),
            ),
          ),
        );
      },
    );
  }
}
