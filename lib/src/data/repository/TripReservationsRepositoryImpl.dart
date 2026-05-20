import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/TripReservationsService.dart';
import 'package:indriver_clone_flutter/src/domain/models/TripReservation.dart';
import 'package:indriver_clone_flutter/src/domain/repository/TripReservationsRepository.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class TripReservationsRepositoryImpl implements TripReservationsRepository {
  final TripReservationsService _service;
  TripReservationsRepositoryImpl(this._service);

  @override
  Future<Resource<TripReservation>> create(TripReservation reservation) => _service.create(reservation);

  @override
  Future<Resource<List<TripReservation>>> getByTrip(int idTrip) => _service.getByTrip(idTrip);

  @override
  Future<Resource<List<TripReservation>>> getByPassenger(int idPassenger) => _service.getByPassenger(idPassenger);

  @override
  Future<Resource<TripReservation>> accept(int id) => _service.accept(id);

  @override
  Future<Resource<TripReservation>> reject(int id) => _service.reject(id);

  @override
  Future<Resource<TripReservation>> cancel(int id) => _service.cancel(id);
}
