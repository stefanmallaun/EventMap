import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final List<Marker> _markers = [];
  //WEB
  final String apiUrl = 'http://localhost:3000/api/save-position';
  //android
  //final String apiUrl = 'http://10.0.2.2:3000/api/save-position'; // Update to your API endpoint

  void _addMarker(LatLng position) {
    
    print('Marker added at: ${position.latitude}, ${position.longitude}');

    
    _sendPositionToDatabase(position);

    setState(() {
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: position,
          builder: (ctx) => const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
    });
  }

  Future<void> _sendPositionToDatabase(LatLng position) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, double>{
        'latitude': position.latitude,
        'longitude': position.longitude,
      }),
    );

    if (response.statusCode == 200) {
      print('Position saved successfully');
    } else {
      print('Failed to save position: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenStreetMap Sample'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(51.509364, -0.128928), 
          zoom: 13.0,
          onTap: (tapPosition, latlng) {
            _addMarker(latlng); 
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _markers, 
          ),
        ],
      ),
    );
  }
}
