import 'package:indriver_clone_flutter/src/domain/repository/AuthRepository.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class ValidateResetCodeUseCase {
  AuthRepository authRepository;

  ValidateResetCodeUseCase(this.authRepository);

  Future<Resource<bool>> run(String email, String code) => 
      authRepository.validateResetCode(email, code);
}
