import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/ProfileInfoContent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoState.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<ProfileInfoBloc>().add(GetUserInfo());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocListener<ProfileInfoBloc, ProfileInfoState>(
      listener: (context, state) {
        final response = state.response;
        if (response is Success) {
          Fluttertoast.showToast(msg: 'Solicitud enviada correctamente', toastLength: Toast.LENGTH_LONG);
        }
        else if (response is ErrorData) {
          Fluttertoast.showToast(msg: response.message, toastLength: Toast.LENGTH_LONG);
        }
      },
      child: BlocBuilder<ProfileInfoBloc, ProfileInfoState>(
        builder: (context, state) {
          return ProfileInfoContent(state.user);
        },
      ),
    ));
  }
}
