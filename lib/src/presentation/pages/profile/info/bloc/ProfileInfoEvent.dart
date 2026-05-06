abstract class ProfileInfoEvent {}

class GetUserInfo extends ProfileInfoEvent {}

class RequestDriverRole extends ProfileInfoEvent {
  final int id;
  RequestDriverRole({ required this.id });
}