import 'package:equatable/equatable.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class DriverMyTripsState extends Equatable {
  final Resource? response;
  final List<SharedTrip> trips;
  final bool isLoading;

  const DriverMyTripsState({
    this.response,
    this.trips = const [],
    this.isLoading = false,
  });

  DriverMyTripsState copyWith({
    Resource? response,
    List<SharedTrip>? trips,
    bool? isLoading,
  }) {
    return DriverMyTripsState(
      response: response ?? this.response,
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [response, trips, isLoading];
}
