import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/injection.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/verify/VerifyAccountContent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/verify/bloc/VerifyAccountBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/verify/bloc/VerifyAccountEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/verify/bloc/VerifyAccountState.dart';

class VerifyAccountPage extends StatefulWidget {
  const VerifyAccountPage({super.key});

  @override
  State<VerifyAccountPage> createState() => _VerifyAccountPageState();
}

class _VerifyAccountPageState extends State<VerifyAccountPage> {
  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      body: BlocProvider(
        create: (context) => VerifyAccountBloc(locator<AuthUseCases>())..add(VerifyAccountInitEvent(email: email)),
        child: BlocListener<VerifyAccountBloc, VerifyAccountState>(
          listener: (context, state) {
            final response = state.response;
            if (response is Success) {
              Fluttertoast.showToast(msg: 'Cuenta verificada exitosamente. Ahora puedes iniciar sesión.', toastLength: Toast.LENGTH_LONG);
              Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
            } else if (response is ErrorData) {
              Fluttertoast.showToast(msg: response.message, toastLength: Toast.LENGTH_LONG);
            }
          },
          child: BlocBuilder<VerifyAccountBloc, VerifyAccountState>(
            builder: (context, state) {
              return VerifyAccountContent(state);
            },
          ),
        ),
      ),
    );
  }
}
