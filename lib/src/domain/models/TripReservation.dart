import 'dart:convert';
import 'package:indriver_clone_flutter/src/domain/models/ReservationStatus.dart';
import 'package:indriver_clone_flutter/src/domain/models/SharedTrip.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';

TripReservation tripReservationFromJson(String str) => TripReservation.fromJson(json.decode(str));
String tripReservationToJson(TripReservation data) => json.encode(data.toJson());

class TripReservation {
  int? id;
  int idTrip;
  int idPassenger;
  int seatsRequested;
  ReservationStatus status;
  String? message;
  String? meetingPoint;
  String paymentMethod;
  String paymentStatus;
  String? paypalOrderId;
  DateTime? createdAt;
  DateTime? updatedAt;
  SharedTrip? trip;
  User? passenger;

  TripReservation({
    this.id,
    required this.idTrip,
    required this.idPassenger,
    this.seatsRequested = 1,
    this.status = ReservationStatus.PENDING,
    this.message,
    this.meetingPoint,
    this.paymentMethod = 'EFECTIVO',
    this.paymentStatus = 'PENDIENTE',
    this.paypalOrderId,
    this.createdAt,
    this.updatedAt,
    this.trip,
    this.passenger,
  });

  static List<TripReservation> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => TripReservation.fromJson(json)).toList();
  }

  factory TripReservation.fromJson(Map<String, dynamic> json) => TripReservation(
        id: json['id'],
        idTrip: json['id_trip'],
        idPassenger: json['id_passenger'],
        seatsRequested: json['seats_requested'] ?? 1,
        status: _parseStatus(json['status']),
        message: json['message'],
        meetingPoint: json['meeting_point'],
        paymentMethod: json['payment_method'] ?? 'EFECTIVO',
        paymentStatus: json['payment_status'] ?? 'PENDIENTE',
        paypalOrderId: json['paypal_order_id'],
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
        updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
        trip: json['trip'] != null ? SharedTrip.fromJson(json['trip']) : null,
        passenger: json['passenger'] != null ? User.fromJson(json['passenger']) : null,
      );

  static ReservationStatus _parseStatus(String? status) {
    switch (status) {
      case 'ACCEPTED':
        return ReservationStatus.ACCEPTED;
      case 'REJECTED':
        return ReservationStatus.REJECTED;
      case 'CANCELLED':
        return ReservationStatus.CANCELLED;
      default:
        return ReservationStatus.PENDING;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_trip': idTrip,
        'id_passenger': idPassenger,
        'seats_requested': seatsRequested,
        'status': status.name,
        'meeting_point': meetingPoint,
        'message': message,
        'payment_method': paymentMethod,
        if (paypalOrderId != null) 'paypal_order_id': paypalOrderId,
      };

  bool get isPending => status == ReservationStatus.PENDING;
  bool get isAccepted => status == ReservationStatus.ACCEPTED;
  bool get isRejected => status == ReservationStatus.REJECTED;
  bool get isCancelled => status == ReservationStatus.CANCELLED;
  bool get isPaidWithPaypal => paymentMethod == 'PAYPAL' && paymentStatus == 'PAGADO';
}
