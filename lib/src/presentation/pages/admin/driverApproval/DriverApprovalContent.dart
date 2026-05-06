import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/DriverApprovalListItem.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/bloc/DriverApprovalBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/bloc/DriverApprovalEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/bloc/DriverApprovalState.dart';

class DriverApprovalContent extends StatelessWidget {

  final DriverApprovalState state;

  DriverApprovalContent(this.state);

  @override
  Widget build(BuildContext context) {
    if (state.pendingDrivers.isEmpty) {
      return Center(
        child: Text('No hay solicitudes pendientes'),
      );
    }

    return ListView.builder(
      itemCount: state.pendingDrivers.length,
      itemBuilder: (context, index) {
        final user = state.pendingDrivers[index];
        return DriverApprovalListItem(
          user, 
          () {
            context.read<DriverApprovalBloc>().add(ApproveDriver(id: user.id!));
          }
        );
      },
    );
  }
}
