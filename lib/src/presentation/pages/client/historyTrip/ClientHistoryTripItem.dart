import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/src/domain/models/ClientRequestResponse.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';
import 'package:indriver_clone_flutter/src/presentation/widgets/DefaultImageUrl.dart';

class ClientHistoryTripItem extends StatelessWidget {
  final ClientRequestResponse clientRequest;

  const ClientHistoryTripItem(this.clientRequest, {super.key});

  @override
  Widget build(BuildContext context) {
    final driver = clientRequest.driver;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.passengerColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.passengerColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.passengerColor.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.passengerColorLight, size: 14),
                const SizedBox(width: 6),
                const Text('Viaje finalizado',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(
                  _formatDateTime(clientRequest.updatedAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (driver != null)
                  Row(
                    children: [
                      DefaultImageUrl(url: driver.image, width: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Conductor',
                                style: TextStyle(color: Colors.white38, fontSize: 11)),
                            Text('${driver.name} ${driver.lastname}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (driver != null) const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.radio_button_checked,
                        color: AppTheme.passengerColorLight, size: 14),
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
                    if (clientRequest.fareAssigned != null)
                      _infoChip(Icons.attach_money_rounded,
                          '\$${clientRequest.fareAssigned!.toStringAsFixed(2)}'),
                    if (clientRequest.createdAt != null)
                      _infoChip(Icons.watch_later_outlined,
                          'Inicio: ${_formatDateTime(clientRequest.createdAt!)}'),
                  ],
                ),
              ],
            ),
          ),
        ],
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

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
