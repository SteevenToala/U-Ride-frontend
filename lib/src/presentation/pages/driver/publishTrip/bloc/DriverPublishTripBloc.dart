import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/models/TripStatus.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/shared-trips/SharedTripsUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'DriverPublishTripEvent.dart';
import 'DriverPublishTripState.dart';

class DriverPublishTripBloc extends Bloc<DriverPublishTripEvent, DriverPublishTripState> {
  final SharedTripsUseCases sharedTripsUseCases;

  DriverPublishTripBloc({required this.sharedTripsUseCases})
      : super(const DriverPublishTripState()) {
    on<OriginZoneChanged>((e, emit) => emit(state.copyWith(originZone: e.value, originLat: e.lat, originLng: e.lng)));
    on<DestinationZoneChanged>((e, emit) => emit(state.copyWith(destinationZone: e.value, destinationLat: e.lat, destinationLng: e.lng)));
    on<DepartureTimeChanged>((e, emit) => emit(state.copyWith(departureTime: e.value)));
    on<TotalSeatsChanged>((e, emit) => emit(state.copyWith(totalSeats: e.value)));
    on<FarePerSeatChanged>((e, emit) => emit(state.copyWith(farePerSeat: e.value)));
    on<NotesChanged>((e, emit) => emit(state.copyWith(notes: e.value)));
    on<ResetForm>((e, emit) => emit(const DriverPublishTripState()));
    on<LoadTripForEdit>(_onLoadTripForEdit);
    on<SubmitPublishTrip>(_onSubmitPublish);
    on<SubmitUpdateTrip>(_onSubmitUpdate);
  }

  void _onLoadTripForEdit(LoadTripForEdit event, Emitter<DriverPublishTripState> emit) {
    final trip = event.trip;
    emit(state.copyWith(
      originZone: trip.originZone,
      originLat: trip.originLat ?? 0.0,
      originLng: trip.originLng ?? 0.0,
      destinationZone: trip.destinationZone,
      destinationLat: trip.destinationLat ?? 0.0,
      destinationLng: trip.destinationLng ?? 0.0,
      departureTime: trip.departureTime.toIso8601String(),
      totalSeats: trip.totalSeats.toString(),
      farePerSeat: trip.farePerSeat.toString(),
      notes: trip.notes ?? '',
      isEditing: true,
      editingTripId: trip.id,
    ));
  }

  Future<void> _onSubmitPublish(SubmitPublishTrip event, Emitter<DriverPublishTripState> emit) async {
    if (!state.isFormValid) {
      emit(state.copyWith(response: ErrorData('Por favor completa todos los campos requeridos')));
      return;
    }
    emit(state.copyWith(isLoading: true, response: Loading()));
    final trip = SharedTrip(
      idDriver: event.idDriver,
      originZone: state.originZone,
      originLat: state.originLat,
      originLng: state.originLng,
      destinationZone: state.destinationZone,
      destinationLat: state.destinationLat,
      destinationLng: state.destinationLng,
      departureTime: DateTime.parse(state.departureTime),
      totalSeats: int.tryParse(state.totalSeats) ?? 1,
      availableSeats: int.tryParse(state.totalSeats) ?? 1,
      farePerSeat: double.tryParse(state.farePerSeat) ?? 0.0,
      notes: state.notes.isNotEmpty ? state.notes : null,
      status: TripStatus.SCHEDULED,
    );
    final response = await sharedTripsUseCases.create.run(trip);
    emit(state.copyWith(isLoading: false, response: response));
  }

  Future<void> _onSubmitUpdate(SubmitUpdateTrip event, Emitter<DriverPublishTripState> emit) async {
    if (!state.isFormValid || state.editingTripId == null) {
      emit(state.copyWith(response: ErrorData('Datos del viaje inválidos')));
      return;
    }
    emit(state.copyWith(isLoading: true, response: Loading()));
    final trip = SharedTrip(
      idDriver: event.idDriver,
      originZone: state.originZone,
      originLat: state.originLat,
      originLng: state.originLng,
      destinationZone: state.destinationZone,
      destinationLat: state.destinationLat,
      destinationLng: state.destinationLng,
      departureTime: DateTime.parse(state.departureTime),
      totalSeats: int.tryParse(state.totalSeats) ?? 1,
      availableSeats: int.tryParse(state.totalSeats) ?? 1,
      farePerSeat: double.tryParse(state.farePerSeat) ?? 0.0,
      notes: state.notes.isNotEmpty ? state.notes : null,
      status: TripStatus.SCHEDULED,
    );
    final response = await sharedTripsUseCases.update.run(state.editingTripId!, trip);
    emit(state.copyWith(isLoading: false, response: response));
  }
}
