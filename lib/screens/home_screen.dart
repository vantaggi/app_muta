import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:muta_manager/services/database_helper.dart';
import 'package:muta_manager/models/muta_model.dart';
import 'package:provider/provider.dart';
import 'package:muta_manager/theme/theme_provider.dart';
import 'package:muta_manager/theme/app_theme.dart';
import 'package:muta_manager/widgets/cero_selector.dart';
import 'package:muta_manager/providers/app_state_provider.dart';
import 'package:muta_manager/screens/ceraioli_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabSelected;

  const HomeScreen({super.key, required this.onTabSelected});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _muteCount = 0;
  int _yearCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    try {
      // Modifica per contare tutte le mute
      await appState.loadAllMute();
      await appState.loadAvailableYears();
      if (mounted) {
        setState(() {
          _muteCount = appState.muteList.where((m) => m.cero == themeProvider.currentCero).length;
          _yearCount = appState.availableYears.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportData(BuildContext context) async {
    final mute = await DatabaseHelper.instance.readAllMute();
    final json = jsonEncode(mute.map((m) => m.toJson()).toList());

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/mute_export_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(path);
    await file.writeAsString(json);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data exported to $path')),
      );
    }
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
      }
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AppStateProvider>(
      builder: (context, themeProvider, appState, child) {
        final currentCero = themeProvider.currentCero;

        return Scaffold(
          appBar: AppBar(
            title: Text('Muta Manager - ${themeProvider.currentCeroName}'),
            actions: [
              IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                onPressed: () => themeProvider.toggleTheme(),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: CeroSelector(showAsPopup: true, showFullName: false),
              ),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: _isLoading
              ? Center(
                  key: const ValueKey('loading'),
                  child: CircularProgressIndicator(color: themeProvider.currentPrimaryColor),
                )
              : SingleChildScrollView(
                  key: ValueKey<CeroType>(currentCero),
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Info Card
                      Card(
                        elevation: 0,
                        shadowColor: Colors.black.withAlpha(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.macroBorderRadius,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: AppTheme.macroBorderRadius,
                            boxShadow: AppTheme.ambientShadow,
                            color: Theme.of(context).cardTheme.color,
                          ),
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
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
                                  const SizedBox(width: AppTheme.spacingMd),
                                  Expanded(
                                    child: Text(
                                      'Cero di ${themeProvider.currentCeroName}',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingMd),
                              Text(
                                _getCeroDescription(currentCero),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      // Inline Cero Selector
                      Text('Seleziona Cero', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppTheme.spacingSm),
                      CeroSelector(
                        showAsPopup: false,
                        onCeroChanged: (_) => _loadStats(),
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      // Statistics Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.macroBorderRadius,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: AppTheme.macroBorderRadius,
                            boxShadow: AppTheme.ambientShadow,
                            color: Theme.of(context).cardTheme.color,
                          ),
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Statistiche',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppTheme.spacingSm),
                              _buildStatRow(context, 'Mute registrate', '$_muteCount'),
                              _buildStatRow(context, 'Anni di archivio', '$_yearCount'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      // Quick Actions
                      Text('Azioni Rapide', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppTheme.spacingSm),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionCard(
                                  context,
                                  'Crea Muta',
                                  Icons.add_circle_outline,
                                  () => widget.onTabSelected(2),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingMd),
                              Expanded(
                                child: _buildQuickActionCard(
                                  context,
                                  'Gestisci Ceraioli',
                                  Icons.people_outline,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CeraioliScreen()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionCard(
                                  context,
                                  'Mappa Archivio',
                                  Icons.map_outlined,
                                  () => widget.onTabSelected(1),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingMd),
                              Expanded(
                                child: _buildQuickActionCard(
                                  context,
                                  'Backup Dati',
                                  Icons.import_export_outlined,
                                  () => _showImportExportDialog(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
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
          shape: RoundedRectangleBorder(borderRadius: AppTheme.macroBorderRadius),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _importData(context);
              },
              child: const Text('Importa'),
            ),
            ElevatedButton(
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(26),
              borderRadius: AppTheme.microBorderRadius,
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: AppTheme.ambientShadow,
        borderRadius: AppTheme.macroBorderRadius,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.macroBorderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.macroBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
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
        return 'Il Cero di Sant\'Antonio rappresenta i contadini e gli agricoltori. Con la sua caratteristica camicia nera e fazzoletto rosso, chiude la processione nella corsa verso il Monte Ingino.';
    }
  }
}
