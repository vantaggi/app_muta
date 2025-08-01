import 'package:app_muta/screens/ceraiolo_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_muta/models/ceraiolo_model.dart';
import 'package:app_muta/services/database_helper.dart';
import 'package:uuid/uuid.dart';

class CeraioliScreen extends StatefulWidget {
  const CeraioliScreen({super.key});

  @override
  State<CeraioliScreen> createState() => _CeraioliScreenState();
}

class _CeraioliScreenState extends State<CeraioliScreen> {
  late Future<List<Ceraiolo>> _ceraioliFuture;

  @override
  void initState() {
    super.initState();
    _refreshCeraioliList();
  }

  void _refreshCeraioliList() {
    setState(() {
      _ceraioliFuture = DatabaseHelper.instance.readAllCeraioli();
    });
  }

  Future<void> _showCeraioloDialog({Ceraiolo? ceraiolo}) async {
    final _formKey = GlobalKey<FormState>();
    final _nomeController = TextEditingController(text: ceraiolo?.nome);
    final _cognomeController = TextEditingController(text: ceraiolo?.cognome);
    final _soprannomeController = TextEditingController(text: ceraiolo?.soprannome);
    final isEditing = ceraiolo != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Modifica Ceraiolo' : 'Aggiungi Ceraiolo'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      value!.isEmpty ? 'Il nome è obbligatorio' : null,
                ),
                TextFormField(
                  controller: _cognomeController,
                  decoration: const InputDecoration(labelText: 'Cognome'),
                  validator: (value) =>
                      value!.isEmpty ? 'Il cognome è obbligatorio' : null,
                ),
                TextFormField(
                  controller: _soprannomeController,
                  decoration: const InputDecoration(labelText: 'Soprannome (Opzionale)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newCeraiolo = Ceraiolo(
                    id: isEditing ? ceraiolo.id : const Uuid().v4(),
                    nome: _nomeController.text,
                    cognome: _cognomeController.text,
                    soprannome: _soprannomeController.text.isNotEmpty
                        ? _soprannomeController.text
                        : null,
                  );
                  if (isEditing) {
                    await DatabaseHelper.instance.updateCeraiolo(newCeraiolo);
                  } else {
                    await DatabaseHelper.instance.insertCeraiolo(newCeraiolo);
                  }
                  _refreshCeraioliList();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCeraiolo(String id) async {
    await DatabaseHelper.instance.deleteCeraiolo(id);
    _refreshCeraioliList();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ceraiolo eliminato con successo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Ceraioli'),
      ),
      body: FutureBuilder<List<Ceraiolo>>(
        future: _ceraioliFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessun ceraiolo trovato.'));
          }

          final ceraioli = snapshot.data!;

          return ListView.builder(
            itemCount: ceraioli.length,
            itemBuilder: (context, index) {
              final ceraiolo = ceraioli[index];
              return ListTile(
                title: Text('${ceraiolo.cognome} ${ceraiolo.nome}'),
                subtitle: ceraiolo.soprannome != null
                    ? Text(ceraiolo.soprannome!)
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showCeraioloDialog(ceraiolo: ceraiolo),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteCeraiolo(ceraiolo.id),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        CeraioloHistoryScreen(ceraiolo: ceraiolo),
                  ));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCeraioloDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
