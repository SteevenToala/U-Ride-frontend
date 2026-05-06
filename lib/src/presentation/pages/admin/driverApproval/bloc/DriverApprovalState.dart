import 'package:equatable/equatable.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class DriverApprovalState extends Equatable {

  final List<User> pendingDrivers;
  final Resource? response;

  DriverApprovalState({
    this.pendingDrivers = const [],
    this.response
  });

  DriverApprovalState copyWith({
    List<User>? pendingDrivers,
    Resource? response
  }) {
    return DriverApprovalState(
      pendingDrivers: pendingDrivers ?? this.pendingDrivers,
      response: response
    );
  }

  @override
  List<Object?> get props => [pendingDrivers, response];

}
