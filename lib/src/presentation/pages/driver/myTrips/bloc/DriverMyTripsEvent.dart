import 'package:equatable/equatable.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';

abstract class DriverMyTripsEvent extends Equatable {
  const DriverMyTripsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMyTrips extends DriverMyTripsEvent {
  final int idDriver;
  const LoadMyTrips({required this.idDriver});
  @override
  List<Object?> get props => [idDriver];
}

class DeleteTrip extends DriverMyTripsEvent {
  final int idTrip;
  const DeleteTrip({required this.idTrip});
  @override
  List<Object?> get props => [idTrip];
}

class StartTrip extends DriverMyTripsEvent {
  final int idTrip;
  const StartTrip({required this.idTrip});
  @override
  List<Object?> get props => [idTrip];
}

class CancelDriverTrip extends DriverMyTripsEvent {
  final int idTrip;
  const CancelDriverTrip({required this.idTrip});
  @override
  List<Object?> get props => [idTrip];
}

class FinishTrip extends DriverMyTripsEvent {
  final int idTrip;
  const FinishTrip({required this.idTrip});
  @override
  List<Object?> get props => [idTrip];
}
