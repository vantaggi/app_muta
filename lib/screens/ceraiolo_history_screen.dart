import 'package:app_muta/models/muta_model.dart';
import 'package:flutter/material.dart';
import 'package:app_muta/models/ceraiolo_model.dart';
import 'package:app_muta/services/database_helper.dart';

class CeraioloHistoryScreen extends StatefulWidget {
  final Ceraiolo ceraiolo;

  const CeraioloHistoryScreen({super.key, required this.ceraiolo});

  @override
  State<CeraioloHistoryScreen> createState() => _CeraioloHistoryScreenState();
}

class _CeraioloHistoryScreenState extends State<CeraioloHistoryScreen> {
  late Future<List<Muta>> _muteHistoryFuture;

  @override
  void initState() {
    super.initState();
    _muteHistoryFuture = _loadMuteHistory();
  }

  Future<List<Muta>> _loadMuteHistory() async {
    // We can search by name, and since names are not unique, we might get mutes from other people
    // with the same name. A better approach would be to have a ceraioloId in the 'persone' table.
    // For now, we will search by name, cognome, and soprannome, which should be specific enough.
    final historyByName = await DatabaseHelper.instance.searchMuteByPerson(widget.ceraiolo.nome);
    final historyByCognome = await DatabaseHelper.instance.searchMuteByPerson(widget.ceraiolo.cognome);

    final allMute = (historyByName + historyByCognome).toSet().toList();

    // This is not perfect, as it will fetch any muta that contains the name OR the cognome.
    // We should filter it to be more precise.
    allMute.retainWhere((muta) {
      final allPersone = muta.stangaSinistra + muta.stangaDestra;
      return allPersone.any((persona) =>
          persona.nome == widget.ceraiolo.nome &&
          persona.cognome == widget.ceraiolo.cognome);
    });

    return allMute;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Storico di ${widget.ceraiolo.nome} ${widget.ceraiolo.cognome}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dettagli Ceraiolo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Nome: ${widget.ceraiolo.nome}'),
                Text('Cognome: ${widget.ceraiolo.cognome}'),
                if (widget.ceraiolo.soprannome != null)
                  Text('Soprannome: ${widget.ceraiolo.soprannome}'),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Muta>>(
              future: _muteHistoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nessuna muta trovata per questo ceraiolo.'));
                }

                final muteHistory = snapshot.data!;

                return ListView.builder(
                  itemCount: muteHistory.length,
                  itemBuilder: (context, index) {
                    final muta = muteHistory[index];
                    return ListTile(
                      title: Text(muta.nomeMuta),
                      subtitle: Text('Anno: ${muta.anno} - Posizione: ${muta.posizione}'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Maybe navigate to a Muta detail screen in the future
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
