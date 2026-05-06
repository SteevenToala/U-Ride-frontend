import 'package:equatable/equatable.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class UserManagementState extends Equatable {
  final Resource<List<User>>? response;

  const UserManagementState({this.response});

  UserManagementState copyWith({Resource<List<User>>? response}) {
    return UserManagementState(response: response ?? this.response);
  }

  @override
  List<Object?> get props => [response];
}
