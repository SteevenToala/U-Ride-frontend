import 'package:indriver_clone_flutter/src/domain/repository/ReportsRepository.dart';

class ResolveReportUseCase {
  ReportsRepository reportsRepository;
  ResolveReportUseCase(this.reportsRepository);

  run(
    int id, {
    required String status,
    String? adminNotes,
    String? suspendUntil,
    required int adminUserId,
  }) => reportsRepository.resolveReport(
    id,
    status: status,
    adminNotes: adminNotes,
    suspendUntil: suspendUntil,
    adminUserId: adminUserId,
  );
}
