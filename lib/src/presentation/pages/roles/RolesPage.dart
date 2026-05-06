import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/Role.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/roles/RolesItem.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/roles/bloc/RolesBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/roles/bloc/RolesEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/roles/bloc/RolesState.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RolesBloc>().add(GetRolesList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RolesBloc, RolesState>(
        builder: (context, state) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1B2A),
                  Color(0xFF1B263B),
                  Color(0xFF415A77),
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 600),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.supervised_user_circle_rounded, size: 80, color: Color(0xFF00B4D8)),
                      SizedBox(height: 20),
                      Text(
                        'SELECCIONA UN ROL',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Elige cómo deseas utilizar U-RIDE hoy',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      SizedBox(height: 50),
                      if (state.roles != null)
                        ...state.roles!.map((Role role) => RolesItem(role)).toList(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}