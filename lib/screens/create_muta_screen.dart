import 'package:flutter/material.dart';

class CreateMutaScreen extends StatelessWidget {
  const CreateMutaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea o Esporta Muta'),
      ),
      body: const Center(
        child: Text(
          'Qui ci sarà il tool per creare e condividere le mute.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}