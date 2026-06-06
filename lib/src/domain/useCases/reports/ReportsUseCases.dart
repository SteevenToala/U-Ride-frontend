import 'package:indriver_clone_flutter/src/domain/useCases/reports/CreateReportUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/reports/GetReportsUseCase.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/reports/ResolveReportUseCase.dart';

class ReportsUseCases {
  CreateReportUseCase createReport;
  GetReportsUseCase getReports;
  ResolveReportUseCase resolveReport;

  ReportsUseCases({
    required this.createReport,
    required this.getReports,
    required this.resolveReport,
  });
}
