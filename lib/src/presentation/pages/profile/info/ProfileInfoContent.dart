import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/ProfileInfoPage.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

// ── Color palette for each role mode ────────────────────────────────────────

class _ModeStyle {
  final Color accent;
  final Color accentLight;
  final LinearGradient gradient;
  final LinearGradient headerGradient;
  final IconData icon;
  final String modeLabel;
  final String modeSubtitle;

  const _ModeStyle({
    required this.accent,
    required this.accentLight,
    required this.gradient,
    required this.headerGradient,
    required this.icon,
    required this.modeLabel,
    required this.modeSubtitle,
  });
}

_ModeStyle _styleFor(ProfileRoleMode mode) {
  switch (mode) {
    case ProfileRoleMode.driver:
      return const _ModeStyle(
        accent: AppTheme.driverColor,
        accentLight: AppTheme.driverColorLight,
        gradient: AppTheme.driverGradient,
        headerGradient: AppTheme.driverGradient,
        icon: Icons.directions_car_rounded,
        modeLabel: 'MODO CONDUCTOR',
        modeSubtitle: 'Perfil de conductor U-Ride',
      );
    case ProfileRoleMode.admin:
      return const _ModeStyle(
        accent: AppTheme.accentColor,
        accentLight: AppTheme.accentColor,
        gradient: AppTheme.accentGradient,
        headerGradient: AppTheme.accentGradient,
        icon: Icons.admin_panel_settings_rounded,
        modeLabel: 'ADMINISTRADOR',
        modeSubtitle: 'Panel de administración U-Ride',
      );
    case ProfileRoleMode.passenger:
    default:
      return const _ModeStyle(
        accent: AppTheme.passengerColor,
        accentLight: AppTheme.passengerColorLight,
        gradient: AppTheme.passengerGradient,
        headerGradient: AppTheme.passengerGradient,
        icon: Icons.person_rounded,
        modeLabel: 'MODO PASAJERO',
        modeSubtitle: 'Perfil de pasajero U-Ride',
      );
  }
}

// ── Widget ───────────────────────────────────────────────────────────────────

class ProfileInfoContent extends StatelessWidget {
  final User? user;
  final ProfileRoleMode mode;

