import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/users/UsersUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/info/bloc/ProfileInfoState.dart';

class ProfileInfoBloc extends Bloc<ProfileInfoEvent, ProfileInfoState> {

  AuthUseCases authUseCases;
  UsersUseCases usersUseCases;

  ProfileInfoBloc(this.authUseCases, this.usersUseCases): super(ProfileInfoState()) {
    
    on<GetUserInfo>((event, emit) async {
      AuthResponse? authResponse = await authUseCases.getUserSession.run();
      if (authResponse != null) {
        emit(
          state.copyWith(
            user: authResponse.user
          )
        );
      } else {
        emit(state.copyWith(user: null));
      }
    });

    on<RequestDriverRole>((event, emit) async {
      emit(state.copyWith(response: Loading()));
      Resource response = await usersUseCases.requestDriverRole.run(event.id);
      
      if (response is Success) {
        // Update session if needed
        AuthResponse? authResponse = await authUseCases.getUserSession.run();
        if (authResponse != null) {
          authResponse.user = response.data;
          await authUseCases.saveUserSession.run(authResponse);
          emit(state.copyWith(response: response, user: response.data));
        }
      }
      else {
        emit(state.copyWith(response: response));
      }
    });

  }
}