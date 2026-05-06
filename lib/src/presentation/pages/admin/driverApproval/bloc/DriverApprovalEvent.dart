abstract class DriverApprovalEvent {}

class GetPendingDrivers extends DriverApprovalEvent {}

class ApproveDriver extends DriverApprovalEvent {
  final int id;
  ApproveDriver({ required this.id });
}
