import 'package:indriver_clone_flutter/src/domain/models/user.dart';

enum ReportStatus { OPEN, REVIEWED, WARNED, ACTION_APPLIED, DISMISSED }

class Report {
  int? id;
  int reporterUserId;
  int reportedUserId;
  String reason;
  String? evidenceUrl;
  ReportStatus status;
  String? adminNotes;
  DateTime? createdAt;
  User? reporter;
  User? reported;

  Report({
    this.id,
    required this.reporterUserId,
    required this.reportedUserId,
    required this.reason,
    this.evidenceUrl,
    this.status = ReportStatus.OPEN,
    this.adminNotes,
    this.createdAt,
    this.reporter,
    this.reported,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      reporterUserId: json['reporter_user_id'],
      reportedUserId: json['reported_user_id'],
      reason: json['reason'] ?? '',
      evidenceUrl: json['evidence_url'],
      status: ReportStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'OPEN'),
        orElse: () => ReportStatus.OPEN,
      ),
      adminNotes: json['admin_notes'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      reporter: json['reporter'] != null ? User.fromJson(json['reporter']) : null,
      reported: json['reported'] != null ? User.fromJson(json['reported']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'reporter_user_id': reporterUserId,
    'reported_user_id': reportedUserId,
    'reason': reason,
    if (evidenceUrl != null) 'evidence_url': evidenceUrl,
  };
}
