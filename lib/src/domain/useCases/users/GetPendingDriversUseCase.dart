import 'package:indriver_clone_flutter/src/domain/repository/UsersRepository.dart';

class GetPendingDriversUseCase {
  UsersRepository repository;
  GetPendingDriversUseCase(this.repository);
  run() => repository.getPendingDrivers();
}
