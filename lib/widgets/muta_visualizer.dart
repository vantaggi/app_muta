import 'package:flutter/material.dart';
import 'package:muta_manager/models/muta_model.dart';
import 'package:muta_manager/theme/theme_provider.dart';
import 'package:muta_manager/utils/extensions.dart';
import 'package:muta_manager/widgets/barella_layout_widget.dart';

class MutaVisualizer extends StatelessWidget {
  final Muta muta;
  final ThemeProvider themeProvider;
  final bool forExport;

  const MutaVisualizer({
    super.key,
    required this.muta,
    required this.themeProvider,
    this.forExport = false,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle baseStyle = TextStyle(
      fontSize: forExport ? 11 : 12,
      color: forExport ? Colors.black : Theme.of(context).textTheme.bodyMedium?.color,
      height: 1.3,
    );
    TextStyle boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
    TextStyle titleStyle = boldStyle.copyWith(
        fontSize: baseStyle.fontSize! + (forExport ? 3 : 4),
        color: forExport ? Colors.black : themeProvider.currentPrimaryColor);
    TextStyle stangaTitleStyle = boldStyle.copyWith(
      fontSize: baseStyle.fontSize! + (forExport ? 2 : 3),
      decoration: TextDecoration.underline,
      decorationColor: forExport ? Colors.black54 : themeProvider.currentPrimaryColor.withOpacity(0.7),
      decorationThickness: 1.5,
    );
    TextStyle ruoloStyle = baseStyle.copyWith(fontWeight: FontWeight.w600, fontSize: baseStyle.fontSize! + (forExport ? 0 : 1));
    TextStyle nomeStyle = baseStyle;
    TextStyle noteStyle = baseStyle.copyWith(
        fontStyle: FontStyle.italic,
        fontSize: baseStyle.fontSize! - (forExport ? 1.5 : 1),
        color: forExport ? Colors.grey.shade700 : Colors.grey.shade600);

    return Container(
      padding: EdgeInsets.all(forExport ? 12 : 0),
      width: forExport ? 400 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: forExport ? 6.0 : 8.0),
              child: Text(
                '${muta.nomeMuta} (${muta.anno})',
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Center(
            child: Text(
              'Cero di ${muta.ceroNome}',
              style: boldStyle.copyWith(
                  fontSize: baseStyle.fontSize! + (forExport ? 1 : 2),
                  color: forExport ? Colors.black87 : themeProvider.currentPrimaryColor.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ),
          if (!forExport && muta.posizione.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Center(child: Text('Luogo: ${muta.posizione}', style: baseStyle, textAlign: TextAlign.center)),
            ),
          if (muta.note != null && muta.note!.isNotEmpty && !forExport)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 6.0),
              child: Center(
                  child: Text('Note Muta: ${muta.note}',
                      style: noteStyle, textAlign: TextAlign.center)),
            ),
          SizedBox(height: forExport ? 10 : 15),
          BarellaLayoutWidget(muta: muta),
          if (forExport) ...[
            SizedBox(height: 15),
            Center(
              child: Text(
                'Muta Manager - Generato il ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
              ),
            )
          ]
        ],
      ),
    );
  }
}
