import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_clone_flutter/src/domain/models/PlacemarkData.dart';

class TripMapPickerState extends Equatable {
  final Completer<GoogleMapController>? controller;
  final CameraPosition cameraPosition;
  final PlacemarkData? origin;
  final PlacemarkData? destination;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool isLoadingAddress;
  final bool selectingOrigin;

  const TripMapPickerState({
    this.controller,
    this.cameraPosition = const CameraPosition(
      target: LatLng(-1.2543, -78.6227), // Ecuador center (Ambato area)
      zoom: 15.0,
    ),
    this.origin,
    this.destination,
    this.markers = const {},
    this.polylines = const {},
    this.isLoadingAddress = false,
    this.selectingOrigin = true,
  });

  TripMapPickerState copyWith({
    Completer<GoogleMapController>? controller,
    CameraPosition? cameraPosition,
    PlacemarkData? origin,
    PlacemarkData? destination,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    bool? isLoadingAddress,
    bool? selectingOrigin,
  }) {
    return TripMapPickerState(
      controller: controller ?? this.controller,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      selectingOrigin: selectingOrigin ?? this.selectingOrigin,
    );
  }

  bool get hasLocation => origin != null && destination != null;

  @override
  List<Object?> get props => [controller, cameraPosition, origin, destination, markers, polylines, isLoadingAddress, selectingOrigin];
}
