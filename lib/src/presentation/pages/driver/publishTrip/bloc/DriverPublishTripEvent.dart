import 'package:equatable/equatable.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';

abstract class DriverPublishTripEvent extends Equatable {
  const DriverPublishTripEvent();
  @override
  List<Object?> get props => [];
}

class OriginZoneChanged extends DriverPublishTripEvent {
  final String value;
  final double lat;
  final double lng;
  const OriginZoneChanged(this.value, this.lat, this.lng);
  @override List<Object?> get props => [value, lat, lng];
}

class DestinationZoneChanged extends DriverPublishTripEvent {
  final String value;
  final double lat;
  final double lng;
  const DestinationZoneChanged(this.value, this.lat, this.lng);
  @override List<Object?> get props => [value, lat, lng];
}

class DepartureTimeChanged extends DriverPublishTripEvent {
  final String value;
  const DepartureTimeChanged(this.value);
  @override List<Object?> get props => [value];
}

class TotalSeatsChanged extends DriverPublishTripEvent {
  final String value;
  const TotalSeatsChanged(this.value);
  @override List<Object?> get props => [value];
}

class FarePerSeatChanged extends DriverPublishTripEvent {
  final String value;
  const FarePerSeatChanged(this.value);
  @override List<Object?> get props => [value];
}

class NotesChanged extends DriverPublishTripEvent {
  final String value;
  const NotesChanged(this.value);
  @override List<Object?> get props => [value];
}

class SubmitPublishTrip extends DriverPublishTripEvent {
  final int idDriver;
  const SubmitPublishTrip({required this.idDriver});
  @override List<Object?> get props => [idDriver];
}

class LoadTripForEdit extends DriverPublishTripEvent {
  final SharedTrip trip;
  const LoadTripForEdit(this.trip);
  @override List<Object?> get props => [trip];
}

class SubmitUpdateTrip extends DriverPublishTripEvent {
  final int idDriver;
  const SubmitUpdateTrip({required this.idDriver});
  @override List<Object?> get props => [idDriver];
}

class ResetForm extends DriverPublishTripEvent {
  const ResetForm();
}
