import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_muta/theme/theme_provider.dart';
import 'package:app_muta/widgets/cero_selector.dart';
import 'package:app_muta/models/muta_model.dart';
import 'package:app_muta/services/database_helper.dart';
import 'package:app_muta/theme/app_theme.dart'; // Per CeroType
import 'dart:ui' as ui; // Per Image rendering
import 'package:flutter/rendering.dart';
import 'dart:typed_data'; // Import per ByteData e Uint8List
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CreateMutaScreen extends StatefulWidget {
  const CreateMutaScreen({super.key});

  @override
  State<CreateMutaScreen> createState() => _CreateMutaScreenState();
}

class _CreateMutaScreenState extends State<CreateMutaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeMutaController = TextEditingController();
  final _posizioneController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _noteMutaController = TextEditingController(); // Note generali per la muta
  final _annoController = TextEditingController(text: DateTime.now().year.toString());


  // Controllers per le persone: [Nome, Cognome, Soprannome, NotePersona]
  // Un set di controller per ogni posizione (4 ruoli x 2 stanghe = 8 posizioni)
  // Stanga Sinistra
  final Map<RuoloMuta, List<TextEditingController>> _stangaSinistraControllers = {
    RuoloMuta.puntaAvanti: List.generate(4, (_) => TextEditingController()),
    RuoloMuta.ceppoAvanti: List.generate(4, (_) => TextEditingController()),
    RuoloMuta.ceppoDietro: List.generate(4, (_) => TextEditingController()),
    RuoloMuta.puntaDietro: List.generate(4, (_) => TextEditingController()),
  };
  // Stanga Destra
  final Map<RuoloMuta, List<TextEditingController>> _stangaDestraControllers = {
    RuoloMuta.puntaAvanti: List.generate(4, (_) => TextEditingController()),
    RuoloMuta.ceppoAvanti: List.generate(4, (_) => TextEditingController()),
    RuoloMuta.ceppoDietro: List.generate(4, (_) => TextEditingController()),
    RuoloMuta.puntaDietro: List.generate(4, (_) => TextEditingController()),
  };

  final GlobalKey _renderKey = GlobalKey();
  int _currentStep = 0;


  @override
  void dispose() {
    _nomeMutaController.dispose();
    _posizioneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _noteMutaController.dispose();
    _annoController.dispose();

    _stangaSinistraControllers.values.forEach((list) => list.forEach((c) => c.dispose()));
    _stangaDestraControllers.values.forEach((list) => list.forEach((c) => c.dispose()));
    super.dispose();
  }

  Widget _buildPersonaInputFields(RuoloMuta ruolo, bool isSinistra, ThemeProvider themeProvider) {
    final controllers = isSinistra ? _stangaSinistraControllers[ruolo]! : _stangaDestraControllers[ruolo]!;
    // controllers[0] = Nome, controllers[1] = Cognome, controllers[2] = Soprannome, controllers[3] = Note Persona

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controllers[0], // Nome
          decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder(), isDense: true),
          validator: (value) => (value == null || value.isEmpty) ? 'Richiesto' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controllers[1], // Cognome
          decoration: const InputDecoration(labelText: 'Cognome', border: OutlineInputBorder(), isDense: true),
          validator: (value) => (value == null || value.isEmpty) ? 'Richiesto' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controllers[2], // Soprannome
          decoration: const InputDecoration(labelText: 'Soprannome (Opz.)', border: OutlineInputBorder(), isDense: true),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controllers[3], // Note Persona
          decoration: const InputDecoration(labelText: 'Note Persona (Opz.)', border: OutlineInputBorder(), isDense: true),
        ),
      ],
    );
  }

  Widget _buildStangaSection(String titoloStanga, bool isSinistra, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            titoloStanga,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: themeProvider.currentPrimaryColor),
          ),
        ),
        ...RuoloMuta.values.map((ruolo) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ruolo.toString().split('.').last.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim().capitalizeFirstLetter(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  _buildPersonaInputFields(ruolo, isSinistra, themeProvider),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }


  Muta? _collectMutaData(ThemeProvider themeProvider) {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, correggi gli errori nel form.'), backgroundColor: Colors.orange),
      );
      return null;
    }

    List<PersonaMuta> sSinistra = [];
    List<PersonaMuta> sDestra = [];

    for (RuoloMuta ruolo in RuoloMuta.values) {
      // Stanga Sinistra
      final sinControllers = _stangaSinistraControllers[ruolo]!;
      sSinistra.add(PersonaMuta(
        nome: sinControllers[0].text.trim(),
        cognome: sinControllers[1].text.trim(),
        soprannome: sinControllers[2].text.trim().isNotEmpty ? sinControllers[2].text.trim() : null,
        ruolo: ruolo,
        note: sinControllers[3].text.trim().isNotEmpty ? sinControllers[3].text.trim() : null,
      ));
      // Stanga Destra
      final desControllers = _stangaDestraControllers[ruolo]!;
      sDestra.add(PersonaMuta(
        nome: desControllers[0].text.trim(),
        cognome: desControllers[1].text.trim(),
        soprannome: desControllers[2].text.trim().isNotEmpty ? desControllers[2].text.trim() : null,
        ruolo: ruolo,
        note: desControllers[3].text.trim().isNotEmpty ? desControllers[3].text.trim() : null,
      ));
    }

    int? anno = int.tryParse(_annoController.text.trim());
    if (anno == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anno non valido.'), backgroundColor: Colors.red),
      );
      return null;
    }


    double? latitude = double.tryParse(_latitudeController.text.trim());
    double? longitude = double.tryParse(_longitudeController.text.trim());

    return Muta(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID Provvisorio, il backend dovrebbe generarne uno univoco
      cero: themeProvider.currentCero,
      nomeMuta: _nomeMutaController.text.trim(),
      posizione: _posizioneController.text.trim(),
      latitude: latitude,
      longitude: longitude,
      stangaSinistra: sSinistra,
      stangaDestra: sDestra,
      dataCreazione: DateTime.now(),
      anno: anno,
      note: _noteMutaController.text.trim().isNotEmpty ? _noteMutaController.text.trim() : null,
    );
  }

  void _previewMuta(ThemeProvider themeProvider) {
    final muta = _collectMutaData(themeProvider);
    if (muta != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Anteprima: ${muta.nomeMuta} (${muta.anno})'),
          content: SingleChildScrollView( // Aggiunto SingleChildScrollView per contenuti lunghi
              child: _MutaVisualizer(muta: muta, themeProvider: themeProvider)
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Chiudi')),
          ],
        ),
      );
    }
  }

  Future<void> _saveMuta(ThemeProvider themeProvider) async {
    final muta = _collectMutaData(themeProvider);
    if (muta != null) {
      try {
        await DatabaseHelper.instance.insertMuta(muta);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Muta "${muta.nomeMuta}" salvata con successo!'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      } catch (e) {
        print("Errore salvataggio muta: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante il salvataggio della muta: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset(); // Questo resetta lo stato di validazione ma non i valori dei controller
    // Resetta i controller manualmente
    _nomeMutaController.clear();
    _posizioneController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _noteMutaController.clear();
    _annoController.text = DateTime.now().year.toString(); // Reimposta all'anno corrente
    _stangaSinistraControllers.values.forEach((list) => list.forEach((c) => c.clear()));
    _stangaDestraControllers.values.forEach((list) => list.forEach((c) => c.clear()));
    setState(() {
      _currentStep = 0;
    });
  }


  Future<void> _exportMuta(ThemeProvider themeProvider) async {
    final muta = _collectMutaData(themeProvider);
    if (muta != null) {
      try {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              Future.delayed(const Duration(milliseconds: 500), () async {
                try {
                  RenderRepaintBoundary boundary = _renderKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                  ui.Image image = await boundary.toImage(pixelRatio: 2.5); // Aumentato pixelRatio per qualità
                  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

                  if (byteData == null) {
                    throw Exception("Impossibile convertire l'immagine in ByteData.");
                  }
                  Uint8List pngBytes = byteData.buffer.asUint8List();

                  Navigator.pop(dialogContext);

                  final directory = await getTemporaryDirectory();
                  final imagePath = '${directory.path}/muta_${muta.id}_${DateTime.now().millisecondsSinceEpoch}.png';
                  final imageFile = File(imagePath);
                  await imageFile.writeAsBytes(pngBytes);
                  await Share.shareXFiles([XFile(imageFile.path)], text: 'Muta: ${muta.nomeMuta} (${muta.anno}) - Cero di ${muta.ceroNome}');

                } catch (e) {
                  print("Errore durante la cattura o condivisione dell'immagine: $e");
                  if (mounted && dialogContext.mounted) { // Controlla se il dialog è ancora montato
                    Navigator.pop(dialogContext);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore generazione/condivisione immagine: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                }
              });
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: RepaintBoundary(
                  key: _renderKey,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: _MutaVisualizer(muta: muta, themeProvider: themeProvider, forExport: true),
                  ),
                ),
              );
            });
      } catch (e) {
        print("Errore avvio esportazione: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante l\'avvio dell\'esportazione: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
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
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 3) {
                  setState(() {
                    _currentStep += 1;
                  });
                } else {
                  _saveMuta(themeProvider);
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                }
              },
              steps: [
                Step(
                  title: const Text('Informazioni Muta'),
                  content: Column(
                    children: [
                      TextFormField(
                        controller: _nomeMutaController,
                        decoration: const InputDecoration(labelText: 'Nome Muta (es. Muta Ospedale)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.label_important_outline)),
                        validator: (v) => (v == null || v.isEmpty) ? 'Nome muta richiesto' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start, // Allinea i campi se hanno altezze diverse
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _posizioneController,
                              decoration: const InputDecoration(labelText: 'Posizione Geografica', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined)),
                              validator: (v) => (v == null || v.isEmpty) ? 'Posizione richiesta' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _annoController,
                              decoration: const InputDecoration(labelText: 'Anno', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today_outlined)),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Anno richiesto';
                                if (int.tryParse(v) == null) return 'Anno non valido';
                                if (v.length != 4) return 'Formato YYYY'; // Anno a 4 cifre
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latitudeController,
                              decoration: const InputDecoration(labelText: 'Latitudine', border: OutlineInputBorder(), prefixIcon: Icon(Icons.gps_fixed)),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _longitudeController,
                              decoration: const InputDecoration(labelText: 'Longitudine', border: OutlineInputBorder(), prefixIcon: Icon(Icons.gps_fixed)),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Stanga Sinistra'),
                  content: _buildStangaSection('Stanga Sinistra', true, themeProvider),
                ),
                Step(
                  title: const Text('Stanga Destra'),
                  content: _buildStangaSection('Stanga Destra', false, themeProvider),
                ),
                Step(
                  title: const Text('Note & Salva'),
                  content: Column(
                    children: [
                      TextFormField(
                        controller: _noteMutaController,
                        decoration: const InputDecoration(labelText: 'Note Generali Muta (Opz.)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.notes_outlined), hintText: "Es. 'Muta veloce', 'Fare attenzione al tombino'"),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _previewMuta(themeProvider),
                              icon: const Icon(Icons.visibility_outlined),
                              label: const Text('Anteprima'),
                              style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Aumentato padding
                                  side: BorderSide(color: themeProvider.currentPrimaryColor),
                                  foregroundColor: themeProvider.currentPrimaryColor,
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _saveMuta(themeProvider),
                              icon: const Icon(Icons.save_alt_outlined),
                              label: const Text('Salva Muta'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.currentPrimaryColor,
                                  foregroundColor: themeProvider.currentPrimaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Aumentato padding
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _exportMuta(themeProvider),
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Esporta come Immagine'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.currentTheme.colorScheme.secondary, // Usa colore secondario per distinguere
                              foregroundColor: themeProvider.currentTheme.colorScheme.secondary.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Aumentato padding
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Widget separato per visualizzare la muta (usato per anteprima ed esportazione)
class _MutaVisualizer extends StatelessWidget {
  final Muta muta;
  final ThemeProvider themeProvider;
  final bool forExport; // Per adattare leggermente lo stile per l'esportazione

  const _MutaVisualizer({required this.muta, required this.themeProvider, this.forExport = false});

  @override
  Widget build(BuildContext context) {
    // Definisci gli stili di base
    TextStyle baseStyle = TextStyle(
      fontSize: forExport ? 11 : 12,
      color: forExport ? Colors.black : Theme.of(context).textTheme.bodyMedium?.color,
      height: 1.3, // Interlinea
    );
    TextStyle boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
    TextStyle titleStyle = boldStyle.copyWith(
        fontSize: baseStyle.fontSize! + (forExport ? 3 : 4),
        color: forExport ? Colors.black : themeProvider.currentPrimaryColor
    );
    TextStyle stangaTitleStyle = boldStyle.copyWith(
      fontSize: baseStyle.fontSize! + (forExport ? 2 : 3),
      decoration: TextDecoration.underline,
      decorationColor: forExport ? Colors.black54 : themeProvider.currentPrimaryColor.withOpacity(0.7),
      decorationThickness: 1.5,
    );
    TextStyle ruoloStyle = baseStyle.copyWith(fontWeight: FontWeight.w600, fontSize: baseStyle.fontSize! + (forExport ? 0 : 1));
    TextStyle nomeStyle = baseStyle;
    TextStyle noteStyle = baseStyle.copyWith(fontStyle: FontStyle.italic, fontSize: baseStyle.fontSize! - (forExport ? 1.5 : 1), color: forExport ? Colors.grey.shade700 : Colors.grey.shade600);


    return Container(
      padding: EdgeInsets.all(forExport ? 12 : 0), // Più padding per l'export
      width: forExport ? 400 : null, // Larghezza fissa per l'export per consistenza
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center( // Centra il titolo
            child: Padding(
              padding: EdgeInsets.only(bottom: forExport ? 6.0 : 8.0),
              child: Text(
                '${muta.nomeMuta} (${muta.anno})',
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Center( // Centra il cero
            child: Text(
              'Cero di ${muta.ceroNome}',
              style: boldStyle.copyWith(fontSize: baseStyle.fontSize! + (forExport ? 1 : 2), color: forExport ? Colors.black87 : themeProvider.currentPrimaryColor.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ),
          if(!forExport && muta.posizione.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Center(child: Text('Luogo: ${muta.posizione}', style: baseStyle, textAlign: TextAlign.center)),
            ),
          if (muta.note != null && muta.note!.isNotEmpty && !forExport)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 6.0),
              child: Center(child: Text('Note Muta: ${muta.note}', style: noteStyle, textAlign: TextAlign.center,)),
            ),
          SizedBox(height: forExport ? 10 : 15),

          // Qui la rappresentazione grafica con CustomPaint sarebbe ideale.
          // Per ora, manteniamo una struttura a colonne.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spazio tra le stanghe
            children: [
              // Stanga Sinistra
              Expanded(
                child: Column(
                  crossAxisAlignment: forExport ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: forExport ? 4.0 : 6.0),
                      child: Text('Stanga Sinistra', style: stangaTitleStyle, textAlign: forExport ? TextAlign.center : TextAlign.start),
                    ),
                    ...muta.stangaSinistra.map((p) => _buildPersonaVisualizer(p, ruoloStyle, nomeStyle, noteStyle, forExport)),
                  ],
                ),
              ),
              // Spazio centrale che simula la tavola
              SizedBox(width: forExport ? 12 : 20),
              // Stanga Destra
              Expanded(
                child: Column(
                  crossAxisAlignment: forExport ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: forExport ? 4.0 : 6.0),
                      child: Text('Stanga Destra', style: stangaTitleStyle, textAlign: forExport ? TextAlign.center : TextAlign.start),
                    ),
                    ...muta.stangaDestra.map((p) => _buildPersonaVisualizer(p, ruoloStyle, nomeStyle, noteStyle, forExport)),
                  ],
                ),
              ),
            ],
          ),
          if (forExport) ...[ // Aggiungi un piccolo piè di pagina per l'esportazione
            SizedBox(height: 15),
            Center(
              child: Text(
                'App Muta - Generato il ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildPersonaVisualizer(PersonaMuta persona, TextStyle ruoloStyle, TextStyle nomeStyle, TextStyle noteStyle, bool forExport) {
    String ruoloFormatted = persona.ruolo.toString().split('.').last.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim().capitalizeFirstLetter();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: forExport ? 2.5 : 4.0),
      child: Column(
        crossAxisAlignment: forExport ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text('$ruoloFormatted:', style: ruoloStyle, textAlign: forExport ? TextAlign.center : TextAlign.start),
          Text(persona.nomeCompleto, style: nomeStyle, textAlign: forExport ? TextAlign.center : TextAlign.start),
          if (persona.note != null && persona.note!.isNotEmpty && !forExport) // Note persona solo in anteprima app
            Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: Text('(${persona.note})', style: noteStyle, textAlign: forExport ? TextAlign.center : TextAlign.start),
            ),
        ],
      ),
    );
  }
}


// Estensione per capitalizzare la prima lettera di una stringa
extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}"; // Capitalizza solo la prima lettera dell'intera stringa
  }
}
