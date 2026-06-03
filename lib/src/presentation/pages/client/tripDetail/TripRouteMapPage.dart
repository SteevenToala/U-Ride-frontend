import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_clone_flutter/injection.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/geolocator/GeolocatorUseCases.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class TripRouteMapPage extends StatefulWidget {
  final SharedTrip trip;

  const TripRouteMapPage({super.key, required this.trip});

  @override
  State<TripRouteMapPage> createState() => _TripRouteMapPageState();
}

class _TripRouteMapPageState extends State<TripRouteMapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoadingRoute = true;

  @override
  void initState() {
    super.initState();
    _initMapData();
  }

  Future<void> _initMapData() async {
    final useCases = locator<GeolocatorUseCases>();

    final origin = LatLng(widget.trip.originLat ?? 0.0, widget.trip.originLng ?? 0.0);
    final dest = LatLng(widget.trip.destinationLat ?? 0.0, widget.trip.destinationLng ?? 0.0);

    if (origin.latitude == 0 || dest.latitude == 0) {
      setState(() => _isLoadingRoute = false);
      return;
    }

    try {
      BitmapDescriptor originIcon;
      try {
        originIcon = await useCases.createMarker.run('assets/img/location_blue.png');
      } catch (_) {
        originIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      }
      
      BitmapDescriptor destIcon;
      try {
        destIcon = await useCases.createMarker.run('assets/img/car_pin.png');
      } catch (_) {
        destIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      }

      final m1 = useCases.getMarker.run('origin', origin.latitude, origin.longitude, 'Origen', widget.trip.originZone, originIcon);
      final m2 = useCases.getMarker.run('dest', dest.latitude, dest.longitude, 'Destino', widget.trip.destinationZone, destIcon);
      
      _markers.add(m1);
      _markers.add(m2);

      final polylinePoints = await useCases.getPolyline.run(origin, dest);
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        color: AppTheme.accentColor,
        points: polylinePoints,
        width: 5,
      );

      _polylines.add(polyline);

      if (mounted) {
        setState(() => _isLoadingRoute = false);
        _fitBounds(origin, dest);
      }
    } catch (e) {
      print('Error loading route map: $e');
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  Future<void> _fitBounds(LatLng origin, LatLng dest) async {
    final controller = await _controller.future;
    
    double minLat = origin.latitude < dest.latitude ? origin.latitude : dest.latitude;
    double maxLat = origin.latitude > dest.latitude ? origin.latitude : dest.latitude;
    double minLng = origin.longitude < dest.longitude ? origin.longitude : dest.longitude;
    double maxLng = origin.longitude > dest.longitude ? origin.longitude : dest.longitude;

    controller.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      50.0, // padding
    ));
  }

  @override
  Widget build(BuildContext context) {
    final origin = LatLng(widget.trip.originLat ?? 0.0, widget.trip.originLng ?? 0.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDarkCard,
        title: const Text('Ruta del Viaje', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: origin.latitude != 0 ? origin : const LatLng(-1.2543, -78.6227),
                zoom: 14,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                // Dark mode style
                controller.setMapStyle('[ { "featureType": "all", "elementType": "labels.text.fill", "stylers": [ { "color": "#ffffff" } ] }, { "featureType": "all", "elementType": "labels.text.stroke", "stylers": [ { "color": "#000000" }, { "lightness": 13 } ] }, { "featureType": "administrative", "elementType": "geometry.fill", "stylers": [ { "color": "#000000" } ] }, { "featureType": "administrative", "elementType": "geometry.stroke", "stylers": [ { "color": "#144b53" }, { "lightness": 14 }, { "weight": 1.4 } ] }, { "featureType": "landscape", "elementType": "all", "stylers": [ { "color": "#08304b" } ] }, { "featureType": "poi", "elementType": "geometry", "stylers": [ { "color": "#0c4152" }, { "lightness": 5 } ] }, { "featureType": "road.highway", "elementType": "geometry.fill", "stylers": [ { "color": "#000000" } ] }, { "featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [ { "color": "#0b434f" }, { "lightness": 25 } ] }, { "featureType": "road.arterial", "elementType": "geometry.fill", "stylers": [ { "color": "#000000" } ] }, { "featureType": "road.arterial", "elementType": "geometry.stroke", "stylers": [ { "color": "#0b3d51" }, { "lightness": 16 } ] }, { "featureType": "road.local", "elementType": "geometry", "stylers": [ { "color": "#000000" } ] }, { "featureType": "transit", "elementType": "all", "stylers": [ { "color": "#146474" } ] }, { "featureType": "water", "elementType": "all", "stylers": [ { "color": "#021019" } ] } ]');
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
            ),
          ),
          if (_isLoadingRoute)
            const Center(
              child: Card(
                color: AppTheme.backgroundDarkCard,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppTheme.accentColor),
                      SizedBox(width: 16),
                      Text('Calculando ruta...', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
