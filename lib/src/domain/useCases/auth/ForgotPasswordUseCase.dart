import 'package:indriver_clone_flutter/src/domain/repository/AuthRepository.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class ForgotPasswordUseCase {
  
  AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Resource<bool>> run(String email) => repository.forgotPassword(email);
  
}