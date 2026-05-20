import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/shared-trips/SharedTripsUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/data/dataSource/local/SharefPref.dart';
import 'DriverMyTripsEvent.dart';
import 'DriverMyTripsState.dart';

class DriverMyTripsBloc extends Bloc<DriverMyTripsEvent, DriverMyTripsState> {
  final SharedTripsUseCases sharedTripsUseCases;
  final SharefPref sharefPref;

  DriverMyTripsBloc({required this.sharedTripsUseCases, required this.sharefPref})
      : super(const DriverMyTripsState()) {
    on<LoadMyTrips>(_onLoadMyTrips);
    on<DeleteTrip>(_onDeleteTrip);
    on<StartTrip>(_onStartTrip);
    on<CancelDriverTrip>(_onCancelTrip);
    on<FinishTrip>(_onFinishTrip);
  }

  Future<int?> _getDriverId() async {
    final userSession = await sharefPref.read('user');
    if (userSession != null) {
      final auth = AuthResponse.fromJson(userSession);
      return auth.user.id;
    }
    return null;
  }

  Future<void> _onLoadMyTrips(LoadMyTrips event, Emitter<DriverMyTripsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final response = await sharedTripsUseCases.getByDriver.run(event.idDriver);
    if (response is Success<List<SharedTrip>>) {
      emit(state.copyWith(trips: response.data, isLoading: false, response: response));
    } else {
      emit(state.copyWith(isLoading: false, response: response));
    }
  }

  Future<void> _onDeleteTrip(DeleteTrip event, Emitter<DriverMyTripsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final response = await sharedTripsUseCases.delete.run(event.idTrip);
    if (response is Success<bool>) {
      final updatedTrips = state.trips.where((t) => t.id != event.idTrip).toList();
      emit(state.copyWith(trips: updatedTrips, isLoading: false, response: response));
    } else {
      emit(state.copyWith(isLoading: false, response: response));
    }
  }

  Future<void> _onStartTrip(StartTrip event, Emitter<DriverMyTripsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final response = await sharedTripsUseCases.startTrip.run(event.idTrip);
    if (response is Success<SharedTrip>) {
      final updatedTrips = state.trips.map((t) => t.id == event.idTrip ? response.data : t).toList();
      emit(state.copyWith(trips: updatedTrips, isLoading: false, response: response));
    } else {
      emit(state.copyWith(isLoading: false, response: response));
    }
  }

  Future<void> _onCancelTrip(CancelDriverTrip event, Emitter<DriverMyTripsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final response = await sharedTripsUseCases.cancelTrip.run(event.idTrip);
    if (response is Success<SharedTrip>) {
      final updatedTrips = state.trips.map((t) => t.id == event.idTrip ? response.data : t).toList();
      emit(state.copyWith(trips: updatedTrips, isLoading: false, response: response));
    } else {
      emit(state.copyWith(isLoading: false, response: response));
    }
  }

  Future<void> _onFinishTrip(FinishTrip event, Emitter<DriverMyTripsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final response = await sharedTripsUseCases.finishTrip.run(event.idTrip);
    if (response is Success<SharedTrip>) {
      final updatedTrips = state.trips.map((t) => t.id == event.idTrip ? response.data : t).toList();
      emit(state.copyWith(trips: updatedTrips, isLoading: false, response: response));
    } else {
      emit(state.copyWith(isLoading: false, response: response));
    }
  }
}
