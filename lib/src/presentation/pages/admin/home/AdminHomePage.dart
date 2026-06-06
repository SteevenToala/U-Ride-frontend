import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:indriver_clone_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/reports/AdminReportsPage.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/reports/bloc/AdminReportsBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/reports/bloc/AdminReportsEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/UserManagementPage.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/home/bloc/ClientHomeBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/home/bloc/ClientHomeEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/ProfileInfoPage.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  static const _titles = ['Usuarios', 'Reportes', 'Mi Perfil'];

  final List<Widget> _pages = const [
    UserManagementPage(),
    AdminReportsPage(),
    ProfileInfoPage(mode: ProfileRoleMode.admin),
  ];

  static const _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Usuarios'),
    BottomNavigationBarItem(icon: Icon(Icons.flag_rounded), label: 'Reportes'),
    BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      context.read<AdminReportsBloc>().add(LoadReports());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDarkCard,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titles[_currentIndex],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const Text('Panel de Administración', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          // Quick access: conductor approvals
          IconButton(
            icon: const Icon(Icons.directions_car_rounded, color: AppTheme.accentColor),
            tooltip: 'Solicitudes de Conductor',
            onPressed: () => Navigator.pushNamed(context, 'admin/driver/approval'),
          ),
          // Logout
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: AppTheme.backgroundDarkCard,
            onSelected: (v) {
              if (v == 'logout') {
                context.read<ClientHomeBloc>().add(Logout());
                context.read<BlocSocketIO>().add(DisconnectSocketIO());
                Navigator.pushNamedAndRemoveUntil(context, 'login', (r) => false);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundDarkCard,
          border: const Border(top: BorderSide(color: AppTheme.borderSubtle)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.accentColor,
          unselectedItemColor: AppTheme.textFaint,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: _navItems,
        ),
      ),
    );
  }
}
