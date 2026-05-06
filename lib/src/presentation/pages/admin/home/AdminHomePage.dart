import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/blocSocketIO/BlocSocketIO.dart';
import 'package:indriver_clone_flutter/blocSocketIO/BlocSocketIOEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/home/bloc/ClientHomeBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/client/home/bloc/ClientHomeEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/ProfileInfoPage.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/roles/RolesPage.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/UserManagementPage.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _pageIndex = 0;

  List<Widget> pageList = <Widget>[
    UserManagementPage(),
    Center(child: Text('Gestión de Reportes - Módulo Administrativo\n(En construcción)', textAlign: TextAlign.center,)),
    ProfileInfoPage(),
    RolesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administración'),
      ),
      body: pageList[_pageIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color.fromARGB(255, 12, 38, 145),
                    Color.fromARGB(255, 34, 156, 249),
                  ]
                ),
              ),
              child: Text(
                'Menú del Administrador',
                style: TextStyle(color: Colors.white, fontSize: 18),
              )
            ),
            ListTile(
              title: Text('Gestión de Usuarios'),
              selected: _pageIndex == 0,
              onTap: () {
                setState(() {
                  _pageIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Solicitudes de Conductor'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'admin/driver/approval');
              },
            ),
            ListTile(
              title: Text('Gestión de Reportes'),
              selected: _pageIndex == 1,
              onTap: () {
                setState(() {
                  _pageIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Perfil del usuario'),
              selected: _pageIndex == 2,
              onTap: () {
                setState(() {
                  _pageIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Roles de usuario'),
              selected: _pageIndex == 3,
              onTap: () {
                setState(() {
                  _pageIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Cerrar sesión'),
              onTap: () {
                context.read<ClientHomeBloc>().add(Logout());
                context.read<BlocSocketIO>().add(DisconnectSocketIO());
                Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
              },
            )
          ],
        ),
      ),
    );
  }
}
