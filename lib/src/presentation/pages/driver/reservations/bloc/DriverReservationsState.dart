import 'package:equatable/equatable.dart';
import 'package:indriver_clone_flutter/src/domain/models/TripReservation.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class DriverReservationsState extends Equatable {
  final Resource? response;
  final List<TripReservation> reservations;
  final bool isLoading;

  const DriverReservationsState({
    this.response,
    this.reservations = const [],
    this.isLoading = false,
  });

  DriverReservationsState copyWith({
    Resource? response,
    List<TripReservation>? reservations,
    bool? isLoading,
  }) {
    return DriverReservationsState(
      response: response ?? this.response,
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [response, reservations, isLoading];
}
