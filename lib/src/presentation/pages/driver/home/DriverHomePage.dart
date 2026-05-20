import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:indriver_clone_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:indriver_clone_flutter/main.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/home/bloc/DriverHomeBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/home/bloc/DriverHomeState.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/home/bloc/DriverHomeEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/driver/myTrips/DriverMyTripsPage.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/ProfileInfoPage.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/roles/RolesPage.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  List<Widget> pageList = <Widget>[
    DriverMyTripsPage(),
    ProfileInfoPage(),
    RolesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          'Menu de opciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<DriverHomeBloc, DriverHomeState>(
        builder: (context, state) {
          return pageList[state.pageIndex];
        },
      ),
      drawer: BlocBuilder<DriverHomeBloc, DriverHomeState>(
        builder: (context, state) {
          return Drawer(
            backgroundColor: const Color(0xFF1A2E44),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0D1B2A),
                        Color(0xFF1B263B),
                        Color(0xFF415A77),
                      ]
                    ),
                  ),
                  child: Text(
                    'Menu del Conductor',
                    style: TextStyle(color: Colors.white),
                  )
                ),
                ListTile(
                  leading: Icon(Icons.directions_car, color: Color(0xFF00C896)),
                  title: Text('Mis Viajes U-Ride', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  selected: state.pageIndex == 0,
                  onTap: () {
                    context.read<DriverHomeBloc>().add(ChangeDrawerPage(pageIndex: 0));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Color(0xFF00C896)),
                  title: Text('Perfil del usuario', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  selected: state.pageIndex == 1,
                  onTap: () {
                    context.read<DriverHomeBloc>().add(ChangeDrawerPage(pageIndex: 1));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.supervised_user_circle_rounded, color: Color(0xFF00C896)),
                  title: Text('Roles de usuario', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  selected: state.pageIndex == 2,
                  onTap: () {
                    context.read<DriverHomeBloc>().add(ChangeDrawerPage(pageIndex: 2));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Color(0xFF00C896)),
                  title: Text('Cerrar sesion', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  onTap: () {
                    context.read<DriverHomeBloc>().add(Logout());
                    context.read<BlocSocketIO>().add(DisconnectSocketIO());
                    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
