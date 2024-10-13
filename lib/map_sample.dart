import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final List<Marker> _markers = [];
  final List<String> _markerNames = [];
  GoogleMapController? _controller;
  final places = GoogleMapsPlaces(apiKey: 'AIzaSyChDKoRKSmGZYBG2fzWHHG4BXYnM3MR0vo');

  void _addMarker(LatLng position) async {
    if (_markers.length < 5) {
      final place = await places.searchNearbyWithRadius(
        Location(lat: position.latitude, lng: position.longitude),
        50,
      );

      String markerName;
      if (place.results.isNotEmpty) {
        markerName = place.results.first.name;
      } else {
        markerName = await _promptForMarkerName();
      }

      final marker = Marker(
        markerId: MarkerId('marker_${_markers.length + 1}'),
        position: position,
        infoWindow: InfoWindow(title: markerName),
      );

      setState(() {
        _markers.add(marker);
        _markerNames.add(markerName);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solo puedes agregar hasta 5 marcadores.')),
      );
    }
  }

  Future<String> _promptForMarkerName() async {
    String markerName = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingrese el nombre del marcador'),
          content: TextField(
            onChanged: (value) {
              markerName = value;
            },
            decoration: InputDecoration(hintText: "Nombre del marcador"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return markerName;
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Historial de marcadores'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _markerNames
                  .map((name) => Text(name))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetMarkers() {
    setState(() {
      _markers.clear();
      _markerNames.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo de Mapas en Flutter'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _showHistory,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetMarkers,
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          print('Mapa creado');
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 5,
        ),
        markers: Set.from(_markers),
        onTap: _addMarker,
      ),
    );
  }
}