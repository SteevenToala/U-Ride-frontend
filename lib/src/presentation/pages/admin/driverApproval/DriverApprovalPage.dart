import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/DriverApprovalContent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/bloc/DriverApprovalBloc.dart';
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
      appBar: AppBar(
        title: Text('Solicitudes de Conductor'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.fromARGB(255, 19, 58, 213),
                Color.fromARGB(255, 65, 173, 255),
              ]
            ),
          ),
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
