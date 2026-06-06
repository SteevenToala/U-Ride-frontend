import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/DriverApprovalContent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/bloc/DriverApprovalBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/bloc/DriverApprovalEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/bloc/DriverApprovalState.dart';

class DriverApprovalPage extends StatefulWidget {
  const DriverApprovalPage({super.key});

  @override
  State<DriverApprovalPage> createState() => _DriverApprovalPageState();
}

class _DriverApprovalPageState extends State<DriverApprovalPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverApprovalBloc>().add(GetPendingDrivers());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDarkCard,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.driverColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_car_rounded, color: AppTheme.driverColor, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Solicitudes de Conductor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                Text('Aprobación pendiente', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: BlocListener<DriverApprovalBloc, DriverApprovalState>(
        listener: (context, state) {
          final response = state.response;
          if (response is Success) {
            if (response.data is! List) { // If it was an approval success
              Fluttertoast.showToast(msg: 'Conductor aprobado correctamente', toastLength: Toast.LENGTH_LONG);
            }
          } else if (response is ErrorData) {
            Fluttertoast.showToast(msg: response.message, toastLength: Toast.LENGTH_LONG);
          }
        },
        child: BlocBuilder<DriverApprovalBloc, DriverApprovalState>(
          builder: (context, state) {
            return DriverApprovalContent(state);
          },
        ),
      ),
    );
  }
}
