import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/users/UsersUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/bloc/UserManagementEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/userManagement/bloc/UserManagementState.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final UsersUseCases usersUseCases;

  UserManagementBloc(this.usersUseCases) : super(const UserManagementState()) {
    on<GetUsers>(_onGetUsers);
    on<SuspendUser>(_onSuspendUser);
  }

  Future<void> _onGetUsers(GetUsers event, Emitter<UserManagementState> emit) async {
    emit(state.copyWith(response: Loading<List<User>>())); // Ahora sí funciona el genérico
    final response = await usersUseCases.getUsers.run();
    emit(state.copyWith(response: response));
  }

  Future<void> _onSuspendUser(SuspendUser event, Emitter<UserManagementState> emit) async {
    await usersUseCases.suspendUser.run(event.id);
    add(GetUsers()); // Refresh list
  }
}
