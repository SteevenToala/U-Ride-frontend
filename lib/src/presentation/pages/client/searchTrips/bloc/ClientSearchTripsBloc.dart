import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/shared-trips/SharedTripsUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/data/dataSource/local/SharefPref.dart';
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'ClientSearchTripsEvent.dart';
import 'ClientSearchTripsState.dart';

class ClientSearchTripsBloc extends Bloc<ClientSearchTripsEvent, ClientSearchTripsState> {
  final SharedTripsUseCases sharedTripsUseCases;

  ClientSearchTripsBloc({required this.sharedTripsUseCases})
      : super(const ClientSearchTripsState()) {
    on<FilterOriginChanged>((e, emit) => emit(state.copyWith(filterOrigin: e.value)));
    on<FilterDestinationChanged>((e, emit) => emit(state.copyWith(filterDestination: e.value)));
    on<FilterDateChanged>((e, emit) => emit(state.copyWith(filterDate: e.value)));
    on<ClearFilters>((e, emit) => emit(const ClientSearchTripsState()));
    on<SearchTrips>(_onSearch);
  }

  Future<void> _onSearch(SearchTrips event, Emitter<ClientSearchTripsState> emit) async {
    emit(state.copyWith(isLoading: true));
    final response = await sharedTripsUseCases.getAll.run(
      originZone: state.filterOrigin.isNotEmpty ? state.filterOrigin : null,
      destinationZone: state.filterDestination.isNotEmpty ? state.filterDestination : null,
      date: state.filterDate.isNotEmpty ? state.filterDate : null,
    );
    if (response is Success<List<SharedTrip>>) {
      final pref = SharefPref();
      final session = await pref.read('user');
      int? userId;
      if (session != null) {
        final auth = AuthResponse.fromJson(session);
        userId = auth.user.id;
      }
      
      // Filter locally for available seats too, and exclude user's own trips
      final available = response.data.where((t) => t.hasAvailableSeats && t.isScheduled && t.idDriver != userId).toList();
      emit(state.copyWith(trips: available, isLoading: false, response: response));
    } else {
      emit(state.copyWith(isLoading: false, response: response));
    }
  }
}
