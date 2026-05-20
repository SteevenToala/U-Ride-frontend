import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:indriver_clone_flutter/src/domain/models/PlacemarkData.dart';
import 'package:indriver_clone_flutter/injection.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/geolocator/GeolocatorUseCases.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/publishTrip/bloc/TripMapPickerBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/publishTrip/bloc/TripMapPickerEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/publishTrip/bloc/TripMapPickerState.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultButton.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/GooglePlacesAutoComplete.dart';

class TripMapPickerPage extends StatefulWidget {
  final String title;
  const TripMapPickerPage({super.key, required this.title});

  @override
  State<TripMapPickerPage> createState() => _TripMapPickerPageState();
}

class _TripMapPickerPageState extends State<TripMapPickerPage> {
  final TextEditingController originController = TextEditingController();
  final TextEditingController destController = TextEditingController();

  @override
  void dispose() {
    originController.dispose();
    destController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripMapPickerBloc(geolocatorUseCases: locator<GeolocatorUseCases>())
        ..add(TripMapPickerInitEvent())
        ..add(FindCurrentPosition()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A2E44),
          title: Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<TripMapPickerBloc, TripMapPickerState>(
          builder: (context, state) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: _buildGoogleMap(context, state),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      _buildInfoBanner(state),
                    ],
                  ),
                ),
                if (!state.hasLocation) // Show center pin only if we are still selecting
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40), // Offset to point to exact center
                      child: Image.asset(
                        state.selectingOrigin ? 'assets/img/location_blue.png' : 'assets/img/car_pin.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildActionButtons(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context, TripMapPickerState state) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: state.cameraPosition,
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: state.markers,
      polylines: state.polylines,
      onCameraMove: (CameraPosition cameraPosition) {
        context.read<TripMapPickerBloc>().add(OnCameraMove(cameraPosition: cameraPosition));
      },
      onCameraIdle: () {
        context.read<TripMapPickerBloc>().add(OnCameraIdle());
      },
      onMapCreated: (GoogleMapController controller) {
        controller.setMapStyle('[ { "featureType": "all", "elementType": "labels.text.fill", "stylers": [ { "color": "#ffffff" } ] }, { "featureType": "all", "elementType": "labels.text.stroke", "stylers": [ { "color": "#000000" }, { "lightness": 13 } ] }, { "featureType": "administrative", "elementType": "geometry.fill", "stylers": [ { "color": "#000000" } ] }, { "featureType": "administrative", "elementType": "geometry.stroke", "stylers": [ { "color": "#144b53" }, { "lightness": 14 }, { "weight": 1.4 } ] }, { "featureType": "landscape", "elementType": "all", "stylers": [ { "color": "#08304b" } ] }, { "featureType": "poi", "elementType": "geometry", "stylers": [ { "color": "#0c4152" }, { "lightness": 5 } ] }, { "featureType": "road.highway", "elementType": "geometry.fill", "stylers": [ { "color": "#000000" } ] }, { "featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [ { "color": "#0b434f" }, { "lightness": 25 } ] }, { "featureType": "road.arterial", "elementType": "geometry.fill", "stylers": [ { "color": "#000000" } ] }, { "featureType": "road.arterial", "elementType": "geometry.stroke", "stylers": [ { "color": "#0b3d51" }, { "lightness": 16 } ] }, { "featureType": "road.local", "elementType": "geometry", "stylers": [ { "color": "#000000" } ] }, { "featureType": "transit", "elementType": "all", "stylers": [ { "color": "#146474" } ] }, { "featureType": "water", "elementType": "all", "stylers": [ { "color": "#021019" } ] } ]');
        if (state.controller != null && !state.controller!.isCompleted) {
          state.controller!.complete(controller);
        }
      },
    );
  }

  Widget _buildInfoBanner(TripMapPickerState state) {
    String message = '';
    Color color = const Color(0xFF00C896);

    if (state.hasLocation) {
      message = 'Ruta trazada con éxito. Verifica y confirma.';
      color = const Color(0xFF1E3A5F);
    } else if (state.selectingOrigin) {
      message = 'Mueve el mapa para seleccionar tu ORIGEN';
      color = Colors.blueAccent;
    } else {
      message = 'Mueve el mapa para seleccionar tu DESTINO';
      color = Colors.redAccent;
    }

    return Container(
      width: double.infinity,
      color: color.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TripMapPickerState state) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!state.hasLocation)
            DefaultButton(
              text: state.isLoadingAddress ? 'Cargando...' : (state.selectingOrigin ? 'ESTABLECER ORIGEN AQUÍ' : 'ESTABLECER DESTINO AQUÍ'),
              iconData: Icons.location_on,
              color: state.selectingOrigin ? Colors.blueAccent : Colors.redAccent,
              onPressed: () {
                if (!state.isLoadingAddress) {
                  context.read<TripMapPickerBloc>().add(OnCenterPinSelected());
                }
              },
            ),
          if (state.hasLocation) ...[
            DefaultButton(
              text: 'CONFIRMAR RUTA',
              iconData: Icons.check_circle,
              color: const Color(0xFF00C896),
              onPressed: () {
                if (!state.isLoadingAddress) {
                  Navigator.pop(context, {
                    'origin': state.origin,
                    'destination': state.destination,
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            DefaultButton(
              text: 'REINICIAR SELECCIÓN',
              iconData: Icons.refresh,
              color: Colors.grey,
              onPressed: () {
                context.read<TripMapPickerBloc>().add(ResetSelection());
              },
            ),
          ],
        ],
      ),
    );
  }
}
