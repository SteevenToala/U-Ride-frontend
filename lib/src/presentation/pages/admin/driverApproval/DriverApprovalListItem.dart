import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class DriverApprovalListItem extends StatelessWidget {
  final User user;
  final VoidCallback onApprove;

  const DriverApprovalListItem(this.user, this.onApprove, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.driverColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: AppTheme.driverColor.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar with driver badge overlay
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.driverColor.withOpacity(0.12),
                  backgroundImage: (user.image != null && user.image!.isNotEmpty)
                      ? NetworkImage(user.image!)
                      : null,
                  child: (user.image == null || user.image!.isEmpty)
                      ? const Icon(Icons.person_rounded, color: AppTheme.driverColor, size: 30)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.statusScheduledColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.backgroundDarkCard, width: 2),
                    ),
                    child: const Icon(Icons.hourglass_top_rounded, size: 11, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.name} ${user.lastname}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (user.career != null && user.career!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.school_rounded, size: 11, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(user.career!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      ],
                    ),
                  if (user.referenceZone != null && user.referenceZone!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 11, color: AppTheme.textFaint),
                        const SizedBox(width: 4),
                        Text(user.referenceZone!, style: const TextStyle(color: AppTheme.textFaint, fontSize: 11)),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.statusScheduledColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.statusScheduledColor.withOpacity(0.35)),
                    ),
                    child: const Text(
                      'Solicitud pendiente de aprobación',
                      style: TextStyle(color: AppTheme.statusScheduledColor, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Approve button
            GestureDetector(
              onTap: onApprove,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppTheme.driverGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: AppTheme.driverColor.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 20),
                    SizedBox(height: 2),
                    Text('Aprobar', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
