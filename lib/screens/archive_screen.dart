import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_muta/theme/theme_provider.dart';
import 'package:app_muta/widgets/cero_selector.dart';
import 'package:app_muta/models/muta_model.dart'; // Assicurati che il percorso sia corretto
import 'package:app_muta/theme/app_theme.dart'; // Per CeroType

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  int? selectedYear;
  int? comparisonYear;

  final List<int> availableYears = List.generate(15, (index) => DateTime.now().year - index); // Ultimi 15 anni

  // Dati Mock Aggiornati - SOSTITUIRE CON FETCH DA DATABASE
  final List<Muta> allMuteData = [
    // Sant'Ubaldo
    Muta(
      id: 'su_2024_calataneri', cero: CeroType.santUbaldo, nomeMuta: 'Muta Calata dei Neri', posizione: 'Inizio Calata dei Neri', anno: 2024, dataCreazione: DateTime(2024),
      stangaSinistra: [
        PersonaMuta(nome: 'Mario', cognome: 'Rossi', soprannome: 'Fulmine', ruolo: RuoloMuta.puntaAvanti, note: 'Capostanga'),
        PersonaMuta(nome: 'Paolo', cognome: 'Verdi', ruolo: RuoloMuta.ceppoAvanti),
        PersonaMuta(nome: 'Franco', cognome: 'Gialli', ruolo: RuoloMuta.ceppoDietro),
        PersonaMuta(nome: 'Simone', cognome: 'Arancio', ruolo: RuoloMuta.puntaDietro),
      ],
      stangaDestra: [
        PersonaMuta(nome: 'Luca', cognome: 'Bianchi', ruolo: RuoloMuta.puntaAvanti),
        PersonaMuta(nome: 'Giovanni', cognome: 'Neri', soprannome: 'Toro', ruolo: RuoloMuta.ceppoAvanti),
        PersonaMuta(nome: 'Andrea', cognome: 'Blu', ruolo: RuoloMuta.ceppoDietro),
        PersonaMuta(nome: 'Marco', cognome: 'Viola', ruolo: RuoloMuta.puntaDietro),
      ],
      note: 'Prima muta importante della corsa.',
    ),
    Muta(
      id: 'su_2023_calataneri', cero: CeroType.santUbaldo, nomeMuta: 'Muta Calata dei Neri', posizione: 'Inizio Calata dei Neri', anno: 2023, dataCreazione: DateTime(2023),
      stangaSinistra: [
        PersonaMuta(nome: 'Mario', cognome: 'Rossi', soprannome: 'Fulmine', ruolo: RuoloMuta.puntaAvanti, note: 'Capostanga'), // Confermato
        PersonaMuta(nome: 'Paolo', cognome: 'Verdi', ruolo: RuoloMuta.ceppoAvanti), // Confermato
        PersonaMuta(nome: 'Franco', cognome: 'Gialli', ruolo: RuoloMuta.ceppoDietro), // Confermato
        PersonaMuta(nome: 'Simone', cognome: 'Arancio', ruolo: RuoloMuta.puntaDietro), // Confermato
      ],
      stangaDestra: [
        PersonaMuta(nome: 'Sergio', cognome: 'Azzurri', soprannome: 'Lampo', ruolo: RuoloMuta.puntaAvanti), // Luca Bianchi è uscito, Sergio Azzurri è entrato
        PersonaMuta(nome: 'Giovanni', cognome: 'Neri', soprannome: 'Toro', ruolo: RuoloMuta.ceppoAvanti), // Confermato
        PersonaMuta(nome: 'Andrea', cognome: 'Blu', ruolo: RuoloMuta.ceppoDietro), // Confermato
        PersonaMuta(nome: 'Marco', cognome: 'Viola', ruolo: RuoloMuta.puntaDietro), // Confermato
      ],
    ),
    Muta(
      id: 'su_2022_calataneri', cero: CeroType.santUbaldo, nomeMuta: 'Muta Calata dei Neri', posizione: 'Inizio Calata dei Neri', anno: 2022, dataCreazione: DateTime(2022),
      stangaSinistra: [
        PersonaMuta(nome: 'Matteo', cognome: 'Bruni', ruolo: RuoloMuta.puntaAvanti), // Mario Rossi è uscito, Matteo Bruni è entrato
        PersonaMuta(nome: 'Paolo', cognome: 'Verdi', ruolo: RuoloMuta.ceppoAvanti),
        PersonaMuta(nome: 'Franco', cognome: 'Gialli', ruolo: RuoloMuta.ceppoDietro),
        PersonaMuta(nome: 'Simone', cognome: 'Arancio', ruolo: RuoloMuta.puntaDietro),
      ],
      stangaDestra: [
        PersonaMuta(nome: 'Sergio', cognome: 'Azzurri', soprannome: 'Lampo', ruolo: RuoloMuta.puntaAvanti),
        PersonaMuta(nome: 'Giovanni', cognome: 'Neri', soprannome: 'Toro', ruolo: RuoloMuta.ceppoAvanti),
        PersonaMuta(nome: 'Leonardo', cognome: 'Rosa', ruolo: RuoloMuta.ceppoDietro), // Andrea Blu è uscito, Leonardo Rosa è entrato
        PersonaMuta(nome: 'Marco', cognome: 'Viola', ruolo: RuoloMuta.puntaDietro),
      ],
    ),
    // San Giorgio
    Muta(
      id: 'sg_2024_pzagrande', cero: CeroType.sanGiorgio, nomeMuta: 'Muta Piazza Grande', posizione: 'Centro Piazza Grande', anno: 2024, dataCreazione: DateTime(2024),
      stangaSinistra: [
        PersonaMuta(nome: 'Giorgio', cognome: 'Dragoni', ruolo: RuoloMuta.puntaAvanti),
        PersonaMuta(nome: 'Umberto', cognome: 'Scudo', ruolo: RuoloMuta.ceppoAvanti),
        PersonaMuta(nome: 'Massimo', cognome: 'Elmo', ruolo: RuoloMuta.ceppoDietro),
        PersonaMuta(nome: 'Enrico', cognome: 'Cavallo', ruolo: RuoloMuta.puntaDietro),
      ],
      stangaDestra: [
        PersonaMuta(nome: 'Guido', cognome: 'Lancia', ruolo: RuoloMuta.puntaAvanti),
        PersonaMuta(nome: 'Teodoro', cognome: 'Corazza', ruolo: RuoloMuta.ceppoAvanti),
        PersonaMuta(nome: 'Stefano', cognome: 'Spada', ruolo: RuoloMuta.ceppoDietro),
        PersonaMuta(nome: 'Davide', cognome: 'Stendardo', ruolo: RuoloMuta.puntaDietro),
      ],
    ),
    Muta(
      id: 'sg_2023_pzagrande', cero: CeroType.sanGiorgio, nomeMuta: 'Muta Piazza Grande', posizione: 'Centro Piazza Grande', anno: 2023, dataCreazione: DateTime(2023),
      stangaSinistra: [
        PersonaMuta(nome: 'Giorgio', cognome: 'Dragoni', ruolo: RuoloMuta.puntaAvanti),
        PersonaMuta(nome: 'Umberto', cognome: 'Scudo', ruolo: RuoloMuta.ceppoAvanti),
        PersonaMuta(nome: 'Massimo', cognome: 'Elmo', ruolo: RuoloMuta.ceppoDietro),
        PersonaMuta(nome: 'Enrico', cognome: 'Cavallo', ruolo: RuoloMuta.puntaDietro),
      ],
      stangaDestra: [
        PersonaMuta(nome: 'Guido', cognome: 'Lancia', ruolo: RuoloMuta.puntaAvanti),
        PersonaMuta(nome: 'Teodoro', cognome: 'Corazza', ruolo: RuoloMuta.ceppoAvanti),
        PersonaMuta(nome: 'Vittorio', cognome: 'Ascia', soprannome:'Taglio', ruolo: RuoloMuta.ceppoDietro), // Stefano Spada è uscito
        PersonaMuta(nome: 'Davide', cognome: 'Stendardo', ruolo: RuoloMuta.puntaDietro),
      ],
    ),
  ];

  List<Muta> displayedMute = [];
  Map<RuoloMuta, Map<String, _ConfrontoPersona>>? comparisonResultData;

  late ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _themeProvider.addListener(_onCeroChanged);
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onCeroChanged);
    super.dispose();
  }

  void _onCeroChanged() {
    setState(() {
      selectedYear = null;
      comparisonYear = null;
      displayedMute = [];
      comparisonResultData = null;
    });
  }

  void _fetchAndDisplayMute() {
    final currentCero = Provider.of<ThemeProvider>(context, listen: false).currentCero;
    setState(() {
      displayedMute = [];
      comparisonResultData = null;

      if (selectedYear != null) {
        displayedMute = allMuteData
            .where((muta) => muta.anno == selectedYear && muta.cero == currentCero)
            .toList();

        if (comparisonYear != null) {
          final muteAnnoPrincipaleLista = allMuteData
              .where((m) => m.anno == selectedYear && m.cero == currentCero)
              .toList();
          final muteAnnoConfrontoLista = allMuteData
              .where((m) => m.anno == comparisonYear && m.cero == currentCero)
              .toList();

          if (muteAnnoPrincipaleLista.isNotEmpty && muteAnnoConfrontoLista.isNotEmpty) {
            Muta? mutaA = muteAnnoPrincipaleLista.first; // Prendi la prima muta dell'anno principale
            Muta? mutaB;

            // Cerca una muta con lo stesso nomeMuta nell'anno di confronto
            try {
              mutaB = muteAnnoConfrontoLista.firstWhere((mB) => mB.nomeMuta == mutaA.nomeMuta);
            } catch (e) {
              // Se non trovi una muta con lo stesso nome, prendi la prima dell'anno di confronto
              // Questo potrebbe non essere l'ideale se ci sono più mute con nomi diversi.
              // Una logica più avanzata potrebbe permettere all'utente di selezionare quale muta confrontare.
              mutaB = muteAnnoConfrontoLista.first;
            }
            comparisonResultData = _compareMuteDetailed(mutaA, mutaB);
          } else {
            comparisonResultData = {};
          }
          displayedMute = []; // Non mostrare la lista singola quando c'è un confronto
        }

        // Mostra un messaggio se non ci sono dati dopo il tentativo di fetch/confronto
        if (displayedMute.isEmpty && (comparisonResultData == null || comparisonResultData!.isEmpty) && selectedYear != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nessuna muta trovata per ${Provider.of<ThemeProvider>(context, listen: false).currentCeroName} nell\'anno $selectedYear per la visualizzazione o il confronto.')),
          );
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleziona un anno per visualizzare le mute.')),
        );
      }
    });
  }

  Map<RuoloMuta, Map<String, _ConfrontoPersona>> _compareMuteDetailed(Muta mutaA, Muta mutaB) {
    Map<RuoloMuta, Map<String, _ConfrontoPersona>> result = {};

    for (RuoloMuta ruolo in RuoloMuta.values) {
      Map<String, _ConfrontoPersona> stangheConfronto = {};

      // Stanga Sinistra
      PersonaMuta? pA_sinistra = mutaA.getPersonaPerRuoloEStanga(ruolo, true);
      PersonaMuta? pB_sinistra = mutaB.getPersonaPerRuoloEStanga(ruolo, true);
      stangheConfronto['Sinistra'] = _ConfrontoPersona(prima: pA_sinistra, dopo: pB_sinistra);

      // Stanga Destra
      PersonaMuta? pA_destra = mutaA.getPersonaPerRuoloEStanga(ruolo, false);
      PersonaMuta? pB_destra = mutaB.getPersonaPerRuoloEStanga(ruolo, false);
      stangheConfronto['Destra'] = _ConfrontoPersona(prima: pA_destra, dopo: pB_destra);

      result[ruolo] = stangheConfronto;
    }
    return result;
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Archivio ${themeProvider.currentCeroName}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CeroSelector(showAsPopup: true, showFullName: false),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con info cero (invariato)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: themeProvider.currentPrimaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  themeProvider.currentCeroIcon,
                  color: themeProvider.currentPrimaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Archivio storico del Cero di ${themeProvider.currentCeroName}',
                    style: TextStyle(
                      color: themeProvider.currentPrimaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Controlli di selezione anno (invariati)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seleziona Anno',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedYear,
                        decoration: InputDecoration(
                          labelText: 'Anno principale',
                          hintText: 'Scegli anno',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          prefixIcon: Icon(Icons.calendar_today,
                              color: themeProvider.currentPrimaryColor),
                        ),
                        items: availableYears.map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value;
                            if (comparisonYear == selectedYear && selectedYear != null) {
                              comparisonYear = null;
                            }
                            // Resetta i risultati quando l'anno principale cambia
                            displayedMute = [];
                            comparisonResultData = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: comparisonYear,
                        decoration: InputDecoration(
                          labelText: 'Confronta con',
                          hintText: 'Opzionale',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          prefixIcon: Icon(Icons.compare_arrows,
                              color: themeProvider.currentTheme.colorScheme.secondary),
                        ),
                        items: availableYears
                            .where((year) => year != selectedYear) // Non si può confrontare con se stesso
                            .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            comparisonYear = value;
                            // Resetta i risultati quando l'anno di confronto cambia
                            displayedMute = [];
                            comparisonResultData = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    icon: Icon(comparisonYear != null ? Icons.compare_arrows : Icons.visibility),
                    label: Text(comparisonYear != null ? 'Confronta Mute' : 'Mostra Mute'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.currentPrimaryColor,
                        foregroundColor: themeProvider.currentPrimaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )
                    ),
                    onPressed: selectedYear != null ? _fetchAndDisplayMute : null, // Abilitato solo se l'anno principale è selezionato
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Area di visualizzazione
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: (displayedMute.isEmpty && (comparisonResultData == null || comparisonResultData!.isEmpty))
                  ? Center(
                  child: Text(
                    'Seleziona un anno (e opzionalmente un anno di confronto) e clicca il pulsante per vedere i risultati.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ))
                  : SingleChildScrollView( // Permette lo scroll se il contenuto è lungo
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Se ci sono dati di confronto, mostra la vista di confronto
                    if (comparisonResultData != null && comparisonResultData!.isNotEmpty)
                      _buildComparisonView(comparisonResultData!, themeProvider, selectedYear!, comparisonYear!),
                    // Altrimenti, se ci sono mute da visualizzare (nessun confronto attivo), mostrale
                    if (displayedMute.isNotEmpty)
                      ...displayedMute.map((muta) => _MutaDisplayCard(muta: muta, themeProvider: themeProvider)).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView(Map<RuoloMuta, Map<String, _ConfrontoPersona>> data, ThemeProvider themeProvider, int annoA, int annoB) {
    List<Widget> ruoloWidgets = [];

    // Titolo del confronto
    String nomeMutaConfrontataA = "Muta Anno $annoA";
    String nomeMutaConfrontataB = "Muta Anno $annoB";

    // Tentativo di trovare i nomi delle mute confrontate (se disponibili e univoche per il confronto)
    // Questa logica assume che _compareMuteDetailed sia stata chiamata con mute specifiche.
    // Per una maggiore precisione, i nomi delle mute confrontate potrebbero essere passati a questa funzione.
    final currentCero = Provider.of<ThemeProvider>(context, listen: false).currentCero;
    try {
      final mutaConfrontataObjA = allMuteData.firstWhere((m) => m.anno == annoA && m.cero == currentCero && comparisonResultData!.isNotEmpty); // Semplificazione
      nomeMutaConfrontataA = mutaConfrontataObjA.nomeMuta;
    } catch (e) {/* non fare nulla, usa il default */}
    try {
      final mutaConfrontataObjB = allMuteData.firstWhere((m) => m.anno == annoB && m.cero == currentCero && comparisonResultData!.isNotEmpty); // Semplificazione
      nomeMutaConfrontataB = mutaConfrontataObjB.nomeMuta;
    } catch (e) {/* non fare nulla, usa il default */}


    data.forEach((ruolo, stangheDettagli) {
      List<Widget> stangaDetailWidgets = [];
      stangheDettagli.forEach((stangaNome, confrontoPersona) {
        Widget dettaglioWidget;
        TextStyle defaultStyle = DefaultTextStyle.of(context).style.copyWith(fontSize: 13);

        if (confrontoPersona.prima == null && confrontoPersona.dopo == null) {
          dettaglioWidget = Text('  $stangaNome: Nessun dato', style: defaultStyle.copyWith(color: Colors.grey));
        } else if (confrontoPersona.prima != null && confrontoPersona.dopo != null) {
          if (confrontoPersona.prima == confrontoPersona.dopo) {
            dettaglioWidget = Text('  $stangaNome: ${confrontoPersona.prima!.nomeCompleto} (Confermato)', style: defaultStyle);
          } else {
            dettaglioWidget = RichText(
              text: TextSpan(
                style: defaultStyle,
                children: <TextSpan>[
                  TextSpan(text: '  $stangaNome: '),
                  TextSpan(text: '${confrontoPersona.prima!.nomeCompleto} ', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.redAccent)),
                  const TextSpan(text: '-> ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: confrontoPersona.dopo!.nomeCompleto, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
        } else if (confrontoPersona.prima != null && confrontoPersona.dopo == null) {
          dettaglioWidget = Text('  $stangaNome: ${confrontoPersona.prima!.nomeCompleto} (Uscito)', style: defaultStyle.copyWith(color: Colors.redAccent));
        } else { // prima == null && dopo != null
          dettaglioWidget = Text('  $stangaNome: ${confrontoPersona.dopo!.nomeCompleto} (Entrato)', style: defaultStyle.copyWith(color: Colors.green, fontWeight: FontWeight.bold));
        }
        stangaDetailWidgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: dettaglioWidget,
        ));
      });

      ruoloWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Formattazione del nome del ruolo per leggibilità
                    ruolo.toString().split('.').last.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim().capitalizeFirstLetter(),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: themeProvider.currentPrimaryColor),
                  ),
                  const Divider(height: 10, thickness: 0.5),
                  ...stangaDetailWidgets,
                ],
              ),
            ),
          ),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
          child: Text(
              'Confronto: "$nomeMutaConfrontataA" ($annoA) vs "$nomeMutaConfrontataB" ($annoB)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 19)
          ),
        ),
        ...ruoloWidgets
      ],
    );
  }
}