  const ProfileInfoContent(this.user, this.mode, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = _styleFor(mode);
    final hasDriverRole = user?.roles?.any((r) => r.id == 'DRIVER') ?? false;
    final isAdmin = user?.roles?.any((r) => r.id == 'ADMIN') ?? false;
    final isDriverApproved = user?.isDriverApproved ?? false;
    final reputation = double.tryParse(user?.roles?.isNotEmpty == true ? '0' : '0') ?? 0.0;

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context, s),
            _buildCard(context, s),
            const SizedBox(height: 20),
            if (!hasDriverRole && !isAdmin)
              _actionButton(
                context,
                label: 'QUIERO SER CONDUCTOR',
                icon: Icons.drive_eta_rounded,
                accent: s.accent,
                gradient: s.gradient,
                filled: true,
                onTap: () {
                  if (user?.id != null) {
                    context.read<ProfileInfoBloc>().add(RequestDriverRole(id: user!.id!));
                  }
                },
              ),
            if (hasDriverRole && !isDriverApproved)
              _pendingBadge(s.accent),
            _actionButton(
              context,
              label: 'EDITAR PERFIL',
              icon: Icons.edit_rounded,
              accent: s.accent,
              gradient: s.gradient,
              filled: false,
              onTap: () => Navigator.pushNamed(
                context,
                'profile/update',
                arguments: {'user': user, 'mode': mode},
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Hero header ─────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context, _ModeStyle s) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient banner
        Container(
          height: 180,
          decoration: BoxDecoration(gradient: s.headerGradient),
          child: Align(
            alignment: Alignment.topRight,
            child: Opacity(
              opacity: 0.08,
              child: Icon(s.icon, size: 160, color: Colors.white),
            ),
          ),
        ),
        // Mode label
        Positioned(
          top: 52,
          left: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s.icon, size: 12, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(s.modeLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('MI PERFIL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: 3)),
              const SizedBox(height: 3),
              Text(s.modeSubtitle, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
            ],
          ),
        ),
        // Avatar — overlapping the banner
        Positioned(
          bottom: -50,
          right: 28,
          child: _avatarWithBorder(s),
        ),
        const SizedBox(height: 180),
      ],
    );
  }

  Widget _avatarWithBorder(_ModeStyle s) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: s.accent, width: 3),
        boxShadow: [BoxShadow(color: s.accent.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4))],
        color: AppTheme.backgroundDark,
      ),
      child: ClipOval(
        child: user?.image != null && user!.image!.isNotEmpty
            ? FadeInImage.assetNetwork(
                placeholder: 'assets/img/user_image.png',
                image: user!.image!,
                fit: BoxFit.cover,
              )
            : Icon(Icons.person, size: 52, color: s.accent.withOpacity(0.6)),
      ),
    );
  }

  // ── Info card ────────────────────────────────────────────────────────────

  Widget _buildCard(BuildContext context, _ModeStyle s) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 70, 20, 0),
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: s.accent.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: s.accent.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          // Name & reputation
          const SizedBox(height: 4),
          Text(
            '${user?.name ?? ''} ${user?.lastname ?? ''}'.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          // Role badges row
          _buildRoleBadges(s),
          const SizedBox(height: 18),
          Divider(color: s.accent.withOpacity(0.2)),
          const SizedBox(height: 12),
          // Info rows
          _infoRow(Icons.alternate_email_rounded, 'Correo', user?.email ?? '—', s),
          _infoRow(Icons.phone_android_rounded, 'Teléfono', user?.phone ?? 'Sin teléfono', s),
          if (user?.career != null && user!.career!.isNotEmpty)
            _infoRow(Icons.school_rounded, 'Carrera', user!.career!, s),
          if (user?.referenceZone != null && user!.referenceZone!.isNotEmpty)
            _infoRow(Icons.location_on_rounded, 'Zona', user!.referenceZone!, s),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, _ModeStyle s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: s.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: s.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textFaint, fontSize: 10, fontWeight: FontWeight.w600)),
                Text(value, style: const TextStyle(color: Colors.white70, fontSize: 14), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadges(_ModeStyle s) {
    final roles = user?.roles ?? [];
    if (roles.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: roles.map((rol) {
        Color badgeColor;
        String label;
        IconData icon;
        switch (rol.id) {
          case 'DRIVER':
            badgeColor = AppTheme.driverColor;
            label = 'CONDUCTOR';
            icon = Icons.directions_car_rounded;
            break;
          case 'ADMIN':
            badgeColor = AppTheme.accentColor;
            label = 'ADMIN';
            icon = Icons.admin_panel_settings_rounded;
            break;
          default:
            badgeColor = AppTheme.passengerColor;
            label = 'ESTUDIANTE';
            icon = Icons.school_rounded;
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: badgeColor.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: badgeColor),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Buttons & badges ─────────────────────────────────────────────────────

  Widget _actionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color accent,
    required LinearGradient gradient,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: filled ? gradient : null,
              color: filled ? null : AppTheme.backgroundDarkCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: filled ? Colors.transparent : accent.withOpacity(0.4),
              ),
              boxShadow: filled
                  ? [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Row(
                children: [
                  Icon(icon, color: filled ? Colors.white : accent, size: 22),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: filled ? Colors.white : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: filled ? Colors.white54 : Colors.white24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pendingBadge(Color accent) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.hourglass_top_rounded, size: 16, color: Colors.orange),
          SizedBox(width: 10),
          Text(
            'SOLICITUD DE CONDUCTOR EN REVISIÓN',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }
}
