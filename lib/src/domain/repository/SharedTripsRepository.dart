import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

abstract class SharedTripsRepository {
  Future<Resource<SharedTrip>> create(SharedTrip trip);
  Future<Resource<SharedTrip>> update(int id, SharedTrip trip);
  Future<Resource<bool>> delete(int id);
  Future<Resource<List<SharedTrip>>> getAll({
    String? originZone,
    String? destinationZone,
    String? date,
  });
  Future<Resource<SharedTrip>> getById(int id);
  Future<Resource<List<SharedTrip>>> getByDriver(int idDriver);
  Future<Resource<List<SharedTrip>>> getByPassenger(int idPassenger);
  Future<Resource<SharedTrip>> startTrip(int id);
  Future<Resource<SharedTrip>> cancelTrip(int id);
  Future<Resource<SharedTrip>> finishTrip(int id);
}
