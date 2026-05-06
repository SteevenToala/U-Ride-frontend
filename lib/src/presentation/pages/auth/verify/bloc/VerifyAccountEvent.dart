import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';

abstract class VerifyAccountEvent {}

class VerifyAccountInitEvent extends VerifyAccountEvent {
  final String email;
  VerifyAccountInitEvent({required this.email});
}

class CodeChanged extends VerifyAccountEvent {
  final BlocFormItem code;
  CodeChanged({required this.code});
}

class VerifyAccountSubmit extends VerifyAccountEvent {}
