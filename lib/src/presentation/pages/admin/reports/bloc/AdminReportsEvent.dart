abstract class AdminReportsEvent {}

class LoadReports extends AdminReportsEvent {}

class ResolveReport extends AdminReportsEvent {
  final int reportId;
  final String status;
  final String? adminNotes;
  final String? suspendUntil;
  final int adminUserId;

  ResolveReport({
    required this.reportId,
    required this.status,
    this.adminNotes,
    this.suspendUntil,
    required this.adminUserId,
  });
}
