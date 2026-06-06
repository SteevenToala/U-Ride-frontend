import 'package:indriver_clone_flutter/src/domain/models/Report.dart';
import 'package:indriver_clone_flutter/src/domain/repository/ReportsRepository.dart';

class CreateReportUseCase {
  ReportsRepository reportsRepository;
  CreateReportUseCase(this.reportsRepository);
  run(Report report) => reportsRepository.createReport(report);
}
