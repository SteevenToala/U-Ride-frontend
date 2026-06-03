import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:indriver_clone_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:indriver_clone_flutter/main.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/home/bloc/ClientHomeBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/home/bloc/ClientHomeEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/home/bloc/ClientHomeState.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/myReservations/ClientMyReservationsPage.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/searchTrips/ClientSearchTripsPage.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/ProfileInfoPage.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/roles/RolesPage.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final List<Widget> _pageList = [
    ClientSearchTripsPage(),
    ClientMyReservationsPage(),
    ProfileInfoPage(),
    const RolesPage(),
  ];

  static const _accent = AppTheme.passengerColor;
  static const _accentLight = AppTheme.passengerColorLight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'PASAJERO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'U-RIDE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.passengerGradient),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<ClientHomeBloc, ClientHomeState>(
        builder: (context, state) => _pageList[state.pageIndex],
      ),
      drawer: BlocBuilder<ClientHomeBloc, ClientHomeState>(
        builder: (context, state) {
          return Drawer(
            backgroundColor: AppTheme.backgroundDarkSecondary,
            child: Column(
              children: [
                _drawerHeader(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 8),
                      _drawerItem(
                        context,
                        icon: Icons.search_rounded,
                        label: 'Buscar Viajes',
                        index: 0,
                        currentIndex: state.pageIndex,
                      ),
                      _drawerItem(
                        context,
                        icon: Icons.bookmark_rounded,
                        label: 'Mis Reservas',
                        index: 1,
                        currentIndex: state.pageIndex,
                      ),
                      _drawerItem(
                        context,
                        icon: Icons.person_rounded,
                        label: 'Mi Perfil',
                        index: 2,
                        currentIndex: state.pageIndex,
                      ),
                      _drawerItem(
                        context,
                        icon: Icons.swap_horiz_rounded,
                        label: 'Cambiar Rol',
                        index: 3,
                        currentIndex: state.pageIndex,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Divider(color: AppTheme.dividerColor),
                      ),
                      _drawerLogout(context),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _drawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accent, _accentLight.withValues(alpha: 0.7)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'MODO PASAJERO',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Encuentra tu próximo viaje',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
  }) {
    final bool selected = index == currentIndex;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? _accent.withValues(alpha: 0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(color: _accent.withValues(alpha: 0.35), width: 1)
            : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: selected ? _accentLight : Colors.white54,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected ? Colors.white : Colors.white70,
            fontSize: 14,
          ),
        ),
        trailing: selected
            ? Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _accentLight,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          context.read<ClientHomeBloc>().add(ChangeDrawerPage(pageIndex: index));
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _drawerLogout(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        onTap: () {
          context.read<ClientHomeBloc>().add(Logout());
          context.read<BlocSocketIO>().add(DisconnectSocketIO());
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        },
      ),
    );
  }
}
