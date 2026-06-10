import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:indriver_clone_flutter/src/domain/models/DriverTripRequest.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/clientRequests/bloc/DriverClientRequestsState.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultImageUrl.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultTextField.dart';

class DriverClientRequestsItem extends StatelessWidget {
  final DriverClientRequestsState state;
  final ClientRequestResponse clientRequest;

  const DriverClientRequestsItem(this.state, this.clientRequest, {super.key});

  @override
  Widget build(BuildContext context) {
    final client = clientRequest.client;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.driverColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.driverColor.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DefaultImageUrl(url: client.image, width: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${client.name} ${client.lastname}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '\$${clientRequest.fareOffered}',
                  style: const TextStyle(
                      color: AppTheme.driverColorLight,
                      fontWeight: FontWeight.w900,
                      fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.radio_button_checked,
                    color: AppTheme.driverColorLight, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(clientRequest.pickupDescription,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.more_vert, color: Colors.white24, size: 14),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: AppTheme.textMuted, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(clientRequest.destinationDescription,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (clientRequest.googleDistanceMatrix != null) ...[
                  _infoChip(Icons.access_time_rounded,
                      clientRequest.googleDistanceMatrix!.duration.text),
                  _infoChip(Icons.social_distance_rounded,
                      clientRequest.googleDistanceMatrix!.distance.text),
                ],
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () => _showFareDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.driverGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.driverColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_offer_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Ofertar viaje',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white38),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  void _showFareDialog(BuildContext context) {
    final bloc = context.read<DriverClientRequestsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.backgroundDarkSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Ingresa tu tarifa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        content: DefaultTextField(
          text: 'Valor',
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          margin: EdgeInsets.zero,
          onChanged: (text) {
            bloc.add(FareOfferedChange(fareOffered: BlocFormItem(value: text)));
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.driverColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              if (bloc.state.idDriver != null && bloc.state.fareOffered.value.isNotEmpty) {
                bloc.add(
                  CreateDriverTripRequest(
                    driverTripRequest: DriverTripRequest(
                      idDriver: bloc.state.idDriver!,
                      idClientRequest: clientRequest.id,
                      fareOffered: double.parse(bloc.state.fareOffered.value),
                      time: clientRequest.googleDistanceMatrix!.duration.value.toDouble() / 60,
                      distance: clientRequest.googleDistanceMatrix!.distance.value.toDouble() / 1000,
                    ),
                  ),
                );
              } else {
                Fluttertoast.showToast(msg: 'No se puede enviar la oferta', toastLength: Toast.LENGTH_LONG);
              }
            },
            child: const Text('Enviar tarifa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
