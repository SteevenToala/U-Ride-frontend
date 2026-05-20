import 'package:equatable/equatable.dart';

abstract class ClientSearchTripsEvent extends Equatable {
  const ClientSearchTripsEvent();
  @override
  List<Object?> get props => [];
}

class SearchTrips extends ClientSearchTripsEvent {
  final String originZone;
  final String destinationZone;
  final String date;
  const SearchTrips({this.originZone = '', this.destinationZone = '', this.date = ''});
  @override List<Object?> get props => [originZone, destinationZone, date];
}

class FilterOriginChanged extends ClientSearchTripsEvent {
  final String value;
  const FilterOriginChanged(this.value);
  @override List<Object?> get props => [value];
}

class FilterDestinationChanged extends ClientSearchTripsEvent {
  final String value;
  const FilterDestinationChanged(this.value);
  @override List<Object?> get props => [value];
}

class FilterDateChanged extends ClientSearchTripsEvent {
  final String value;
  const FilterDateChanged(this.value);
  @override List<Object?> get props => [value];
}

class ClearFilters extends ClientSearchTripsEvent {
  const ClearFilters();
}
