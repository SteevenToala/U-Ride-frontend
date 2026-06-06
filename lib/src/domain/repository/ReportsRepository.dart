import 'package:indriver_clone_flutter/src/domain/models/Report.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

abstract class ReportsRepository {
  Future<Resource<Report>> createReport(Report report);
  Future<Resource<List<Report>>> getReports();
  Future<Resource<Report>> resolveReport(
    int id, {
    required String status,
    String? adminNotes,
    String? suspendUntil,
    required int adminUserId,
  });
}
