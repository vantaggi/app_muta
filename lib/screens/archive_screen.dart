import 'package:flutter/material.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archivio Storico'),
      ),
      body: const Center(
        child: Text(
          'Qui potrai consultare le mute degli anni passati.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}