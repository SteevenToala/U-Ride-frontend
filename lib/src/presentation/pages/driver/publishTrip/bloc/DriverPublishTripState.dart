import 'package:equatable/equatable.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class DriverPublishTripState extends Equatable {
  final Resource? response;
  final bool isLoading;

  // Campos del formulario
  final String originZone;
  final double originLat;
  final double originLng;
  final String destinationZone;
  final double destinationLat;
  final double destinationLng;
  final String departureTime;
  final String totalSeats;
  final String farePerSeat;
  final String notes;
  final bool isEditing;
  final int? editingTripId;

  const DriverPublishTripState({
    this.response,
    this.isLoading = false,
    this.originZone = '',
    this.originLat = 0.0,
    this.originLng = 0.0,
    this.destinationZone = '',
    this.destinationLat = 0.0,
    this.destinationLng = 0.0,
    this.departureTime = '',
    this.totalSeats = '1',
    this.farePerSeat = '',
    this.notes = '',
    this.isEditing = false,
    this.editingTripId,
  });

  DriverPublishTripState copyWith({
    Resource? response,
    bool? isLoading,
    String? originZone,
    double? originLat,
    double? originLng,
    String? destinationZone,
    double? destinationLat,
    double? destinationLng,
    String? departureTime,
    String? totalSeats,
    String? farePerSeat,
    String? notes,
    bool? isEditing,
    int? editingTripId,
  }) {
    return DriverPublishTripState(
      response: response ?? this.response,
      isLoading: isLoading ?? this.isLoading,
      originZone: originZone ?? this.originZone,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destinationZone: destinationZone ?? this.destinationZone,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      departureTime: departureTime ?? this.departureTime,
      totalSeats: totalSeats ?? this.totalSeats,
      farePerSeat: farePerSeat ?? this.farePerSeat,
      notes: notes ?? this.notes,
      isEditing: isEditing ?? this.isEditing,
      editingTripId: editingTripId ?? this.editingTripId,
    );
  }

  bool get isFormValid =>
      originZone.isNotEmpty &&
      destinationZone.isNotEmpty &&
      departureTime.isNotEmpty &&
      farePerSeat.isNotEmpty;

  @override
  List<Object?> get props => [
        response, isLoading, originZone, originLat, originLng, destinationZone, destinationLat, destinationLng,
        departureTime, totalSeats, farePerSeat, notes, isEditing, editingTripId,
      ];
}
