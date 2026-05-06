import 'package:indriver_clone_flutter/src/domain/repository/UsersRepository.dart';

class ApproveDriverRoleUseCase {
  UsersRepository repository;
  ApproveDriverRoleUseCase(this.repository);
  run(int id) => repository.approveDriverRole(id);
}
