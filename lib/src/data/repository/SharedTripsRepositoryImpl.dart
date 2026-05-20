import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/SharedTripsService.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/repository/SharedTripsRepository.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class SharedTripsRepositoryImpl implements SharedTripsRepository {
  final SharedTripsService _service;
  SharedTripsRepositoryImpl(this._service);

  @override
  Future<Resource<SharedTrip>> create(SharedTrip trip) => _service.create(trip);

  @override
  Future<Resource<SharedTrip>> update(int id, SharedTrip trip) => _service.update(id, trip);

  @override
  Future<Resource<bool>> delete(int id) => _service.delete(id);

  @override
  Future<Resource<List<SharedTrip>>> getAll({String? originZone, String? destinationZone, String? date}) =>
      _service.getAll(originZone: originZone, destinationZone: destinationZone, date: date);

  @override
  Future<Resource<SharedTrip>> getById(int id) => _service.getById(id);

  @override
  Future<Resource<List<SharedTrip>>> getByDriver(int idDriver) => _service.getByDriver(idDriver);

  @override
  Future<Resource<List<SharedTrip>>> getByPassenger(int idPassenger) => _service.getByPassenger(idPassenger);

  @override
  Future<Resource<SharedTrip>> startTrip(int id) => _service.startTrip(id);

  @override
  Future<Resource<SharedTrip>> cancelTrip(int id) => _service.cancelTrip(id);

  @override
  Future<Resource<SharedTrip>> finishTrip(int id) => _service.finishTrip(id);
}
