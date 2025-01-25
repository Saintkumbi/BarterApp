import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  LatLng _selectedLocation = LatLng(38.9869, -76.9426); // UMD College Park
  double _searchRadius = 5.0; // Default radius in km
  double _currentZoom = 12.0; // Initial map zoom level

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLocation = LatLng(
        prefs.getDouble('latitude') ?? 38.9869,
        prefs.getDouble('longitude') ?? -76.9426,
      );
      _searchRadius = prefs.getDouble('radius') ?? 5.0;
    });
  }

  Future<void> _saveLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', _selectedLocation.latitude);
    await prefs.setDouble('longitude', _selectedLocation.longitude);
    await prefs.setDouble('radius', _searchRadius);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Filter trades by location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Map Section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(top:20, left: 10, right: 10, bottom: 16,),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlutterMap(
                  options: MapOptions(
                    center: _selectedLocation,
                    zoom: _currentZoom,
                    onTap: (tapPosition, LatLng location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                    onPositionChanged: (MapPosition position, bool hasGesture) {
                      if (hasGesture) {
                        setState(() {
                          _selectedLocation = position.center!;
                          _currentZoom = position.zoom!;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _selectedLocation,
                          color: Colors.blue.withOpacity(0.3), // Semitransparent blue
                          borderStrokeWidth: 2.0,
                          borderColor: Colors.blue,
                          radius: _getVisibleRadius(_searchRadius, _currentZoom),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          builder: (_) => Icon(Icons.location_on,
                              color: Colors.red, size: 20), // Red pinpoint
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Radius Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Radius: ${_searchRadius.toStringAsFixed(1)} km',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: _searchRadius,
                  min: 1.0,
                  max: 50.0,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey,
                  onChanged: (double value) {
                    setState(() {
                      _searchRadius = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Confirm Button
          Padding(
            padding: const EdgeInsets.only(top:20 , bottom: 30),
            child: ElevatedButton(
              
              onPressed: () async {
                await _saveLocationData();
                Navigator.pop(context, {
                  'location': _selectedLocation,
                  'radius': _searchRadius,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Confirm Location',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getVisibleRadius(double radiusInKm, double zoom) {
    const double earthCircumference = 40075.0; 
    double metersPerPixel = earthCircumference * 1000 / (256 * (1 << zoom.toInt()));
    return radiusInKm * 1000 / metersPerPixel;
  }
}
