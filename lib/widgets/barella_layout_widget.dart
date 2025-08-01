import 'package:flutter/material.dart';
import 'package:muta_manager/models/muta_model.dart';

class BarellaLayoutWidget extends StatelessWidget {
  final Muta muta;

  const BarellaLayoutWidget({super.key, required this.muta});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * 0.5; // Aspect ratio for the stretcher

        return Container(
          width: width,
          height: height,
          child: Stack(
            children: [
              // Stretcher body
              Center(
                child: Container(
                  width: width * 0.8,
                  height: height * 0.6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Stanga Sinistra
              _buildParticipant(context, muta.getPersonaPerRuoloEStanga(RuoloMuta.puntaAvanti, true), top: 0, left: 0),
              _buildParticipant(context, muta.getPersonaPerRuoloEStanga(RuoloMuta.ceppoAvanti, true), top: height * 0.3, left: 0),
              _buildParticipant(context, muta.getPersonaPerRuoloEStanga(RuoloMuta.ceppoDietro, true), top: height * 0.7, left: 0),
              _buildParticipant(context, muta.getPersonaPerRuoloEStanga(RuoloMuta.puntaDietro, true), bottom: 0, left: 0),
              // Stanga Destra
              _buildParticipant(context, muta.getPersonaPerRuoloEStanga(RuoloMuta.puntaAvanti, false), top: 0, right: 0),
              _buildParticipant(context, muta.getPersonaPerRuoloEStanga(RuoloMuta.ceppoAvanti, false), top: height * 0.3, right: 0),
              _buildParticipant(context, muta.getPersonaPerRuoloEStanga(RuoloMuta.ceppoDietro, false), top: height * 0.7, right: 0),
              _buildParticipant(context, muta.getPersonaPerRuoloEStanga(RuoloMuta.puntaDietro, false), bottom: 0, right: 0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipant(BuildContext context, PersonaMuta? persona, {double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          persona?.nomeCompleto ?? 'N/A',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ),
    );
  }
}
