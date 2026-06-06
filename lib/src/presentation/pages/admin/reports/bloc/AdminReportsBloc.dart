import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/Report.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/reports/ReportsUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/reports/bloc/AdminReportsEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/reports/bloc/AdminReportsState.dart';

class AdminReportsBloc extends Bloc<AdminReportsEvent, AdminReportsState> {
  final ReportsUseCases reportsUseCases;

  AdminReportsBloc(this.reportsUseCases) : super(const AdminReportsState()) {
    on<LoadReports>(_onLoadReports);
    on<ResolveReport>(_onResolveReport);
  }

  Future<void> _onLoadReports(LoadReports event, Emitter<AdminReportsState> emit) async {
    emit(state.copyWith(response: Loading<List<Report>>()));
    final result = await reportsUseCases.getReports.run();
    emit(state.copyWith(response: result));
  }

  Future<void> _onResolveReport(ResolveReport event, Emitter<AdminReportsState> emit) async {
    await reportsUseCases.resolveReport.run(
      event.reportId,
      status: event.status,
      adminNotes: event.adminNotes,
      suspendUntil: event.suspendUntil,
      adminUserId: event.adminUserId,
    );
    add(LoadReports());
  }
}
