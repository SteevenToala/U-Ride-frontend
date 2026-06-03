import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/Role.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/roles/RolesItem.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/roles/bloc/RolesBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/roles/bloc/RolesEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/roles/bloc/RolesState.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

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
          return DecoratedBox(
            decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 620),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        _header(),
                        const SizedBox(height: 10),
                        _splitIndicator(),
                        const SizedBox(height: 32),
                        if (state.roles != null)
                          ...state.roles!.map((Role role) => RolesItem(role)),
                        if (state.roles == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: CircularProgressIndicator(color: AppTheme.accentColor),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.accentGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentColor.withValues(alpha: 0.45),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 18),
        const Text(
          '¿CÓMO USARÁS U-RIDE?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona tu modo para esta sesión',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _splitIndicator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: AppTheme.passengerGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'VS',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: AppTheme.driverGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}
