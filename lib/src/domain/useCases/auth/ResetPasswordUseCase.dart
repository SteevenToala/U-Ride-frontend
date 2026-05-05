import 'package:indriver_clone_flutter/src/domain/repository/AuthRepository.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class ResetPasswordUseCase {
  AuthRepository authRepository;

  ResetPasswordUseCase(this.authRepository);

  Future<Resource<bool>> run(String email, String code, String newPassword) => 
      authRepository.resetPassword(email, code, newPassword);
}
