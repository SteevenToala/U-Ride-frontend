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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 14),
            const Text('Sin solicitudes pendientes', style: TextStyle(color: AppTheme.textMuted, fontSize: 15)),
            const SizedBox(height: 6),
            const Text('Todos los conductores están al día', style: TextStyle(color: AppTheme.textFaint, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: state.pendingDrivers.length,
      itemBuilder: (context, index) {
        final user = state.pendingDrivers[index];
        return DriverApprovalListItem(
          user,
          () => context.read<DriverApprovalBloc>().add(ApproveDriver(id: user.id!)),
        );
      },
    );
  }
}
