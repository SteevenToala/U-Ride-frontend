import 'package:indriver_clone_flutter/src/domain/repository/ReportsRepository.dart';

class GetReportsUseCase {
  ReportsRepository reportsRepository;
  GetReportsUseCase(this.reportsRepository);
  run() => reportsRepository.getReports();
}
