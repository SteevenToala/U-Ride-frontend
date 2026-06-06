import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/bloc/UserManagementBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/bloc/UserManagementEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class UserManagementItem extends StatelessWidget {
  final User user;

  const UserManagementItem(this.user, {super.key});

  bool get _isDriver => user.isDriverApproved ?? false;
  bool get _isSuspended => false; // backend sends is_suspended in future

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(),
            const SizedBox(width: 14),
            // Info
            Expanded(child: _buildInfo()),
            const SizedBox(width: 8),
            // Actions
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.accentColor.withOpacity(0.12),
          backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
          child: user.image == null
              ? const Icon(Icons.person_rounded, color: AppTheme.accentColor, size: 28)
              : null,
        ),
        if (_isDriver)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.driverColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.backgroundDarkCard, width: 2),
              ),
              child: const Icon(Icons.directions_car_rounded, size: 10, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${user.name} ${user.lastname}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          user.email ?? '',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _badge('Estudiante', AppTheme.accentColor, Icons.school_rounded),
            if (_isDriver) _badge('Conductor', AppTheme.driverColor, Icons.directions_car_rounded),
            if (user.career != null && user.career!.isNotEmpty)
              _badge(user.career!, Colors.blueGrey, Icons.book_outlined),
          ],
        ),
        if (user.referenceZone != null && user.referenceZone!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 11, color: AppTheme.textFaint),
              const SizedBox(width: 3),
              Flexible(child: Text(user.referenceZone!, style: const TextStyle(color: AppTheme.textFaint, fontSize: 11), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _iconBtn(
          icon: Icons.info_outline_rounded,
          color: AppTheme.accentColor,
          tooltip: 'Ver detalles',
          onTap: () => _showDetailsDialog(context),
        ),
        const SizedBox(height: 6),
        _iconBtn(
          icon: Icons.block_rounded,
          color: Colors.redAccent,
          tooltip: 'Suspender usuario',
          onTap: () => _showSuspendDialog(context),
        ),
      ],
    );
  }

  Widget _iconBtn({required IconData icon, required Color color, required String tooltip, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showSuspendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Confirmar Suspensión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.redAccent.withOpacity(0.12),
              backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
              child: user.image == null ? const Icon(Icons.person, color: Colors.redAccent, size: 30) : null,
            ),
            const SizedBox(height: 12),
            Text(
              '¿Suspender a ${user.name} ${user.lastname}?',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 6),
            const Text(
              'El usuario perderá acceso a la plataforma.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.block_rounded, size: 16),
            label: const Text('Suspender'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              context.read<UserManagementBloc>().add(SuspendUser(user.id!));
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundDarkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.accentColor.withOpacity(0.12),
              backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
              child: user.image == null ? const Icon(Icons.person, color: AppTheme.accentColor, size: 22) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${user.name} ${user.lastname}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  if (user.email != null)
                    Text(user.email!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        content: _detailContent(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar', style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  Widget _detailContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _detailRow(Icons.phone_rounded, 'Teléfono', user.phone ?? 'No registrado'),
        _detailRow(Icons.school_rounded, 'Carrera', user.career ?? 'No registrado'),
        _detailRow(Icons.location_on_rounded, 'Zona', user.referenceZone ?? 'No registrado'),
        _detailRow(
          Icons.directions_car_rounded,
          'Rol conductor',
          _isDriver ? '✓ Aprobado' : 'No es conductor',
          valueColor: _isDriver ? AppTheme.driverColor : AppTheme.textMuted,
        ),
        if (user.roles != null && user.roles!.isNotEmpty)
          _detailRow(Icons.badge_rounded, 'Roles', user.roles!.map((r) => r.id).join(', ')),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textFaint),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: valueColor ?? Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
