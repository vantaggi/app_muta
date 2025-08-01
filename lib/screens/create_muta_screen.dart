import 'dart:typed_data';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:app_muta/models/ceraiolo_model.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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


  List<DragAndDropList> _lists = [];
  List<Ceraiolo> _allCeraioli = [];

  final GlobalKey _renderKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadCeraioli();
  }

  Future<void> _loadCeraioli() async {
    final ceraioli = await DatabaseHelper.instance.readAllCeraioli();
    setState(() {
      _allCeraioli = ceraioli;
      _lists = [
        DragAndDropList(
          header: const Text('Disponibili'),
          children: _allCeraioli.map((c) => DragAndDropItem(child: Text(c.nome))).toList(),
        ),
        ...RuoloMuta.values.map((ruolo) => DragAndDropList(
          header: Text(ruolo.toString().split('.').last),
          children: [],
        )),
        ...RuoloMuta.values.map((ruolo) => DragAndDropList(
          header: Text(ruolo.toString().split('.').last),
          children: [],
        )),
      ];
    });
  }

  Widget _buildVisualBuilder() {
    bool isMutaComplete = _lists.sublist(1).every((list) => list.children.isNotEmpty);

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: DragAndDropLists(
                  children: [_lists[0]],
                  onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
                    // This is a simplified reorder logic, as we only have one list here
                    setState(() {
                      final movedItem = _lists[0].children.removeAt(oldItemIndex);
                      _lists[0].children.insert(newItemIndex, movedItem);
                    });
                  },
                  onListReorder: (int oldListIndex, int newListIndex) {},
                ),
              ),
              Expanded(
                child: Column(
                  children: RuoloMuta.values.map((ruolo) {
                    final listIndex = 1 + ruolo.index;
                    return Expanded(
                      child: DragAndDropLists(
                        children: [_lists[listIndex]],
                        onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
                           setState(() {
                              final movedItem = _lists[listIndex].children.removeAt(oldItemIndex);
                              _lists[listIndex].children.insert(newItemIndex, movedItem);
                           });
                        },
                        onListReorder: (int oldListIndex, int newListIndex) {},
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: Column(
                  children: RuoloMuta.values.map((ruolo) {
                    final listIndex = 1 + RuoloMuta.values.length + ruolo.index;
                    return Expanded(
                      child: DragAndDropLists(
                        children: [_lists[listIndex]],
                        onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
                           setState(() {
                              final movedItem = _lists[listIndex].children.removeAt(oldItemIndex);
                              _lists[listIndex].children.insert(newItemIndex, movedItem);
                           });
                        },
                        onListReorder: (int oldListIndex, int newListIndex) {},
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _previewMuta(context.read<ThemeProvider>()),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Anteprima'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isMutaComplete ? () => _saveMuta(context.read<ThemeProvider>()) : null,
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text('Salva Muta'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomeMutaController.dispose();
    _posizioneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _noteMutaController.dispose();
    _annoController.dispose();
    super.dispose();
  }

  Muta? _collectMutaData(ThemeProvider themeProvider) {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, correggi gli errori nel form.'), backgroundColor: Colors.orange),
      );
      return null;
    }

    final stangaSinistra = _stanghe[1].children.map((item) {
      final ceraiolo = _allCeraioli.firstWhere((c) => c.nome == (item.child as Text).data);
      // This is not robust, we need a better way to get the RuoloMuta
      final ruolo = RuoloMuta.values[_stanghe[1].children.indexOf(item)];
      return PersonaMuta(
        nome: ceraiolo.nome,
        cognome: ceraiolo.cognome,
        soprannome: ceraiolo.soprannome,
        ruolo: ruolo,
      );
    }).toList();

    final stangaDestra = _stanghe[2].children.map((item) {
      final ceraiolo = _allCeraioli.firstWhere((c) => c.nome == (item.child as Text).data);
      final ruolo = RuoloMuta.values[_stanghe[2].children.indexOf(item)];
      return PersonaMuta(
        nome: ceraiolo.nome,
        cognome: ceraiolo.cognome,
        soprannome: ceraiolo.soprannome,
        ruolo: ruolo,
      );
    }).toList();

    if (stangaSinistra.length != 4 || stangaDestra.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le stanghe devono avere 4 persone.'), backgroundColor: Colors.red),
      );
      return null;
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
            TextButton(onPressed: () => _shareWebLink(muta), child: const Text('Share Link')),
            ElevatedButton(onPressed: () => _exportMutaAsPdf(muta), child: const Text('Esporta PDF')),
          ],
        ),
      );
    }
  }

  void _shareWebLink(Muta muta) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Condivisione link non ancora implementata.')),
    );
  }

  Future<void> _exportMutaAsPdf(Muta muta) async {
    final pdf = await _generatePdf(muta);
    await Printing.sharePdf(bytes: pdf, filename: 'muta_${muta.id}.pdf');
  }

  Future<Uint8List> _generatePdf(Muta muta) async {
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
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Stanga Sinistra', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        ...muta.stangaSinistra.map((p) => pw.Text('${p.ruoloDescrizione}: ${p.nomeCompleto}')),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Stanga Destra', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        ...muta.stangaDestra.map((p) => pw.Text('${p.ruoloDescrizione}: ${p.nomeCompleto}')),
                      ],
                    ),
                  ),
                ],
              ),
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
            child: _buildVisualBuilder(),
          ),
        );
      },
    );
  }

  _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      // Prevent adding more than one item to a stanga role list
      if (newListIndex > 0 && _lists[newListIndex].children.isNotEmpty) {
        return;
      }
      final movedItem = _lists[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  Muta? _collectMutaData(ThemeProvider themeProvider) {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, correggi gli errori nel form.'), backgroundColor: Colors.orange),
      );
      return null;
    }

    final stangaSinistra = _lists.sublist(1, 5).map((list) {
      if (list.children.isEmpty) {
        return null;
      }
      final ceraiolo = _allCeraioli.firstWhere((c) => c.nome == (list.children.first.child as Text).data);
      final ruolo = RuoloMuta.values[_lists.sublist(1, 5).indexOf(list)];
      return PersonaMuta(
        nome: ceraiolo.nome,
        cognome: ceraiolo.cognome,
        soprannome: ceraiolo.soprannome,
        ruolo: ruolo,
      );
    }).where((p) => p != null).cast<PersonaMuta>().toList();

    final stangaDestra = _lists.sublist(5).map((list) {
      if (list.children.isEmpty) {
        return null;
      }
      final ceraiolo = _allCeraioli.firstWhere((c) => c.nome == (list.children.first.child as Text).data);
      final ruolo = RuoloMuta.values[_lists.sublist(5).indexOf(list)];
      return PersonaMuta(
        nome: ceraiolo.nome,
        cognome: ceraiolo.cognome,
        soprannome: ceraiolo.soprannome,
        ruolo: ruolo,
      );
    }).where((p) => p != null).cast<PersonaMuta>().toList();


    if (stangaSinistra.length != 4 || stangaDestra.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le stanghe devono avere 4 persone.'), backgroundColor: Colors.red),
      );
      return null;
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
      stangaSinistra: stangaSinistra,
      stangaDestra: stangaDestra,
      dataCreazione: DateTime.now(),
      anno: anno,
      note: _noteMutaController.text.trim().isNotEmpty ? _noteMutaController.text.trim() : null,
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
