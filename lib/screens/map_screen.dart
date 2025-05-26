import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_muta/theme/theme_provider.dart';
import 'package:app_muta/widgets/cero_selector.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Mappa ${themeProvider.currentCeroName}'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CeroSelector(showAsPopup: true, showFullName: false),
              ),
            ],
          ),
          body: Column(
            children: [
              // Barra informativa del cero
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: themeProvider.currentPrimaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      themeProvider.currentCeroIcon,
                      color: themeProvider.currentPrimaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Visualizzando le mute del Cero di ${themeProvider
                          .currentCeroName}',
                      style: TextStyle(
                        color: themeProvider.currentPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Area della mappa (placeholder per ora)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeProvider.currentPrimaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Placeholder mappa
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Mappa Interattiva',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Qui verrà visualizzato il percorso\ncon le mute del ${themeProvider
                                  .currentCeroName}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Punti mute di esempio
                      ...List.generate(5, (index) =>
                          _buildMutaPoint(
                            context,
                            themeProvider,
                            index + 1,
                            _getRandomPosition(context, index),
                          )),
                    ],
                  ),
                ),
              ),

              // Pannello inferiore con informazioni
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .cardColor,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mute ${themeProvider.currentCeroName}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              _showMuteList(context, themeProvider),
                          icon: const Icon(Icons.list),
                          label: const Text('Vedi Lista'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(context, '5 Mute', Colors.green),
                        const SizedBox(width: 8),
                        _buildInfoChip(context, '3 Verificate', Colors.blue),
                        const SizedBox(width: 8),
                        _buildInfoChip(context, '2 In Attesa', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addNewMuta(context, themeProvider),
            backgroundColor: themeProvider.currentPrimaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildMutaPoint(BuildContext context, ThemeProvider themeProvider,
      int numero, Offset position) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () => _showMutaDetails(context, numero, themeProvider),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: themeProvider.currentPrimaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              numero.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Offset _getRandomPosition(BuildContext context, int index) {
    // Posizioni di esempio per le mute
    final positions = [
      const Offset(50, 80),
      const Offset(150, 120),
      const Offset(100, 200),
      const Offset(200, 160),
      const Offset(120, 280),
    ];
    return positions[index % positions.length];
  }

  void _showMutaDetails(BuildContext context, int numero,
      ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Muta #$numero - ${themeProvider.currentCeroName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Posizione: Via del Corso, $numero'),
                const SizedBox(height: 8),
                Text('Stato: ${numero <= 3
                    ? "Verificata"
                    : "In attesa di verifica"}'),
                const SizedBox(height: 8),
                const Text('Persone: 8/8'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Chiudi'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Qui andrebbe la navigazione ai dettagli della muta
                },
                child: const Text('Dettagli'),
              ),
            ],
          ),
    );
  }

  void _showMuteList(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            builder: (context, scrollController) =>
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Mute ${themeProvider.currentCeroName}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: 5,
                          itemBuilder: (context, index) =>
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: themeProvider
                                      .currentPrimaryColor,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text('Muta #${index + 1}'),
                                subtitle: Text('Via del Corso, ${index + 1}'),
                                trailing: Icon(
                                  index < 3 ? Icons.verified : Icons.pending,
                                  color: index < 3 ? Colors.green : Colors
                                      .orange,
                                ),
                                onTap: () =>
                                    _showMutaDetails(
                                        context, index + 1, themeProvider),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _addNewMuta(BuildContext context, ThemeProvider themeProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Aggiungi nuova muta per ${themeProvider.currentCeroName}'),
        backgroundColor: themeProvider.currentPrimaryColor,
      ),
    );
  }
}