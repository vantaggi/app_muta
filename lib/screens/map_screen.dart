import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:app_muta/models/muta_model.dart';
import 'package:app_muta/services/database_helper.dart';
import 'package:app_muta/theme/theme_provider.dart';
import 'package:app_muta/widgets/cero_selector.dart';
import 'package:app_muta/theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _center = const LatLng(43.3539, 12.6723); // Gubbio
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    _loadMute();
  }

  Future<void> _loadMute() async {
    final mute = await DatabaseHelper.instance.readAllMute();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    setState(() {
      markers.clear();
      for (final muta in mute) {
        if (muta.cero == themeProvider.currentCero) {
          if (muta.latitude != null && muta.longitude != null) {
            markers.add(
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(muta.latitude!, muta.longitude!),
                child: GestureDetector(
                  onTap: () {
                    _showMutaDetails(context, muta, themeProvider);
                  },
                  child: Icon(
                    Icons.location_on,
                    color: themeProvider.currentPrimaryColor,
                    size: 40,
                  ),
                ),
              ),
            );
          }
        }
      }
    });
  }

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
                child: CeroSelector(
                  showAsPopup: true,
                  showFullName: false,
                  onCeroChanged: (CeroType cero) {
                    _loadMute();
                  },
                ),
              ),
            ],
          ),
          body: FlutterMap(
            options: MapOptions(
              center: _center,
              zoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: markers),
            ],
          ),
        );
      },
    );
  }

  void _showMutaDetails(BuildContext context, Muta muta, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${muta.nomeMuta} - ${themeProvider.currentCeroName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Posizione: ${muta.posizione}'),
            const SizedBox(height: 8),
            Text('Anno: ${muta.anno}'),
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
              // Here we would navigate to the muta details screen
            },
            child: const Text('Dettagli'),
          ),
        ],
      ),
    );
  }
}