// Helper class per il confronto di una singola posizione
class _ConfrontoPersona {
  final PersonaMuta? prima; // Persona nell'anno principale
  final PersonaMuta? dopo;  // Persona nell'anno di confronto

  _ConfrontoPersona({this.prima, this.dopo});
}

// Widget per visualizzare una singola Muta
class _MutaDisplayCard extends StatelessWidget {
  final Muta muta;
  final ThemeProvider themeProvider;

  const _MutaDisplayCard({required this.muta, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: themeProvider.currentPrimaryColor.withOpacity(0.03), // Sfondo leggermente colorato
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${muta.nomeMuta} (${muta.posizione}) - Anno: ${muta.anno}',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: themeProvider.currentPrimaryColor),
            ),
            if (muta.note != null && muta.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 8.0),
                child: Text('Note Muta: ${muta.note}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54)),
              ),
            const Divider(height: 15, thickness: 0.5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonna Stanga Sinistra
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stanga Sinistra', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      ...RuoloMuta.values.map((ruolo) {
                        PersonaMuta? p = muta.getPersonaPerRuoloEStanga(ruolo, true);
                        return _buildPersonaRuoloRow(ruolo, p);
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(width: 16), // Spazio tra le stanghe
                // Colonna Stanga Destra
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stanga Destra', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      ...RuoloMuta.values.map((ruolo) {
                        PersonaMuta? p = muta.getPersonaPerRuoloEStanga(ruolo, false);
                        return _buildPersonaRuoloRow(ruolo, p);
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaRuoloRow(RuoloMuta ruolo, PersonaMuta? persona) {
    // Formattazione del nome del ruolo per leggibilità (es. "Punta Avanti")
    String ruoloFormatted = ruolo.toString().split('.').last.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim().capitalizeFirstLetter();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Aumentato padding verticale
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$ruoloFormatted:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5), // Leggermente più grande
          ),
          Text(
            persona?.nomeCompleto ?? '-', // Mostra il nome completo (con soprannome)
            style: const TextStyle(fontSize: 13.5),
          ),
          if (persona?.note != null && persona!.note!.isNotEmpty) // Mostra le note della persona se presenti
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                '(${persona.note})', // Nota specifica della persona
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11.5, color: Colors.grey.shade700),
              ),
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
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
