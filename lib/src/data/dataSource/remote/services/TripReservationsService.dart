import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indriver_clone_flutter/src/data/api/ApiConfig.dart';
import 'package:indriver_clone_flutter/src/domain/models/TripReservation.dart';
import 'package:indriver_clone_flutter/src/domain/utils/ListToString.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class TripReservationsService {

  Future<Resource<TripReservation>> create(TripReservation reservation) async {
    try {
      Uri url = ApiConfig.buildUri( '/trip-reservations');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      String body = json.encode(reservation.toJson());
      final response = await http.post(url, headers: headers, body: body);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(TripReservation.fromJson(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<List<TripReservation>>> getByTrip(int idTrip) async {
    try {
      Uri url = ApiConfig.buildUri( '/trip-reservations/trip/$idTrip');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(TripReservation.fromJsonList(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<List<TripReservation>>> getByPassenger(int idPassenger) async {
    try {
      Uri url = ApiConfig.buildUri( '/trip-reservations/passenger/$idPassenger');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(TripReservation.fromJsonList(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<TripReservation>> accept(int id) async {
    try {
      Uri url = ApiConfig.buildUri( '/trip-reservations/$id/accept');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.put(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(TripReservation.fromJson(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<TripReservation>> reject(int id) async {
    try {
      Uri url = ApiConfig.buildUri( '/trip-reservations/$id/reject');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.put(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(TripReservation.fromJson(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<TripReservation>> cancel(int id) async {
    try {
      Uri url = ApiConfig.buildUri( '/trip-reservations/$id/cancel');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.put(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(TripReservation.fromJson(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<TripReservation>> confirmPayment(int id) async {
    try {
      Uri url = ApiConfig.buildUri( '/trip-reservations/$id/confirm-payment');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.put(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(TripReservation.fromJson(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<Map<String, dynamic>>> createPaypalOrder(double amount) async {
    try {
      Uri url = ApiConfig.buildUri('/trip-reservations/paypal/create-order');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      String body = json.encode({'amount': amount});
      final response = await http.post(url, headers: headers, body: body);
      
      if (response.body.isEmpty) {
        return ErrorData('El servidor devolvió una respuesta vacía (Código ${response.statusCode})');
      }

      dynamic data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        return ErrorData('Error de respuesta (Código ${response.statusCode}): ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data != null && data['id'] != null) {
          return Success(Map<String, dynamic>.from(data));
        } else {
          return ErrorData('Error al obtener la orden de PayPal desde el servidor');
        }
      } else {
        final errMsg = (data is Map && data['message'] != null)
            ? listToString(data['message'])
            : 'Error del servidor (${response.statusCode})';
        return ErrorData(errMsg);
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }
}
