import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/ProfileInfoPage.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/ProfileUpdateContent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateState.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  User? user;
  ProfileRoleMode mode = ProfileRoleMode.passenger;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        user = args['user'] as User?;
        mode = args['mode'] as ProfileRoleMode? ?? ProfileRoleMode.passenger;
      } else {
        user = args as User?;
      }
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProfileUpdateBloc>().add(ProfileUpdateInitEvent(user: user));
      });
    }

    // Derive accent color from mode
    final Color accent;
    switch (mode) {
      case ProfileRoleMode.driver:
        accent = AppTheme.driverColor;
        break;
      case ProfileRoleMode.admin:
        accent = AppTheme.accentColor;
        break;
      default:
        accent = AppTheme.passengerColor;
    }

    return Scaffold(
      body: BlocListener<ProfileUpdateBloc, ProfileUpdateState>(
        listener: (context, state) {
          final response = state.response;
          if (response is ErrorData) {
            Fluttertoast.showToast(msg: response.message, toastLength: Toast.LENGTH_LONG);
          } else if (response is Success) {
            final updatedUser = response.data as User;
            Fluttertoast.showToast(msg: 'Actualización exitosa');
            context.read<ProfileUpdateBloc>().add(UpdateUserSession(user: updatedUser));
            Future.delayed(const Duration(seconds: 1), () {
              context.read<ProfileInfoBloc>().add(GetUserInfo());
            });
          }
        },
        child: BlocBuilder<ProfileUpdateBloc, ProfileUpdateState>(
          builder: (context, state) {
            final response = state.response;
            if (response is Loading) {
              return Stack(
                children: [
                  ProfileUpdateContent(state, user, accent: accent),
                  Center(child: CircularProgressIndicator(color: accent)),
                ],
              );
            }
            return ProfileUpdateContent(state, user, accent: accent);
          },
        ),
      ),
    );
  }
}
