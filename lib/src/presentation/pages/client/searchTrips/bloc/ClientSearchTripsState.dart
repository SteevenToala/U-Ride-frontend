import 'package:equatable/equatable.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class ClientSearchTripsState extends Equatable {
  final Resource? response;
  final List<SharedTrip> trips;
  final bool isLoading;
  final String filterOrigin;
  final String filterDestination;
  final String filterDate;

  const ClientSearchTripsState({
    this.response,
    this.trips = const [],
    this.isLoading = false,
    this.filterOrigin = '',
    this.filterDestination = '',
    this.filterDate = '',
  });

  ClientSearchTripsState copyWith({
    Resource? response,
    List<SharedTrip>? trips,
    bool? isLoading,
    String? filterOrigin,
    String? filterDestination,
    String? filterDate,
  }) {
    return ClientSearchTripsState(
      response: response ?? this.response,
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      filterOrigin: filterOrigin ?? this.filterOrigin,
      filterDestination: filterDestination ?? this.filterDestination,
      filterDate: filterDate ?? this.filterDate,
    );
  }

  @override
  List<Object?> get props => [response, trips, isLoading, filterOrigin, filterDestination, filterDate];
}
