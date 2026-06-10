import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indriver_clone_flutter/src/data/api/ApiConfig.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/utils/ListToString.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class SharedTripsService {

  Future<Resource<SharedTrip>> create(SharedTrip trip) async {
    try {
      Uri url = ApiConfig.buildUri( '/shared-trips');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      String body = json.encode(trip.toJson());
      final response = await http.post(url, headers: headers, body: body);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(SharedTrip.fromJson(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<SharedTrip>> update(int id, SharedTrip trip) async {
    try {
      Uri url = ApiConfig.buildUri( '/shared-trips/$id');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      String body = json.encode(trip.toJson());
      final response = await http.put(url, headers: headers, body: body);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(SharedTrip.fromJson(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<bool>> delete(int id) async {
    try {
      Uri url = ApiConfig.buildUri( '/shared-trips/$id');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return Success(true);
      } else {
        final data = json.decode(response.body);
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<List<SharedTrip>>> getAll({
    String? originZone,
    String? destinationZone,
    String? date,
  }) async {
    try {
      Map<String, String> queryParams = {};
      if (originZone != null && originZone.isNotEmpty) queryParams['origin_zone'] = originZone;
      if (destinationZone != null && destinationZone.isNotEmpty) queryParams['destination_zone'] = destinationZone;
      if (date != null && date.isNotEmpty) queryParams['date'] = date;

      Uri url = ApiConfig.buildUri( '/shared-trips', queryParams);
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<SharedTrip> trips = SharedTrip.fromJsonList(data);
        return Success(trips);
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<SharedTrip>> getById(int id) async {
    try {
      Uri url = ApiConfig.buildUri( '/shared-trips/$id');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(SharedTrip.fromJson(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<List<SharedTrip>>> getByDriver(int idDriver) async {
    try {
      Uri url = ApiConfig.buildUri( '/shared-trips/driver/$idDriver');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(SharedTrip.fromJsonList(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<List<SharedTrip>>> getByPassenger(int idPassenger) async {
    try {
      Uri url = ApiConfig.buildUri( '/shared-trips/passenger/$idPassenger');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(SharedTrip.fromJsonList(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<SharedTrip>> startTrip(int id) async {
    try {
      Uri url = ApiConfig.buildUri( '/shared-trips/$id/start');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.put(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(SharedTrip.fromJson(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<SharedTrip>> cancelTrip(int id) async {
    try {
      Uri url = ApiConfig.buildUri( '/shared-trips/$id/cancel');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.put(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(SharedTrip.fromJson(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<SharedTrip>> finishTrip(int id) async {
    try {
      Uri url = ApiConfig.buildUri( '/shared-trips/$id/finish');
      Map<String, String> headers = {'Content-Type': 'application/json'};
      final response = await http.put(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(SharedTrip.fromJson(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }
}
