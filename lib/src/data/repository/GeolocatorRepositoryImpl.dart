import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_clone_flutter/src/data/api/ApiKeyGoogle.dart';
import 'package:indriver_clone_flutter/src/domain/models/PlacemarkData.dart';
import 'package:indriver_clone_flutter/src/domain/repository/GeolocatorRepository.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


class GeolocatorRepositoryImpl implements GeolocatorRepository {
  @override
  Future<Position> findPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('La ubicacion no esta activada');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permiso no otorgado por el usuario');
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('Permiso no otorgado por el usuario permanentemente');
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 
    return await Geolocator.getCurrentPosition();
  }

  @override
  Future<BitmapDescriptor> createMarkerFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor descriptor = await BitmapDescriptor.fromAssetImage(configuration, path);
    return descriptor;
  }

  @override
  Marker getMarker(String markerId, double lat, double lng, String title, String content, BitmapDescriptor imageMarker) {
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
      markerId: id,
      icon: imageMarker,
      position: LatLng(lat,lng),
      infoWindow: InfoWindow(title: title, snippet: content)
    );
    return marker;
  }

  @override
  Future<PlacemarkData?> getPlacemarkData(CameraPosition cameraPosition) async {
    double lat = cameraPosition.target.latitude;
    double lng = cameraPosition.target.longitude;
    try {
      List<Placemark> placemarkList = await placemarkFromCoordinates(lat, lng);
      if (placemarkList != null && placemarkList.isNotEmpty) {
        String direction = placemarkList[0].thoroughfare ?? '';
        String street = placemarkList[0].subThoroughfare ?? '';
        String city = placemarkList[0].locality ?? '';
        String department = placemarkList[0].administrativeArea ?? '';
        
        String address = [direction, street, city, department].where((e) => e.isNotEmpty).join(', ');
        if (address.isEmpty) address = 'Ubicación seleccionada';

        return PlacemarkData(address: address, lat: lat, lng: lng);
      }
    } catch (e) {
      print('Geocoding plugin failed: $e. Falling back to Google API...');
    }

    // Fallback for Web or when plugin fails
    try {
      final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$API_KEY_GOOGLE');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final formattedAddress = data['results'][0]['formatted_address'];
          return PlacemarkData(address: formattedAddress, lat: lat, lng: lng);
        }
      }
    } catch (e) {
      print('Google API Geocoding fallback failed: $e');
    }

    return null;
  }
  
  @override
  Future<List<LatLng>> getPolyline(LatLng pickUpLatLng, LatLng destinationLatLng) async {
    List<LatLng> polylineCoordinates = [];
    try {
      PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
          API_KEY_GOOGLE,
          PointLatLng(pickUpLatLng.latitude, pickUpLatLng.longitude),
          PointLatLng(destinationLatLng.latitude, destinationLatLng.longitude),
          travelMode: TravelMode.driving,
      );
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        // Fallback: draw straight line
        polylineCoordinates.add(pickUpLatLng);
        polylineCoordinates.add(destinationLatLng);
      }
    } catch (e) {
      print('Error en getPolyline: $e');
      // Fallback: draw straight line if API fails (CORS on web or invalid key)
      polylineCoordinates.add(pickUpLatLng);
      polylineCoordinates.add(destinationLatLng);
    }
    return polylineCoordinates;
  }
  @override
  Stream<Position> getPositionStream() {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

}