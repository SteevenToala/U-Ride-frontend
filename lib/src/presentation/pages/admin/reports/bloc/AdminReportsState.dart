import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class AdminReportsState {
  final Resource? response;

  const AdminReportsState({this.response});

  AdminReportsState copyWith({Resource? response}) {
    return AdminReportsState(response: response ?? this.response);
  }
}
