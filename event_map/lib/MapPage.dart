import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<Marker> _markers = [];

  // WEB URLS
  final String locationApiUrl = 'http://localhost:3000/api/save-position';
  final String eventApiUrl = 'http://localhost:3000/api/save-eventdata';

  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime? _eventDate;
  int _eventType = 1;


  
  void _addMarker(LatLng position) {
    print('Marker added at: ${position.latitude}, ${position.longitude}');
    _fetchAndSaveData(position);

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

  // Get address from latitude and longitude
  Future<String> getNominatimAddress(double latitude, double longitude) async {
    final String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Unknown address';
      } else {
        print('Failed to retrieve address.');
        return 'Unknown address';
      }
    } catch (e) {
      print('Error: $e');
      return 'Unknown address';
    }
  }

  // Save location to the database and get location ID
  Future<int?> _saveLocationToDatabase(LatLng position, String address) async {
    try {
      final response = await http.post(
        Uri.parse(locationApiUrl),
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
        final data = json.decode(response.body);
        return data['location_id'];
      } else {
        print('Failed to save location: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error saving location: $e');
      return null;
    }
  }

  // Save event data to the database
  Future<void> _saveEventToDatabase(int locationId) async {
    try {
      final response = await http.post(
        Uri.parse(eventApiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'location_id': locationId,
          'title': _title,
          'description': _description,
          'event_date': _eventDate?.toIso8601String(),
          'type_of_event': _eventType,
        }),
      );

      if (response.statusCode == 200) {
        print('Event data saved successfully');
      } else {
        print('Failed to save event data: ${response.body}');
      }
    } catch (e) {
      print('Error saving event data: $e');
    }
  }

  // Fetch address, save location, and then save event
  Future<void> _fetchAndSaveData(LatLng position) async {
    String address = await getNominatimAddress(position.latitude, position.longitude);

    int? locationId = await _saveLocationToDatabase(position, address);

    if (locationId != null) {
      await _saveEventToDatabase(locationId);
    } else {
      print('Failed to save location, event data not saved.');
    }
  }

  // Pop-up window to input event data
  void _addEventData(LatLng position) {
    DateTime? selectedDate = _eventDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Event Daten eingeben'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Titel'),
                        onSaved: (value) {
                          _title = value ?? '';
                        },
                        validator: (value) {
                          return (value == null || value.isEmpty)
                              ? 'Bitte Titel eingeben'
                              : null;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Beschreibung'),
                        onSaved: (value) {
                          _description = value ?? '';
                        },
                        validator: (value) {
                          return (value == null || value.isEmpty)
                              ? 'Bitte Beschreibung eingeben'
                              : null;
                        },
                      ),
                      Row(
                        children: [
                          Text(
                            selectedDate == null
                                ? 'Kein Datum ausgewählt'
                                : 'Datum: ${selectedDate.toString().split(' ')[0]}',
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  selectedDate = date;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Event-Typ'),
                        value: _eventType,
                        items: const [
                          DropdownMenuItem(child: Text('Keine Angabe'), value: 1),
                          DropdownMenuItem(child: Text('Sport'), value: 2),
                          DropdownMenuItem(child: Text('Party'), value: 3),
                          DropdownMenuItem(child: Text('Concert'), value: 4),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            if (value != null) {
                              _eventType = value;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Abbrechen'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Bestätigen'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      setState(() {
                        _eventDate = selectedDate;
                      });
                      Navigator.of(context).pop();
                      _addMarker(position);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EVENT MAP'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(51.509364, -0.128928),
          zoom: 13.0,
          onTap: (tapPosition, latlng) {
            _addEventData(latlng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
    );
  }
}
