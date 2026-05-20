import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/repository/SharedTripsRepository.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class CreateSharedTripUseCase {
  final SharedTripsRepository _repository;
  CreateSharedTripUseCase(this._repository);
  Future<Resource<SharedTrip>> run(SharedTrip trip) => _repository.create(trip);
}

class UpdateSharedTripUseCase {
  final SharedTripsRepository _repository;
  UpdateSharedTripUseCase(this._repository);
  Future<Resource<SharedTrip>> run(int id, SharedTrip trip) => _repository.update(id, trip);
}

class DeleteSharedTripUseCase {
  final SharedTripsRepository _repository;
  DeleteSharedTripUseCase(this._repository);
  Future<Resource<bool>> run(int id) => _repository.delete(id);
}

class GetSharedTripsUseCase {
  final SharedTripsRepository _repository;
  GetSharedTripsUseCase(this._repository);
  Future<Resource<List<SharedTrip>>> run({
    String? originZone,
    String? destinationZone,
    String? date,
  }) => _repository.getAll(originZone: originZone, destinationZone: destinationZone, date: date);
}

class GetSharedTripByIdUseCase {
  final SharedTripsRepository _repository;
  GetSharedTripByIdUseCase(this._repository);
  Future<Resource<SharedTrip>> run(int id) => _repository.getById(id);
}

class GetTripsByDriverUseCase {
  final SharedTripsRepository _repository;
  GetTripsByDriverUseCase(this._repository);
  Future<Resource<List<SharedTrip>>> run(int idDriver) => _repository.getByDriver(idDriver);
}

class GetTripsByPassengerUseCase {
  final SharedTripsRepository _repository;
  GetTripsByPassengerUseCase(this._repository);
  Future<Resource<List<SharedTrip>>> run(int idPassenger) => _repository.getByPassenger(idPassenger);
}

class StartSharedTripUseCase {
  final SharedTripsRepository _repository;
  StartSharedTripUseCase(this._repository);
  Future<Resource<SharedTrip>> run(int id) => _repository.startTrip(id);
}

class CancelSharedTripUseCase {
  final SharedTripsRepository _repository;
  CancelSharedTripUseCase(this._repository);
  Future<Resource<SharedTrip>> run(int id) => _repository.cancelTrip(id);
}

class FinishSharedTripUseCase {
  final SharedTripsRepository _repository;
  FinishSharedTripUseCase(this._repository);
  Future<Resource<SharedTrip>> run(int id) => _repository.finishTrip(id);
}

// Contenedor de todos los use cases de viajes compartidos
class SharedTripsUseCases {
  final CreateSharedTripUseCase create;
  final UpdateSharedTripUseCase update;
  final DeleteSharedTripUseCase delete;
  final GetSharedTripsUseCase getAll;
  final GetSharedTripByIdUseCase getById;
  final GetTripsByDriverUseCase getByDriver;
  final GetTripsByPassengerUseCase getByPassenger;
  final StartSharedTripUseCase startTrip;
  final CancelSharedTripUseCase cancelTrip;
  final FinishSharedTripUseCase finishTrip;

  SharedTripsUseCases({
    required this.create,
    required this.update,
    required this.delete,
    required this.getAll,
    required this.getById,
    required this.getByDriver,
    required this.getByPassenger,
    required this.startTrip,
    required this.cancelTrip,
    required this.finishTrip,
  });
}
