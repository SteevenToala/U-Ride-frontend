import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_clone_flutter/src/domain/models/PlacemarkData.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/geolocator/GeolocatorUseCases.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/publishTrip/bloc/TripMapPickerEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/publishTrip/bloc/TripMapPickerState.dart';

class TripMapPickerBloc extends Bloc<TripMapPickerEvent, TripMapPickerState> {
  final GeolocatorUseCases geolocatorUseCases;

  TripMapPickerBloc({required this.geolocatorUseCases}) : super(const TripMapPickerState()) {
    on<TripMapPickerInitEvent>((event, emit) {
      Completer<GoogleMapController> controller = Completer<GoogleMapController>();
      emit(state.copyWith(controller: controller));
    });

    on<InitMap>((event, emit) {
      add(FindCurrentPosition());
    });

    on<InitWithData>((event, emit) async {
      final origin = event.origin as PlacemarkData;
      final destination = event.destination as PlacemarkData;
      emit(state.copyWith(
        origin: origin,
        destination: destination,
        selectingOrigin: false,
      ));
      await _traceRoute(emit, origin, destination);
    });

    on<FindCurrentPosition>((event, emit) async {
      try {
        Position position = await geolocatorUseCases.findPosition.run();
        add(ChangeMapCameraPosition(lat: position.latitude, lng: position.longitude));
      } catch (e) {
        print('Error finding position: $e');
      }
    });

    on<ChangeMapCameraPosition>((event, emit) async {
      try {
        if (state.controller != null && state.controller!.isCompleted) {
          GoogleMapController googleMapController = await state.controller!.future;
          await Future.delayed(const Duration(milliseconds: 200));
          await googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(event.lat, event.lng), zoom: 15, bearing: 0),
          ));
        }
      } catch (e) {
        print('Error changing camera position: $e');
      }
    });

    on<OnCameraMove>((event, emit) {
      emit(state.copyWith(cameraPosition: event.cameraPosition));
    });

    on<OnCameraIdle>((event, emit) async {});

    on<OnOriginSelected>((event, emit) async {
      final origin = PlacemarkData(address: event.description, lat: event.lat, lng: event.lng);
      emit(state.copyWith(origin: origin));
      add(ChangeMapCameraPosition(lat: event.lat, lng: event.lng));
      await _traceRoute(emit, origin, state.destination);
    });

    on<OnDestinationSelected>((event, emit) async {
      final destination = PlacemarkData(address: event.description, lat: event.lat, lng: event.lng);
      emit(state.copyWith(destination: destination, selectingOrigin: false));
      add(ChangeMapCameraPosition(lat: event.lat, lng: event.lng));
      await _traceRoute(emit, state.origin, destination);
    });

    on<ResetSelection>((event, emit) {
      emit(state.copyWith(
        origin: null,
        destination: null,
        selectingOrigin: true,
        markers: {},
        polylines: {},
      ));
    });

    on<OnCenterPinSelected>((event, emit) async {
      emit(state.copyWith(isLoadingAddress: true));
      PlacemarkData? newPlacemark;
      try {
        newPlacemark = await geolocatorUseCases.getPlacemarkData.run(state.cameraPosition);
      } catch (e) {
        print('Geocoding failed, using generic text: $e');
      }
      
      newPlacemark ??= PlacemarkData(
        address: state.selectingOrigin ? 'Origen Seleccionado' : 'Destino Seleccionado',
        lat: state.cameraPosition.target.latitude,
        lng: state.cameraPosition.target.longitude,
      );

      if (state.selectingOrigin) {
        emit(state.copyWith(
          origin: newPlacemark,
          selectingOrigin: false,
          isLoadingAddress: false,
        ));
        await _traceRoute(emit, newPlacemark, state.destination);
      } else {
        emit(state.copyWith(
          destination: newPlacemark,
          isLoadingAddress: false,
        ));
        await _traceRoute(emit, state.origin, newPlacemark);
      }
    });

    on<OnMapTapped>((event, emit) async {
      emit(state.copyWith(isLoadingAddress: true));
      PlacemarkData? newPlacemark;
      try {
        // We try to reverse geocode, but if it fails (e.g. Web), we use a generic name
        final pos = CameraPosition(target: event.position, zoom: 15);
        newPlacemark = await geolocatorUseCases.getPlacemarkData.run(pos);
      } catch (e) {
        print('Geocoding failed, using generic text: $e');
      }
      
      newPlacemark ??= PlacemarkData(
        address: 'Ubicación seleccionada en el mapa',
        lat: event.position.latitude,
        lng: event.position.longitude,
      );

      if (state.origin == null || (state.origin != null && state.destination != null)) {
        // Set origin and clear destination
        emit(state.copyWith(origin: newPlacemark, destination: null, selectingOrigin: false, polylines: {}, isLoadingAddress: false));
        await _traceRoute(emit, newPlacemark, null);
      } else {
        // Set destination
        emit(state.copyWith(destination: newPlacemark, isLoadingAddress: false));
        await _traceRoute(emit, state.origin, newPlacemark);
      }
    });
  }

  Future<void> _traceRoute(Emitter<TripMapPickerState> emit, PlacemarkData? origin, PlacemarkData? destination) async {
    final Set<Marker> markers = {};
    final Set<Polyline> polylines = {};

    try {
      if (origin != null) {
        BitmapDescriptor originIcon;
        try {
          originIcon = await geolocatorUseCases.createMarker.run('assets/img/location_blue.png');
        } catch (_) {
          originIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
        }
        markers.add(geolocatorUseCases.getMarker.run('origin', origin.lat, origin.lng, 'Origen', origin.address, originIcon));
      }
      if (destination != null) {
        BitmapDescriptor destIcon;
        try {
          destIcon = await geolocatorUseCases.createMarker.run('assets/img/car_pin.png');
        } catch (_) {
          destIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        }
        markers.add(geolocatorUseCases.getMarker.run('dest', destination.lat, destination.lng, 'Destino', destination.address, destIcon));
      }

      if (origin != null && destination != null) {
        emit(state.copyWith(isLoadingAddress: true));
        final originLatLng = LatLng(origin.lat, origin.lng);
        final destLatLng = LatLng(destination.lat, destination.lng);
        final polylinePoints = await geolocatorUseCases.getPolyline.run(originLatLng, destLatLng);
        polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          color: const Color(0xFF00C896),
          points: polylinePoints,
          width: 5,
        ));
        emit(state.copyWith(isLoadingAddress: false, markers: markers, polylines: polylines));
        
        try {
          if (state.controller != null) {
            GoogleMapController controller = await state.controller!.future;
            await Future.delayed(const Duration(milliseconds: 200)); // Delay for web view
            await controller.animateCamera(CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  origin.lat < destination.lat ? origin.lat : destination.lat,
                  origin.lng < destination.lng ? origin.lng : destination.lng,
                ),
                northeast: LatLng(
                  origin.lat > destination.lat ? origin.lat : destination.lat,
                  origin.lng > destination.lng ? origin.lng : destination.lng,
                ),
              ),
              50.0,
            ));
          }
        } catch (e) {
          print('Error animating to bounds: $e');
        }
      } else {
        emit(state.copyWith(markers: markers, polylines: polylines));
      }
    } catch (e) {
      print('Error trace route: $e');
      emit(state.copyWith(isLoadingAddress: false, markers: markers, polylines: polylines));
    }
  }
}
