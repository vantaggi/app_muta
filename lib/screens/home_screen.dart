import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home - App Muta'),
      ),
      body: const Center(
        child: Text(
          'Benvenuto! Qui ci sarà la dashboard principale.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}