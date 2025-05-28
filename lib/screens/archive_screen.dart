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

  // Dati Mock - SOSTITUIRE CON FETCH DA DATABASE (es. Firebase)
  // Utilizza i modelli Muta e PersonaMuta
  final List<Muta> allMuteData = [
    // Sant'Ubaldo
    Muta(id: 'su_2024_m1', cero: CeroType.santUbaldo, numeroMuta: 1, posizione: 'Calata dei Neri', anno: 2024, dataCreazione: DateTime(2024), persone: [
      PersonaMuta(nome: 'Mario', cognome: 'Rossi', ruolo: RuoloMuta.puntaAvanti), PersonaMuta(nome: 'Luca', cognome: 'Bianchi', ruolo: RuoloMuta.puntaAvanti),
      PersonaMuta(nome: 'Paolo', cognome: 'Verdi', ruolo: RuoloMuta.ceppoAvanti), PersonaMuta(nome: 'Giovanni', cognome: 'Neri', ruolo: RuoloMuta.ceppoAvanti),
      PersonaMuta(nome: 'Franco', cognome: 'Gialli', ruolo: RuoloMuta.ceppoDietro), PersonaMuta(nome: 'Andrea', cognome: 'Blu', ruolo: RuoloMuta.ceppoDietro),
      PersonaMuta(nome: 'Simone', cognome: 'Arancio', ruolo: RuoloMuta.puntaDietro), PersonaMuta(nome: 'Marco', cognome: 'Viola', ruolo: RuoloMuta.puntaDietro),
    ]),
    Muta(id: 'su_2023_m1', cero: CeroType.santUbaldo, numeroMuta: 1, posizione: 'Calata dei Neri', anno: 2023, dataCreazione: DateTime(2023), persone: [
      PersonaMuta(nome: 'Mario', cognome: 'Rossi', ruolo: RuoloMuta.puntaAvanti), PersonaMuta(nome: 'Sergio', cognome: 'Azzurri', ruolo: RuoloMuta.puntaAvanti), // Luca è uscito, Sergio è entrato
      PersonaMuta(nome: 'Paolo', cognome: 'Verdi', ruolo: RuoloMuta.ceppoAvanti), PersonaMuta(nome: 'Giovanni', cognome: 'Neri', ruolo: RuoloMuta.ceppoAvanti),
      PersonaMuta(nome: 'Franco', cognome: 'Gialli', ruolo: RuoloMuta.ceppoDietro), PersonaMuta(nome: 'Andrea', cognome: 'Blu', ruolo: RuoloMuta.ceppoDietro),
      PersonaMuta(nome: 'Simone', cognome: 'Arancio', ruolo: RuoloMuta.puntaDietro), PersonaMuta(nome: 'Marco', cognome: 'Viola', ruolo: RuoloMuta.puntaDietro),
    ]),
    Muta(id: 'su_2024_m2', cero: CeroType.santUbaldo, numeroMuta: 2, posizione: 'Via dei Consoli', anno: 2024, dataCreazione: DateTime(2024), persone: [
      PersonaMuta(nome: 'Luigi', cognome: 'Rizzo', ruolo: RuoloMuta.puntaAvanti), PersonaMuta(nome: 'Antonio', cognome: 'Gallo', ruolo: RuoloMuta.puntaAvanti),
      PersonaMuta(nome: 'Giuseppe', cognome: 'Conte', ruolo: RuoloMuta.ceppoAvanti), PersonaMuta(nome: 'Salvatore', cognome: 'Esposito', ruolo: RuoloMuta.ceppoAvanti),
      PersonaMuta(nome: 'Roberto', cognome: 'Mancini', ruolo: RuoloMuta.ceppoDietro), PersonaMuta(nome: 'Claudio', cognome: 'Lotito', ruolo: RuoloMuta.ceppoDietro),
      PersonaMuta(nome: 'Fabio', cognome: 'Capello', ruolo: RuoloMuta.puntaDietro), PersonaMuta(nome: 'Walter', cognome: 'Mazzarri', ruolo: RuoloMuta.puntaDietro),
    ]),
    // San Giorgio
    Muta(id: 'sg_2024_m1', cero: CeroType.sanGiorgio, numeroMuta: 1, posizione: 'Piazza Grande', anno: 2024, dataCreazione: DateTime(2024), persone: [
      PersonaMuta(nome: 'Giorgio', cognome: 'Dragoni', ruolo: RuoloMuta.puntaAvanti), PersonaMuta(nome: 'Guido', cognome: 'Lancia', ruolo: RuoloMuta.puntaAvanti),
      PersonaMuta(nome: 'Umberto', cognome: 'Scudo', ruolo: RuoloMuta.ceppoAvanti), PersonaMuta(nome: 'Teodoro', cognome: 'Corazza', ruolo: RuoloMuta.ceppoAvanti),
      PersonaMuta(nome: 'Massimo', cognome: 'Elmo', ruolo: RuoloMuta.ceppoDietro), PersonaMuta(nome: 'Stefano', cognome: 'Spada', ruolo: RuoloMuta.ceppoDietro),
      PersonaMuta(nome: 'Enrico', cognome: 'Cavallo', ruolo: RuoloMuta.puntaDietro), PersonaMuta(nome: 'Davide', cognome: 'Stendardo', ruolo: RuoloMuta.puntaDietro),
    ]),
    Muta(id: 'sg_2023_m1', cero: CeroType.sanGiorgio, numeroMuta: 1, posizione: 'Piazza Grande', anno: 2023, dataCreazione: DateTime(2023), persone: [
      PersonaMuta(nome: 'Giorgio', cognome: 'Dragoni', ruolo: RuoloMuta.puntaAvanti), PersonaMuta(nome: 'Guido', cognome: 'Lancia', ruolo: RuoloMuta.puntaAvanti),
      PersonaMuta(nome: 'Umberto', cognome: 'Scudo', ruolo: RuoloMuta.ceppoAvanti), PersonaMuta(nome: 'Teodoro', cognome: 'Corazza', ruolo: RuoloMuta.ceppoAvanti),
      PersonaMuta(nome: 'Massimo', cognome: 'Elmo', ruolo: RuoloMuta.ceppoDietro), PersonaMuta(nome: 'Vittorio', cognome: 'Ascia', ruolo: RuoloMuta.ceppoDietro), // Stefano è uscito, Vittorio è entrato
      PersonaMuta(nome: 'Enrico', cognome: 'Cavallo', ruolo: RuoloMuta.puntaDietro), PersonaMuta(nome: 'Davide', cognome: 'Stendardo', ruolo: RuoloMuta.puntaDietro),
    ]),
  ];

  List<Muta> displayedMute = [];
  // Struttura per i risultati del confronto dettagliato
  Map<RuoloMuta, Map<String, List<PersonaMuta>>>? comparisonResultData;

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
    // Resetta le selezioni e i risultati quando il cero cambia
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
        // Filtra le mute per l'anno selezionato E per il cero corrente
        displayedMute = allMuteData
            .where((muta) => muta.anno == selectedYear && muta.cero == currentCero)
            .toList();

        if (comparisonYear != null) {
          final muteAnnoPrincipale = allMuteData
              .where((m) => m.anno == selectedYear && m.cero == currentCero)
              .toList(); // Potrebbero esserci più mute per lo stesso anno/cero
          final muteAnnoConfronto = allMuteData
              .where((m) => m.anno == comparisonYear && m.cero == currentCero)
              .toList();

          // Semplificazione: confrontiamo solo la prima muta trovata per ogni anno.
          // In un'app reale, l'utente dovrebbe poter selezionare quali specifiche mute confrontare.
          if (muteAnnoPrincipale.isNotEmpty && muteAnnoConfronto.isNotEmpty) {
            comparisonResultData = _compareMuteDetailed(muteAnnoPrincipale.first, muteAnnoConfronto.first);
          } else {
            comparisonResultData = {}; // Nessun dato per confronto
          }
          // Quando c'è un confronto, non mostriamo la lista di displayedMute
          displayedMute = [];
        }
        if (displayedMute.isEmpty && comparisonResultData == null) {
          // Se non ci sono mute per l'anno principale e nessun confronto
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nessuna muta trovata per ${Provider.of<ThemeProvider>(context, listen: false).currentCeroName} nell\'anno $selectedYear.')),
          );
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleziona un anno per visualizzare le mute.')),
        );
      }
    });
  }

  Map<RuoloMuta, Map<String, List<PersonaMuta>>> _compareMuteDetailed(Muta mutaA, Muta mutaB) {
    Map<RuoloMuta, Map<String, List<PersonaMuta>>> result = {};

    for (RuoloMuta ruolo in RuoloMuta.values) {
      List<PersonaMuta> personeA = mutaA.getPersonePerRuolo(ruolo);
      List<PersonaMuta> personeB = mutaB.getPersonePerRuolo(ruolo);

      List<PersonaMuta> confermati = [];
      List<PersonaMuta> entrati = List.from(personeB); // Copia per modifica
      List<PersonaMuta> usciti = [];

      for (PersonaMuta pA in personeA) {
        PersonaMuta? matchingPB = personeB.firstWhere(
                (pB) => pB.nomeCompleto == pA.nomeCompleto, // Confronto per nome completo
            orElse: () => PersonaMuta(nome: "dummy", cognome: "dummy", ruolo: ruolo) // Valore fittizio per evitare null error se non trovato
        );

        if (matchingPB.nome != "dummy") { // Se trovato in B
          confermati.add(pA);
          entrati.removeWhere((pB) => pB.nomeCompleto == pA.nomeCompleto); // Rimuovi dai potenziali entrati
        } else { // Se non trovato in B, è uscito
          usciti.add(pA);
        }
      }
      result[ruolo] = {
        'confermati': confermati,
        'usciti': usciti,
        'entrati': entrati,
      };
    }
    return result;
  }


  @override
  Widget build(BuildContext context) {
    // Ascolta i cambiamenti del ThemeProvider per ricostruire l'interfaccia con il tema corretto
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Archivio ${themeProvider.currentCeroName}'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: CeroSelector(showAsPopup: true, showFullName: false),
          ),
        ],
      ),
      body: Column(
        children: [
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
                            // Resetta i risultati se si cambia solo l'anno principale
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
                            .where((year) => year != selectedYear)
                            .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            comparisonYear = value;
                            // Resetta i risultati se si cambia solo l'anno di confronto
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
                    onPressed: selectedYear != null ? _fetchAndDisplayMute : null,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
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
                  : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (comparisonResultData != null && comparisonResultData!.isNotEmpty)
                      _buildComparisonView(comparisonResultData!, themeProvider, selectedYear!, comparisonYear!),
                    if (displayedMute.isNotEmpty)
                      ...displayedMute.map((muta) => _MutaDisplayCard(muta: muta, themeProvider: themeProvider)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView(Map<RuoloMuta, Map<String, List<PersonaMuta>>> data, ThemeProvider themeProvider, int annoA, int annoB) {
    List<Widget> ruoloWidgets = [];

    data.forEach((ruolo, dettagli) {
      ruoloWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ruolo.toString().split('.').last.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim(), // Formatta il nome del ruolo
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: themeProvider.currentPrimaryColor),
                  ),
                  const Divider(),
                  if (dettagli['confermati']!.isNotEmpty) ...[
                    Text('Confermati ($annoA e $annoB):', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ...dettagli['confermati']!.map((p) => Text('  - ${p.nomeCompleto}')),
                    const SizedBox(height: 8),
                  ],
                  if (dettagli['usciti']!.isNotEmpty) ...[
                    Text('Usciti (da $annoA):', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade700)),
                    ...dettagli['usciti']!.map((p) => Text('  - ${p.nomeCompleto}')),
                    const SizedBox(height: 8),
                  ],
                  if (dettagli['entrati']!.isNotEmpty) ...[
                    Text('Entrati (in $annoB):', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                    ...dettagli['entrati']!.map((p) => Text('  - ${p.nomeCompleto}')),
                  ],
                  if (dettagli['confermati']!.isEmpty && dettagli['usciti']!.isEmpty && dettagli['entrati']!.isEmpty)
                    const Text('Nessun cambiamento o dato per questo ruolo.'),
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
          padding: const EdgeInsets.symmetric(vertical:8.0),
          child: Text('Confronto Mute: $annoA vs $annoB', style: Theme.of(context).textTheme.titleLarge),
        ),
        ...ruoloWidgets
      ],
    );
  }
}

class _MutaDisplayCard extends StatelessWidget {
  final Muta muta;
  final ThemeProvider themeProvider;

  const _MutaDisplayCard({required this.muta, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      color: themeProvider.currentPrimaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${muta.posizione} - Anno: ${muta.anno}', // o muta.nomeMuta se preferisci
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: themeProvider.currentPrimaryColor),
            ),
            if (muta.note != null && muta.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text('Note: ${muta.note}', style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            const Divider(),
            ...RuoloMuta.values.map((ruolo) {
              List<PersonaMuta> personePerRuolo = muta.getPersonePerRuolo(ruolo);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120, // Larghezza fissa per l'etichetta del ruolo
                      child: Text(
                        // Formattazione del nome del ruolo per leggibilità
                        '${ruolo.toString().split('.').last.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim()}:',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: personePerRuolo.isNotEmpty
                            ? personePerRuolo.map((p) => Text(p.nomeCompleto)).toList()
                            : [const Text('-', style: TextStyle(color: Colors.grey))],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
