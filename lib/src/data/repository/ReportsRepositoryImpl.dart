import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/ReportsService.dart';
import 'package:indriver_clone_flutter/src/domain/models/Report.dart';
import 'package:indriver_clone_flutter/src/domain/repository/ReportsRepository.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsService reportsService;

  ReportsRepositoryImpl(this.reportsService);

  @override
  Future<Resource<Report>> createReport(Report report) => reportsService.createReport(report);

  @override
  Future<Resource<List<Report>>> getReports() => reportsService.getReports();

  @override
  Future<Resource<Report>> resolveReport(
    int id, {
    required String status,
    String? adminNotes,
    String? suspendUntil,
    required int adminUserId,
  }) => reportsService.resolveReport(
    id,
    status: status,
    adminNotes: adminNotes,
    suspendUntil: suspendUntil,
    adminUserId: adminUserId,
  );
}
