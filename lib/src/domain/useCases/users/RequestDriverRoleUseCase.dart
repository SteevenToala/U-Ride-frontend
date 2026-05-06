import 'package:indriver_clone_flutter/src/domain/repository/UsersRepository.dart';

class RequestDriverRoleUseCase {

  UsersRepository repository;

  RequestDriverRoleUseCase(this.repository);

  run(int id) => repository.requestDriverRole(id);

}
