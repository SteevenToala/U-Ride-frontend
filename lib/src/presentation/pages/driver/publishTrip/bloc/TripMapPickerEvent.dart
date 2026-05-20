import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class TripMapPickerEvent extends Equatable {
  const TripMapPickerEvent();
  @override
  List<Object> get props => [];
}

class TripMapPickerInitEvent extends TripMapPickerEvent {}

class FindCurrentPosition extends TripMapPickerEvent {}

class ChangeMapCameraPosition extends TripMapPickerEvent {
  final double lat;
  final double lng;
  const ChangeMapCameraPosition({required this.lat, required this.lng});
  @override
  List<Object> get props => [lat, lng];
}

class OnCameraMove extends TripMapPickerEvent {
  final CameraPosition cameraPosition;
  const OnCameraMove({required this.cameraPosition});
  @override
  List<Object> get props => [cameraPosition];
}

class OnCameraIdle extends TripMapPickerEvent {}

class OnOriginSelected extends TripMapPickerEvent {
  final double lat;
  final double lng;
  final String description;

  const OnOriginSelected({
    required this.lat,
    required this.lng,
    required this.description,
  });

  @override
  List<Object> get props => [lat, lng, description];
}

class OnDestinationSelected extends TripMapPickerEvent {
  final double lat;
  final double lng;
  final String description;

  const OnDestinationSelected({
    required this.lat,
    required this.lng,
    required this.description,
  });

  @override
  List<Object> get props => [lat, lng, description];
}

class OnMapTapped extends TripMapPickerEvent {
  final LatLng position;
  const OnMapTapped({required this.position});
  @override
  List<Object> get props => [position];
}

class OnCenterPinSelected extends TripMapPickerEvent {}

class ResetSelection extends TripMapPickerEvent {}
