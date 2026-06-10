import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/TripReservation.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/trip-reservations/TripReservationsUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'DriverReservationsEvent.dart';
import 'DriverReservationsState.dart';

class DriverReservationsBloc extends Bloc<DriverReservationsEvent, DriverReservationsState> {
  final TripReservationsUseCases reservationsUseCases;

  DriverReservationsBloc({required this.reservationsUseCases})
      : super(const DriverReservationsState()) {
    on<LoadReservationsByTrip>(_onLoad);
    on<AcceptReservation>(_onAccept);
    on<RejectReservation>(_onReject);
    on<ConfirmPayment>(_onConfirmPayment);
  }

  Future<void> _onLoad(LoadReservationsByTrip event, Emitter<DriverReservationsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final response = await reservationsUseCases.getByTrip.run(event.idTrip);
    if (response is Success<List<TripReservation>>) {
      emit(state.copyWith(reservations: response.data, isLoading: false, response: response));
    } else {
      emit(state.copyWith(isLoading: false, response: response));
    }
  }

  Future<void> _onAccept(AcceptReservation event, Emitter<DriverReservationsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final response = await reservationsUseCases.accept.run(event.idReservation);
    if (response is Success<TripReservation>) {
      final updated = state.reservations.map((r) => r.id == event.idReservation ? response.data : r).toList();
      emit(state.copyWith(reservations: updated, isLoading: false, response: response));
    } else {
      emit(state.copyWith(isLoading: false, response: response));
    }
  }

  Future<void> _onReject(RejectReservation event, Emitter<DriverReservationsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final response = await reservationsUseCases.reject.run(event.idReservation);
    if (response is Success<TripReservation>) {
      final updated = state.reservations.map((r) => r.id == event.idReservation ? response.data : r).toList();
      emit(state.copyWith(reservations: updated, isLoading: false, response: response));
    } else {
      emit(state.copyWith(isLoading: false, response: response));
    }
  }

  Future<void> _onConfirmPayment(ConfirmPayment event, Emitter<DriverReservationsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final response = await reservationsUseCases.confirmPayment.run(event.idReservation);
    if (response is Success<TripReservation>) {
      final updated = state.reservations.map((r) => r.id == event.idReservation ? response.data : r).toList();
      emit(state.copyWith(reservations: updated, isLoading: false, response: response));
    } else {
      emit(state.copyWith(isLoading: false, response: response));
    }
  }
}
