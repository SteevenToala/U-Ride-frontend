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

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  List<Widget> pageList = <Widget>[
    ClientSearchTripsPage(),
    ClientMyReservationsPage(),
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
      body: BlocBuilder<ClientHomeBloc, ClientHomeState>(
        builder: (context, state) {
          return pageList[state.pageIndex];
        },
      ),
      drawer: BlocBuilder<ClientHomeBloc, ClientHomeState>(
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
                    'Menu del cliente',
                    style: TextStyle(color: Colors.white),
                  )
                ),
                ListTile(
                  leading: const Icon(Icons.search, color: Color(0xFF00C896)),
                  title: const Text('Buscar Viajes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  selected: state.pageIndex == 0,
                  onTap: () {
                    context.read<ClientHomeBloc>().add(ChangeDrawerPage(pageIndex: 0));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark, color: Color(0xFF00C896)),
                  title: const Text('Mis Reservas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  selected: state.pageIndex == 1,
                  onTap: () {
                    context.read<ClientHomeBloc>().add(ChangeDrawerPage(pageIndex: 1));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Color(0xFF00C896)),
                  title: Text('Perfil del usuario', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  selected: state.pageIndex == 2,
                  onTap: () {
                    context.read<ClientHomeBloc>().add(ChangeDrawerPage(pageIndex: 2));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.supervised_user_circle_rounded, color: Color(0xFF00C896)),
                  title: Text('Roles de usuario', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  selected: state.pageIndex == 3,
                  onTap: () {
                    context.read<ClientHomeBloc>().add(ChangeDrawerPage(pageIndex: 3));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Color(0xFF00C896)),
                  title: Text('Cerrar sesion', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  onTap: () {
                    context.read<ClientHomeBloc>().add(Logout());
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
