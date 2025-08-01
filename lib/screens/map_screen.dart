import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:app_muta/models/muta_model.dart';
import 'package:app_muta/services/database_helper.dart';
import 'package:app_muta/theme/theme_provider.dart';
import 'package:app_muta/widgets/cero_selector.dart';
import 'package:app_muta/theme/app_theme.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:app_muta/screens/archive_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _center = const LatLng(43.3539, 12.6723); // Gubbio
  List<Marker> markers = [];
  bool _isLoading = true;
  LatLng? _userLocation;

  final Map<String, String> _tileLayers = {
    'Street': 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    'Satellite': 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
  };
  String _currentTileLayer = 'Street';

  @override
  void initState() {
    super.initState();
    _loadMute();
  }

  Future<void> _loadMute() async {
    setState(() {
      _isLoading = true;
    });

    final mute = await DatabaseHelper.instance.readAllMute();
    if (!mounted) return;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final newMarkers = <Marker>[];
    for (final muta in mute) {
      if (muta.cero == themeProvider.currentCero) {
        if (muta.latitude != null && muta.longitude != null) {
          newMarkers.add(_buildMutaMarker(muta, themeProvider));
        }
      }
    }

    setState(() {
      markers = newMarkers;
      _isLoading = false;
    });
  }

  Marker _buildMutaMarker(Muta muta, ThemeProvider themeProvider) {
    Color markerColor;
    switch (muta.cero) {
      case CeroType.santUbaldo:
        markerColor = Colors.yellow.shade700;
        break;
      case CeroType.sanGiorgio:
        markerColor = Colors.blue.shade700;
        break;
      case CeroType.santAntonio:
        markerColor = Colors.black;
        break;
    }

    return Marker(
      width: 40.0,
      height: 40.0,
      point: LatLng(muta.latitude!, muta.longitude!),
      child: GestureDetector(
        onTap: () {
          _showMutaDetails(context, muta, themeProvider);
        },
        child: Container(
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.location_on,
            color: Colors.white.withOpacity(0.8),
            size: 20,
          ),
        ),
      ),
    );
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
    _mapController.move(_userLocation!, 15.0);
  }

  Future<void> _launchNavigation(LatLng destination) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch maps')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Mappa ${themeProvider.currentCeroName}'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (String value) {
                  setState(() {
                    _currentTileLayer = value;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return _tileLayers.keys.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
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
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _center,
                  zoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: _tileLayers[_currentTileLayer]!,
                    subdomains: const ['a', 'b', 'c'],
                    // Add a key to force rebuild when url changes
                    key: ValueKey<String>(_currentTileLayer),
                  ),
                  if (_userLocation != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _userLocation!,
                          color: Colors.blue.withOpacity(0.3),
                          borderColor: Colors.blue,
                          borderStrokeWidth: 2,
                          useRadiusInMeter: true,
                          radius: 10,
                        ),
                      ],
                    ),
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 45,
                      size: const Size(40, 40),
                      anchor: AnchorPos.align(AnchorAlign.center),
                      fitBoundsOptions: const FitBoundsOptions(
                        padding: EdgeInsets.all(50),
                        maxZoom: 15,
                      ),
                      markers: markers,
                      builder: (context, markers) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: themeProvider.currentPrimaryColor,
                          ),
                          child: Center(
                            child: Text(
                              markers.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  AttributionWidget.defaultWidget(
                    source: 'OpenStreetMap contributors',
                    onSourceTapped: null,
                  ),
                ],
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!_isLoading && markers.isEmpty)
                const Center(
                  child: Text(
                    'No mute with coordinates found for this Cero.',
                    style: TextStyle(fontSize: 18, color: Colors.white, backgroundColor: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
              Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'my_location_button',
                      onPressed: _getUserLocation,
                      child: const Icon(Icons.my_location),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      heroTag: 'zoom_in_button',
                      onPressed: () {
                        _mapController.move(_mapController.center, _mapController.zoom + 1);
                      },
                      child: const Icon(Icons.zoom_in),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      heroTag: 'zoom_out_button',
                      onPressed: () {
                        _mapController.move(_mapController.center, _mapController.zoom - 1);
                      },
                      child: const Icon(Icons.zoom_out),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      heroTag: 'recenter_button',
                      onPressed: () {
                        _mapController.move(_center, 14.0);
                      },
                      child: const Icon(Icons.center_focus_strong),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMutaDetails(BuildContext context, Muta muta, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                muta.nomeMuta,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Anno: ${muta.anno}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(muta.posizione, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close bottom sheet
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ArchiveScreen()));
                      },
                      icon: const Icon(Icons.archive_outlined),
                      label: const Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.currentPrimaryColor,
                        foregroundColor: themeProvider.currentPrimaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (muta.latitude != null && muta.longitude != null) {
                          _launchNavigation(LatLng(muta.latitude!, muta.longitude!));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No coordinates available for this muta')));
                        }
                      },
                      icon: const Icon(Icons.directions_outlined),
                      label: const Text('Get Directions'),
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: themeProvider.currentPrimaryColor),
                          foregroundColor: themeProvider.currentPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}