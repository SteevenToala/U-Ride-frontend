import 'package:indriver_clone_flutter/src/domain/models/TripReservation.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

abstract class TripReservationsRepository {
  Future<Resource<TripReservation>> create(TripReservation reservation);
  Future<Resource<List<TripReservation>>> getByTrip(int idTrip);
  Future<Resource<List<TripReservation>>> getByPassenger(int idPassenger);
  Future<Resource<TripReservation>> accept(int id);
  Future<Resource<TripReservation>> reject(int id);
  Future<Resource<TripReservation>> cancel(int id);
  Future<Resource<TripReservation>> confirmPayment(int id);
  Future<Resource<Map<String, dynamic>>> createPaypalOrder(double amount);
}
