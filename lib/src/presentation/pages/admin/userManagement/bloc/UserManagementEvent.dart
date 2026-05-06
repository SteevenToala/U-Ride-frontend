abstract class UserManagementEvent {}

class GetUsers extends UserManagementEvent {}

class SuspendUser extends UserManagementEvent {
  final int id;
  SuspendUser(this.id);
}
