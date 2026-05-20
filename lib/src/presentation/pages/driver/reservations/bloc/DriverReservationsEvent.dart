import 'package:equatable/equatable.dart';

abstract class DriverReservationsEvent extends Equatable {
  const DriverReservationsEvent();
  @override
  List<Object?> get props => [];
}

class LoadReservationsByTrip extends DriverReservationsEvent {
  final int idTrip;
  const LoadReservationsByTrip({required this.idTrip});
  @override List<Object?> get props => [idTrip];
}

class AcceptReservation extends DriverReservationsEvent {
  final int idReservation;
  const AcceptReservation({required this.idReservation});
  @override List<Object?> get props => [idReservation];
}

class RejectReservation extends DriverReservationsEvent {
  final int idReservation;
  const RejectReservation({required this.idReservation});
  @override List<Object?> get props => [idReservation];
}
