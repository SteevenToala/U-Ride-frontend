import 'package:indriver_clone_flutter/src/domain/repository/UsersRepository.dart';

class GetUsersUseCase {

  UsersRepository usersRepository;

  GetUsersUseCase(this.usersRepository);

  run() => usersRepository.getUsers();

}
