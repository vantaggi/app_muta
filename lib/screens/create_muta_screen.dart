import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muta_manager/theme/theme_provider.dart';
import 'package:muta_manager/widgets/cero_selector.dart';
import 'package:muta_manager/models/muta_model.dart';
import 'package:muta_manager/services/database_helper.dart';
import 'package:muta_manager/theme/app_theme.dart'; // Per CeroType
import 'dart:ui' as ui; // Per Image rendering
import 'package:muta_manager/models/ceraiolo_model.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data'; // Import per ByteData e Uint8List
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:geocoding/geocoding.dart';
import 'package:muta_manager/utils/export_helper.dart';
import 'package:muta_manager/widgets/muta_visualizer.dart';
import 'package:muta_manager/utils/extensions.dart';


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
  bool _isSaving = false;


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
        FutureBuilder<List<Ceraiolo>>(
          future: DatabaseHelper.instance.readAllCeraioliByCero(themeProvider.currentCero),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Nessun ceraiolo trovato per questo cero.");
            }
            final ceraioli = snapshot.data!;
            return DropdownSearch<Ceraiolo>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Nome",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              items: ceraioli,
              itemAsString: (Ceraiolo c) => c.nomeCompleto,
              onChanged: (Ceraiolo? data) {
                if (data != null) {
                  controllers[0].text = data.nome;
                  controllers[1].text = data.cognome;
                  controllers[2].text = data.soprannome ?? '';
                }
              },
            );
          },
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
          content: SingleChildScrollView(
            child: MutaVisualizer(muta: muta, themeProvider: themeProvider),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Chiudi')),
            ElevatedButton(onPressed: () => ExportHelper.exportMutaAsPdf(muta), child: const Text('Esporta PDF')),
          ],
        ),
      );
    }
  }

  Future<void> _saveMuta(ThemeProvider themeProvider) async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, correggi gli errori nel form.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Geocoding
      if (_latitudeController.text.isEmpty && _longitudeController.text.isEmpty && _posizioneController.text.isNotEmpty) {
        try {
          final address = '${_posizioneController.text}, Gubbio';
          final locations = await locationFromAddress(address);
          if (locations.isNotEmpty) {
            _latitudeController.text = locations.first.latitude.toString();
            _longitudeController.text = locations.first.longitude.toString();
            if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coordinate trovate per l\'indirizzo.'), backgroundColor: Colors.blue),
              );
            }
          } else {
            throw Exception('No coordinates found');
          }
        } catch (e) {
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Indirizzo non trovato: $e'), backgroundColor: Colors.orange),
            );
          }
          // Stop saving if address is not found.
          setState(() {
            _isSaving = false;
          });
          return;
        }
      }

      final muta = _collectMutaData(themeProvider);
      if (muta != null) {
        await DatabaseHelper.instance.insertMuta(muta);
        if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Muta "${muta.nomeMuta}" salvata con successo!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Pop with true on success
        }
      }
    } catch (e) {
      print("Errore salvataggio muta: $e");
      if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore durante il salvataggio della muta: $e'), backgroundColor: Colors.red),
          );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
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
      await ExportHelper.exportMutaAsImage(context, muta, themeProvider);
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
                  content: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nomeMutaController,
                            decoration: const InputDecoration(labelText: 'Nome Muta (es. Muta Ospedale)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.label_important_outline)),
                            validator: (v) => (v == null || v.isEmpty) ? 'Nome muta richiesto' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    if (v.length != 4) return 'Formato YYYY';
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
                  ),
                ),
                Step(
                  title: const Text('Stanga Sinistra'),
                  content: Column(
                    children: RuoloMuta.values.map((ruolo) {
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
                              _buildPersonaInputFields(ruolo, true, themeProvider),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Step(
                  title: const Text('Stanga Destra'),
                  content: Column(
                    children: RuoloMuta.values.map((ruolo) {
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
                              _buildPersonaInputFields(ruolo, false, themeProvider),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
                              onPressed: _isSaving ? null : () => _saveMuta(themeProvider),
                              icon: const Icon(Icons.save_alt_outlined),
                              label: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Salva Muta'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.currentPrimaryColor,
                                  foregroundColor: themeProvider.currentPrimaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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

