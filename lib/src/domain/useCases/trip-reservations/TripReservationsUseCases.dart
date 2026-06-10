import 'package:indriver_clone_flutter/src/domain/models/TripReservation.dart';
import 'package:indriver_clone_flutter/src/domain/repository/TripReservationsRepository.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class CreateReservationUseCase {
  final TripReservationsRepository _repository;
  CreateReservationUseCase(this._repository);
  Future<Resource<TripReservation>> run(TripReservation reservation) => _repository.create(reservation);
}

class GetReservationsByTripUseCase {
  final TripReservationsRepository _repository;
  GetReservationsByTripUseCase(this._repository);
  Future<Resource<List<TripReservation>>> run(int idTrip) => _repository.getByTrip(idTrip);
}

class GetReservationsByPassengerUseCase {
  final TripReservationsRepository _repository;
  GetReservationsByPassengerUseCase(this._repository);
  Future<Resource<List<TripReservation>>> run(int idPassenger) => _repository.getByPassenger(idPassenger);
}

class AcceptReservationUseCase {
  final TripReservationsRepository _repository;
  AcceptReservationUseCase(this._repository);
  Future<Resource<TripReservation>> run(int id) => _repository.accept(id);
}

class RejectReservationUseCase {
  final TripReservationsRepository _repository;
  RejectReservationUseCase(this._repository);
  Future<Resource<TripReservation>> run(int id) => _repository.reject(id);
}

class CancelReservationUseCase {
  final TripReservationsRepository _repository;
  CancelReservationUseCase(this._repository);
  Future<Resource<TripReservation>> run(int id) => _repository.cancel(id);
}

class ConfirmPaymentUseCase {
  final TripReservationsRepository _repository;
  ConfirmPaymentUseCase(this._repository);
  Future<Resource<TripReservation>> run(int id) => _repository.confirmPayment(id);
}

class CreatePaypalOrderUseCase {
  final TripReservationsRepository _repository;
  CreatePaypalOrderUseCase(this._repository);
  Future<Resource<Map<String, dynamic>>> run(double amount) => _repository.createPaypalOrder(amount);
}

// Contenedor de todos los use cases de reservas
class TripReservationsUseCases {
  final CreateReservationUseCase create;
  final GetReservationsByTripUseCase getByTrip;
  final GetReservationsByPassengerUseCase getByPassenger;
  final AcceptReservationUseCase accept;
  final RejectReservationUseCase reject;
  final CancelReservationUseCase cancel;
  final ConfirmPaymentUseCase confirmPayment;
  final CreatePaypalOrderUseCase createPaypalOrder;

  TripReservationsUseCases({
    required this.create,
    required this.getByTrip,
    required this.getByPassenger,
    required this.accept,
    required this.reject,
    required this.cancel,
    required this.confirmPayment,
    required this.createPaypalOrder,
  });
}
