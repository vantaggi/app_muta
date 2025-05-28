import 'package:app_muta/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_muta/theme/theme_provider.dart';
import 'package:app_muta/widgets/cero_selector.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('App Muta - ${themeProvider.currentCeroName}'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: CeroSelector(showAsPopup: true, showFullName: false),
              ),
            ],
          ),
          body: SingleChildScrollView(
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
                        _buildStatRow(context, 'Mute registrate', '0'),
                        _buildStatRow(context, 'Anni di archivio', '0'),
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
                    // Use Padding instead of SizedBox for flexible spacing
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0), // Half of 12.0 on each side
                      child: Container(), // An empty container for the padding
                    ),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        'Crea Muta',
                        Icons.add_circle_outline,
                            () => _navigateToTab(context, 2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
}