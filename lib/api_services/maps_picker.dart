import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPicker extends StatefulWidget {
  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  final String _googleApiKey = "YOUR_GOOGLE_API_KEY"; // Replace with your actual API key
  final TextEditingController _searchController = TextEditingController();

  void _locateCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خدمات الموقع معطلة. الرجاء تفعيلها.')),
      );
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفض إذن الموقع.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم رفض إذن الموقع نهائيًا.')),
      );
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Update the map view to the current location
    LatLng currentLocation = LatLng(position.latitude, position.longitude);
    _mapController?.animateCamera(CameraUpdate.newLatLng(currentLocation));

    setState(() {
      _selectedLocation = currentLocation;
    });
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال مكان للبحث')),
      );
      return;
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleApiKey&language=ar&region=IQ',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          if (predictions.isNotEmpty) {
            final placeId = predictions[0]['place_id'];
            await _moveToSelectedPlace(placeId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('لم يتم العثور على نتائج')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ أثناء البحث: ${data['status']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الاتصال بالخادم')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء البحث: $e')),
      );
    }
  }

  Future<void> _moveToSelectedPlace(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleApiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final selectedLocation = LatLng(location['lat'], location['lng']);

          _mapController?.animateCamera(CameraUpdate.newLatLng(selectedLocation));

          setState(() {
            _selectedLocation = selectedLocation;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ أثناء جلب تفاصيل المكان: ${data['status']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الاتصال بالخادم')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء جلب تفاصيل المكان: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختر الموقع على الخريطة'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _searchLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن مكان...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(33.3152, 44.3661), // Default to Baghdad, Iraq
                    zoom: 10,
                  ),
                  onTap: (LatLng position) {
                    setState(() {
                      _selectedLocation = position;
                    });
                  },
                  markers: _selectedLocation != null
                      ? {
                    Marker(
                      markerId: MarkerId('selected-location'),
                      position: _selectedLocation!,
                    ),
                  }
                      : {},
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    child: Icon(Icons.my_location),
                    onPressed: _locateCurrentPosition,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          if (_selectedLocation != null) {
            final String googleMapUrl =
                'https://www.google.com/maps?q=${_selectedLocation!.latitude},${_selectedLocation!.longitude}';
            Navigator.pop(context, googleMapUrl);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('الرجاء اختيار موقع')),
            );
          }
        },
      ),
    );
  }
}