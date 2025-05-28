import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_muta/theme/theme_provider.dart';
import 'package:app_muta/widgets/cero_selector.dart';
import 'package:app_muta/models/muta_model.dart';

class CreateMutaScreen extends StatefulWidget {
  const CreateMutaScreen({super.key});

  @override
  State<CreateMutaScreen> createState() => _CreateMutaScreenState();
}

class _CreateMutaScreenState extends State<CreateMutaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroMutaController = TextEditingController();
  final _posizioneController = TextEditingController();
  final _noteController = TextEditingController();

  // Controllers per le persone
  final Map<RuoloMuta, List<TextEditingController>> _nomiControllers = {
    RuoloMuta.puntaAvanti: [TextEditingController(), TextEditingController()],
    RuoloMuta.ceppoAvanti: [TextEditingController(), TextEditingController()],
    RuoloMuta.ceppoDietro: [TextEditingController(), TextEditingController()],
    RuoloMuta.puntaDietro: [TextEditingController(), TextEditingController()],
  };

  final Map<RuoloMuta, List<TextEditingController>> _cognomiControllers = {
    RuoloMuta.puntaAvanti: [TextEditingController(), TextEditingController()],
    RuoloMuta.ceppoAvanti: [TextEditingController(), TextEditingController()],
    RuoloMuta.ceppoDietro: [TextEditingController(), TextEditingController()],
    RuoloMuta.puntaDietro: [TextEditingController(), TextEditingController()],
  };

  @override
  void dispose() {
    _numeroMutaController.dispose();
    _posizioneController.dispose();
    _noteController.dispose();

    for (var controllers in _nomiControllers.values) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }

    for (var controllers in _cognomiControllers.values) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Crea Muta ${themeProvider.currentCeroName}'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: CeroSelector(showAsPopup: true, showFullName: false),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con info cero
                  Card(
                    color: themeProvider.currentPrimaryColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            themeProvider.currentCeroIcon,
                            color: themeProvider.currentPrimaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Creazione muta per il Cero di ${themeProvider.currentCeroName}',
                            style: TextStyle(
                              color: themeProvider.currentPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Informazioni generali
                  Text(
                    'Informazioni Generali',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _numeroMutaController,
                          decoration: const InputDecoration(
                            labelText: 'Numero Muta',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserisci il numero della muta';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _posizioneController,
                          decoration: const InputDecoration(
                            labelText: 'Posizione',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                            hintText: 'es. Via del Corso, 15',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserisci la posizione';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Composizione muta
                  Text(
                    'Composizione Muta',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inserisci le 8 persone che compongono la muta (2 per ogni ruolo)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sezioni per ogni ruolo
                  ...RuoloMuta.values.map((ruolo) => _buildRuoloSection(ruolo, themeProvider)),

                  const SizedBox(height: 24),

                  // Note
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (opzionale)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                      hintText: 'Eventuali note sulla muta...',
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 32),

                  // Pulsanti azione
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _previewMuta(themeProvider),
                          icon: const Icon(Icons.preview),
                          label: const Text('Anteprima'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _saveMuta(themeProvider),
                          icon: const Icon(Icons.save),
                          label: const Text('Salva Muta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.currentPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Pulsante esporta
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _exportMuta(themeProvider),
                      icon: const Icon(Icons.share),
                      label: const Text('Esporta come Immagine'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRuoloSection(RuoloMuta ruolo, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeProvider.currentPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getRuoloIcon(ruolo),
                    color: themeProvider.currentPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getRuoloName(ruolo),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Prima persona
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nomiControllers[ruolo]![0],
                    decoration: const InputDecoration(
                      labelText: 'Nome 1°',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Richiesto';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _cognomiControllers[ruolo]![0],
                    decoration: const InputDecoration(
                      labelText: 'Cognome 1°',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Richiesto';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Seconda persona
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nomiControllers[ruolo]![1],
                    decoration: const InputDecoration(
                      labelText: 'Nome 2°',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Richiesto';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _cognomiControllers[ruolo]![1],
                    decoration: const InputDecoration(
                      labelText: 'Cognome 2°',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Richiesto';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRuoloIcon(RuoloMuta ruolo) {
    switch (ruolo) {
      case RuoloMuta.puntaAvanti:
        return Icons.keyboard_arrow_up;
      case RuoloMuta.ceppoAvanti:
        return Icons.crop_square;
      case RuoloMuta.ceppoDietro:
        return Icons.crop_square;
      case RuoloMuta.puntaDietro:
        return Icons.keyboard_arrow_down;
    }
  }

  String _getRuoloName(RuoloMuta ruolo) {
    switch (ruolo) {
      case RuoloMuta.puntaAvanti:
        return 'Punta Avanti';
      case RuoloMuta.ceppoAvanti:
        return 'Ceppo Avanti';
      case RuoloMuta.ceppoDietro:
        return 'Ceppo Dietro';
      case RuoloMuta.puntaDietro:
        return 'Punta Dietro';
    }
  }

  void _previewMuta(ThemeProvider themeProvider) {
    if (_formKey.currentState!.validate()) {
      // Mostra anteprima della muta
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Anteprima Muta ${themeProvider.currentCeroName}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Numero: ${_numeroMutaController.text}'),
                Text('Posizione: ${_posizioneController.text}'),
                const SizedBox(height: 16),
                Text('Composizione:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ...RuoloMuta.values.map((ruolo) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${_getRuoloName(ruolo)}: ${_nomiControllers[ruolo]![0].text} ${_cognomiControllers[ruolo]![0].text}, ${_nomiControllers[ruolo]![1].text} ${_cognomiControllers[ruolo]![1].text}',
                    style: const TextStyle(fontSize: 12),
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      );
    }
  }

  void _saveMuta(ThemeProvider themeProvider) {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementare il salvataggio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Muta salvata per ${themeProvider.currentCeroName}!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _exportMuta(ThemeProvider themeProvider) {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementare l'esportazione come immagine
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Esportazione muta ${themeProvider.currentCeroName} (da implementare)'),
          backgroundColor: themeProvider.currentPrimaryColor,
        ),
      );
    }
  }
}