import 'package:flutter/material.dart';
import 'package:muta_manager/models/muta_model.dart';
import 'package:muta_manager/theme/app_theme.dart';
import 'package:muta_manager/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class BarellaLayoutWidget extends StatelessWidget {
  final Muta muta;

  const BarellaLayoutWidget({super.key, required this.muta});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildStangaColumn(context, true),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: _buildStangaColumn(context, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStangaColumn(BuildContext context, bool isSinistra) {
    final title = isSinistra ? 'Stanga Sinistra' : 'Stanga Destra';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        _buildSlot(context, RuoloMuta.puntaAvanti, isSinistra),
        const SizedBox(height: AppTheme.spacingSm),
        _buildSlot(context, RuoloMuta.ceppoAvanti, isSinistra),
        const SizedBox(height: AppTheme.spacingSm),
        _buildSlot(context, RuoloMuta.ceppoDietro, isSinistra),
        const SizedBox(height: AppTheme.spacingSm),
        _buildSlot(context, RuoloMuta.puntaDietro, isSinistra),
      ],
    );
  }

  Widget _buildSlot(BuildContext context, RuoloMuta ruolo, bool isSinistra) {
    final persona = muta.getPersonaPerRuoloEStanga(ruolo, isSinistra);

    if (persona == null) {
      return _buildEmptySlot(context, ruolo);
    }
    return _buildFilledSlot(context, persona);
  }

  Widget _buildEmptySlot(BuildContext context, RuoloMuta ruolo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white38 : Colors.black38;

    return CustomPaint(
      painter: _DashedRectPainter(color: color, strokeWidth: 1.5, gap: 4.0),
      child: Container(
        height: 80, // Increased height slightly
        alignment: Alignment.center,
        child: Text(
          _getRuoloLabel(ruolo),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildFilledSlot(BuildContext context, PersonaMuta persona) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 80, // Increased height slightly
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: AppTheme.microBorderRadius,
        boxShadow: AppTheme.ambientShadow,
      ),
      child: ClipRRect(
        borderRadius: AppTheme.microBorderRadius,
        child: Row(
          children: [
            Container(
              width: 6,
              color: themeProvider.currentPrimaryColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.labelLarge,
                        children: [
                          TextSpan(text: '${persona.nome} '),
                          if (persona.soprannome != null && persona.soprannome!.isNotEmpty)
                            TextSpan(
                              text: '"${persona.soprannome}" ',
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          TextSpan(text: persona.cognome),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      persona.ruoloDescrizione,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (persona.note != null && persona.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          persona.note!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRuoloLabel(RuoloMuta ruolo) {
    switch (ruolo) {
      case RuoloMuta.puntaAvanti: return 'Punta Avanti';
      case RuoloMuta.ceppoAvanti: return 'Ceppo Avanti';
      case RuoloMuta.ceppoDietro: return 'Ceppo Dietro';
      case RuoloMuta.puntaDietro: return 'Punta Dietro';
    }
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedRectPainter({this.color = Colors.black, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12.0)));

    Path dashPath = Path();

    double distance = 0.0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
            pathMetric.extractPath(distance, distance + gap), Offset.zero);
        distance += gap * 2;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
