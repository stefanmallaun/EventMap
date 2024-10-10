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
  //final String apiUrl = 'http://localhost:3000/api/save-position';
  //ANDROID
  final String apiUrl = 'http://10.0.2.2:3000/api/save-position';

  // Function to add marker
  void _addMarker(LatLng position) {
    print('Marker added at: ${position.latitude}, ${position.longitude}');
    _fetchAndSendData(position);
    
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

  // Function to get address using Nominatim (OpenStreetMap)
  Future<String> getNominatimAddress(double latitude, double longitude) async {
    final String url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Unknown address';  // Return the address
      } else {
        print('Failed to retrieve address.');
        return 'Unknown address';
      }
    } catch (e) {
      print('Error: $e');
      return 'Unknown address';
    }
  }

  // Function to send position and address to the database
  Future<void> _sendPositionToDatabase(LatLng position, String address) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'latitude': position.latitude,
          'longitude': position.longitude,
          'address': address,  
        }),
      );

      if (response.statusCode == 200) {
        print('Position and address saved successfully');
      } else {
        print('Failed to save position and address: ${response.body}');
      }
    } catch (e) {
      print('Error sending position and address to database: $e');
    }
  }

  // Function to fetch the address and send both position and address to the database
  Future<void> _fetchAndSendData(LatLng position) async {
    // Get the address first
    String address = await getNominatimAddress(position.latitude, position.longitude);

    // Then send both the position and address to the database
    await _sendPositionToDatabase(position, address);
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
