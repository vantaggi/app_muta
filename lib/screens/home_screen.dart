import 'package:app_muta/screens/ceraioli_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:app_muta/services/database_helper.dart';
import 'package:app_muta/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:app_muta/theme/theme_provider.dart';
import 'package:app_muta/widgets/cero_selector.dart';
import 'package:app_muta/models/muta_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _muteCount = 0;
  int _yearCount = 0;
  late ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _themeProvider.addListener(_loadStats);
    _loadStats();
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_loadStats);
    super.dispose();
  }

  Future<void> _loadStats() async {
    final mute = await DatabaseHelper.instance.readAllMute();
    final currentCero = _themeProvider.currentCero;
    final muteForCero = mute.where((m) => m.cero == currentCero).toList();
    final years = muteForCero.map((m) => m.anno).toSet().toList();
    setState(() {
      _muteCount = muteForCero.length;
      _yearCount = years.length;
    });
  }

  Future<void> _exportData(BuildContext context) async {
    final mute = await DatabaseHelper.instance.readAllMute();
    final json = jsonEncode(mute.map((m) => m.toJson()).toList());
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/muta_export.json';
    final file = File(path);
    await file.writeAsString(json);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data exported to $path')),
    );
  }

  Future<void> _importData(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = File(result.files.single.path!);
      final json = await file.readAsString();
      final data = jsonDecode(json) as List;
      for (final item in data) {
        await DatabaseHelper.instance.insertMuta(Muta.fromJson(item));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data imported successfully')),
      );
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('App Muta - ${themeProvider.currentCeroName}'),
            actions: [
              IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: CeroSelector(showAsPopup: true, showFullName: false),
              ),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(child: child, opacity: animation);
            },
            child: SingleChildScrollView(
              key: ValueKey<CeroType>(themeProvider.currentCero),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card di benvenuto con info del cero
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                themeProvider.currentCeroIcon,
                                size: 32,
                                color: themeProvider.currentPrimaryColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded( // <--- Added Expanded
                                child:Text(
                                  'Cero di ${themeProvider.currentCeroName}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getCeroDescription(themeProvider.currentCero),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Selettore cero inline
                  Text(
                    'Seleziona Cero:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const CeroSelector(showAsPopup: false),

                  const SizedBox(height: 24),

                  // Statistiche del cero corrente
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistiche ${themeProvider.currentCeroName}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(context, 'Mute registrate', '$_muteCount'),
                          _buildStatRow(context, 'Anni di archivio', '$_yearCount'),
                          _buildStatRow(context, 'Ultima modifica', 'Mai'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Azioni rapide
                  Text(
                    'Azioni Rapide:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              'Crea Muta',
                              Icons.add_circle_outline,
                              () => _navigateToTab(context, 2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              'Gestisci Ceraioli',
                              Icons.people,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CeraioliScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              'Visualizza Mappa',
                              Icons.map,
                              () => _navigateToTab(context, 1),
                            ),
                          ),
                           const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              'Importa/Esporta',
                              Icons.import_export,
                              () => _showImportExportDialog(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImportExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Importa/Esporta Dati'),
          content: const Text('Vuoi importare o esportare i dati delle mute?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _importData(context);
              },
              child: const Text('Importa'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _exportData(context);
              },
              child: const Text('Esporta'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCeroDescription(CeroType cero) {
    switch (cero) {
      case CeroType.santUbaldo:
        return 'Il Cero di Sant\'Ubaldo, patrono di Gubbio, rappresenta la tradizione più antica della Festa dei Ceri. Con i suoi colori giallo, rosso e bianco, è il primo a partire nella corsa.';
      case CeroType.sanGiorgio:
        return 'Il Cero di San Giorgio rappresenta gli artigiani e i commercianti di Gubbio. Con i suoi colori blu, rosso e bianco, occupa la posizione centrale nella corsa.';
      case CeroType.santAntonio:
        return 'Il Cero di Sant\'Antonio rappresenta i contadini e gli agricoltori. Con i suoi colori nero, rosso e bianco, chiude la processione nella corsa verso il Monte Ingino.';
    }
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    // Questa funzione dovrebbe comunicare con il MainNavigator
    // Per ora mostriamo un messaggio
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigazione alla tab $tabIndex'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showImportExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Importa/Esporta Dati'),
          content: const Text('Vuoi importare o esportare i dati delle mute?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _importData(context);
              },
              child: const Text('Importa'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _exportData(context);
              },
              child: const Text('Esporta'),
            ),
          ],
        );
      },
    );
  }
}