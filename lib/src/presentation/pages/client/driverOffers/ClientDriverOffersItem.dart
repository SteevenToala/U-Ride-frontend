import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/DriverTripRequest.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/driverOffers/bloc/ClientDriverOffersBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/driverOffers/bloc/ClientDriverOffersEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultImageUrl.dart';

class ClientDriverOffersItem extends StatelessWidget {
  final DriverTripRequest driverTripRequest;

  const ClientDriverOffersItem(this.driverTripRequest, {super.key});

  @override
  Widget build(BuildContext context) {
    final driver = driverTripRequest.driver;
    final car = driverTripRequest.car;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.passengerColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.passengerColor.withValues(alpha: 0.12),
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
                DefaultImageUrl(url: driver?.image, width: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${driver?.name ?? ''} ${driver?.lastname ?? ''}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          const Text('5.0',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                          if (car?.brand != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.directions_car_rounded,
                                color: Colors.white38, size: 14),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(car!.brand,
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${driverTripRequest.fareOffered.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppTheme.passengerColorLight,
                      fontWeight: FontWeight.w900,
                      fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(Icons.access_time_rounded,
                    '${driverTripRequest.time.toStringAsFixed(0)} min'),
                _infoChip(Icons.social_distance_rounded,
                    '${driverTripRequest.distance.toStringAsFixed(1)} km'),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  context.read<ClientDriverOffersBloc>().add(
                        AssignDriver(
                          idClientRequest: driverTripRequest.idClientRequest,
                          idDriver: driverTripRequest.idDriver,
                          fareAssigned: driverTripRequest.fareOffered,
                          context: context,
                        ),
                      );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.passengerGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.passengerColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Aceptar oferta',
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
}
