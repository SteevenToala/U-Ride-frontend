import 'package:indriver_clone_flutter/src/domain/repository/UsersRepository.dart';

class SuspendUserUseCase {

  UsersRepository usersRepository;

  SuspendUserUseCase(this.usersRepository);

  run(int id) => usersRepository.suspendUser(id);

}
