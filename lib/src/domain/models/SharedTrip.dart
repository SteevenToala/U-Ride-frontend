import 'dart:convert';
import 'package:indriver_clone_flutter/src/domain/models/TripStatus.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';

SharedTrip sharedTripFromJson(String str) => SharedTrip.fromJson(json.decode(str));
String sharedTripToJson(SharedTrip data) => json.encode(data.toJson());

class SharedTrip {
  int? id;
  int idDriver;
  String originZone;
  String destinationZone;
  double? originLat;
  double? originLng;
  double? destinationLat;
  double? destinationLng;
  DateTime departureTime;
  int availableSeats;
  int totalSeats;
  double farePerSeat;
  String? notes;
  TripStatus status;
  DateTime? createdAt;
  DateTime? updatedAt;
  User? driver;
  int? reservationsCount;

  SharedTrip({
    this.id,
    required this.idDriver,
    required this.originZone,
    required this.destinationZone,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
    required this.departureTime,
    required this.availableSeats,
    required this.totalSeats,
    required this.farePerSeat,
    this.notes,
    this.status = TripStatus.SCHEDULED,
    this.createdAt,
    this.updatedAt,
    this.driver,
    this.reservationsCount,
  });

  static List<SharedTrip> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SharedTrip.fromJson(json)).toList();
  }

  factory SharedTrip.fromJson(Map<String, dynamic> json) => SharedTrip(
        id: json['id'],
        idDriver: json['id_driver'],
        originZone: json['origin_zone'] ?? '',
        destinationZone: json['destination_zone'] ?? '',
        originLat: _parseDouble(json['origin_lat']),
        originLng: _parseDouble(json['origin_lng']),
        destinationLat: _parseDouble(json['destination_lat']),
        destinationLng: _parseDouble(json['destination_lng']),
        departureTime: DateTime.parse(json['departure_time']),
        availableSeats: json['available_seats'] ?? 0,
        totalSeats: json['total_seats'] ?? 1,
        farePerSeat: json['fare_per_seat'] != null
            ? (json['fare_per_seat'] is String
                ? double.parse(json['fare_per_seat'])
                : json['fare_per_seat'].toDouble())
            : 0.0,
        notes: json['notes'],
        status: _parseStatus(json['status']),
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
        updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
        driver: json['driver'] != null ? User.fromJson(json['driver']) : null,
        reservationsCount: json['reservations_count'],
      );

  static TripStatus _parseStatus(String? status) {
    switch (status) {
      case 'ACTIVE':
        return TripStatus.ACTIVE;
      case 'FINISHED':
        return TripStatus.FINISHED;
      case 'CANCELLED':
        return TripStatus.CANCELLED;
      default:
        return TripStatus.SCHEDULED;
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id_driver': idDriver,
      'origin_zone': originZone,
      'destination_zone': destinationZone,
      'origin_lat': originLat,
      'origin_lng': originLng,
      'destination_lat': destinationLat,
      'destination_lng': destinationLng,
      'departure_time': departureTime.toIso8601String(),
      'available_seats': availableSeats,
      'total_seats': totalSeats,
      'fare_per_seat': farePerSeat,
      'notes': notes,
      'status': status.name,
    };
    // Solo incluir 'id' si existe (evita enviar id: null al backend
    // lo cual causa que TypeORM haga INSERT en lugar de UPDATE)
    if (id != null) map['id'] = id;
    return map;
  }

  bool get isScheduled => status == TripStatus.SCHEDULED;
  bool get isActive => status == TripStatus.ACTIVE;
  bool get isFinished => status == TripStatus.FINISHED;
  bool get isCancelled => status == TripStatus.CANCELLED;
  bool get hasAvailableSeats => availableSeats > 0;
}
