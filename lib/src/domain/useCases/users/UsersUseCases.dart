import 'package:indriver_clone_flutter/src/domain/useCases/users/ApproveDriverRoleUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/users/GetPendingDriversUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/users/GetUsersUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/users/RequestDriverRoleUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/users/SuspendUserUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/users/UpdateNotificationTokenUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/users/UpdateUserUseCase.dart';

class UsersUseCases {

  UpdateUserUseCase update;
  UpdateNotificationTokenUseCase updateNotificationToken;
  RequestDriverRoleUseCase requestDriverRole;
  GetPendingDriversUseCase getPendingDrivers;
  ApproveDriverRoleUseCase approveDriverRole;
  GetUsersUseCase getUsers;
  SuspendUserUseCase suspendUser;

  UsersUseCases({
    required this.update,
    required this.updateNotificationToken,
    required this.requestDriverRole,
    required this.getPendingDrivers,
    required this.approveDriverRole,
    required this.getUsers,
    required this.suspendUser,
  });

}