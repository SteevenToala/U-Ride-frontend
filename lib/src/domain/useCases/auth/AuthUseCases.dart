import 'package:indriver_clone_flutter/src/domain/useCases/auth/GetUserSessionUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/LoginUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/LogoutUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/RegisterUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/SaveUserSessionUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/ForgotPasswordUseCase.dart';

class AuthUseCases {

  LoginUseCase login;
  RegisterUseCase register;
  SaveUserSessionUseCase saveUserSession;
  GetUserSessionUseCase getUserSession;
  LogoutUseCase logout;
  ForgotPasswordUseCase forgotPassword;

  AuthUseCases({
    required this.login,
    required this.register,
    required this.saveUserSession,
    required this.getUserSession,
    required this.logout,
    required this.forgotPassword,
  });

}