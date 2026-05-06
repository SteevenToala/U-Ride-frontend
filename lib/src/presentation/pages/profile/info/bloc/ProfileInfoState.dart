import 'package:equatable/equatable.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class ProfileInfoState extends Equatable {

  final User? user;
  final Resource? response;

  ProfileInfoState({this.user, this.response});

  ProfileInfoState copyWith({
    User? user,
    Resource? response
  }) {
    return ProfileInfoState(
      user: user ?? this.user,
      response: response
    );
  }

  @override
  List<Object?> get props => [user, response];

}