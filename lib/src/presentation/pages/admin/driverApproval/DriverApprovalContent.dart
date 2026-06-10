import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/DriverApprovalListItem.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/bloc/DriverApprovalBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/bloc/DriverApprovalEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/bloc/DriverApprovalState.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class DriverApprovalContent extends StatelessWidget {
  final DriverApprovalState state;

  const DriverApprovalContent(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    if (state.pendingDrivers.isEmpty) {
      return _emptyState();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          final cols = w >= 960 ? 3 : w >= 580 ? 2 : 1;
          final hPad = w >= 580 ? 20.0 : 16.0;
          final spacing = 14.0;
          final cardW = cols == 1
              ? double.infinity
              : (w - hPad * 2 - spacing * (cols - 1)) / cols;

          if (cols == 1) {
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
              itemCount: state.pendingDrivers.length,
              itemBuilder: (context, i) {
                final user = state.pendingDrivers[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: DriverApprovalListItem(
                    user,
                    () => context.read<DriverApprovalBloc>().add(ApproveDriver(id: user.id!)),
                  ),
                );
              },
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: state.pendingDrivers
                  .map((user) => SizedBox(
                        width: cardW,
                        child: DriverApprovalListItem(
                          user,
                          () => context.read<DriverApprovalBloc>().add(ApproveDriver(id: user.id!)),
                        ),
                      ))
                  .toList(),
            ),
          );
        }),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppTheme.driverColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_outline_rounded,
                  size: 38,
                  color: AppTheme.driverColor.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 18),
            const Text('Sin solicitudes pendientes',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text('Todos los conductores están al día',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 13)),
            ),
          ]),
        ),
      ],
    );
  }
}
