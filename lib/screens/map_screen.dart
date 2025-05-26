import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mappa del Percorso'),
      ),
      body: const Center(
        child: Text(
          'Qui verrà visualizzata la mappa interattiva.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}