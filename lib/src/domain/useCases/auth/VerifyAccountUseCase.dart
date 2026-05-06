import 'package:indriver_clone_flutter/src/domain/repository/AuthRepository.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class VerifyAccountUseCase {

  AuthRepository repository;

  VerifyAccountUseCase(this.repository);

  run(String email, String code) => repository.verifyAccount(email, code);

}
