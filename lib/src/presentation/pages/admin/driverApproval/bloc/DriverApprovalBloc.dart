import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/users/UsersUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/bloc/DriverApprovalEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/admin/driverApproval/bloc/DriverApprovalState.dart';

class DriverApprovalBloc extends Bloc<DriverApprovalEvent, DriverApprovalState> {

  UsersUseCases usersUseCases;

  DriverApprovalBloc(this.usersUseCases): super(DriverApprovalState()) {
    
    on<GetPendingDrivers>((event, emit) async {
      emit(state.copyWith(response: Loading()));
      Resource response = await usersUseCases.getPendingDrivers.run();
      if (response is Success) {
        emit(state.copyWith(pendingDrivers: response.data, response: response));
      } else {
        emit(state.copyWith(response: response));
      }
    });

    on<ApproveDriver>((event, emit) async {
      emit(state.copyWith(response: Loading()));
      Resource response = await usersUseCases.approveDriverRole.run(event.id);
      if (response is Success) {
        // Remove from list or refresh
        add(GetPendingDrivers());
      } else {
        emit(state.copyWith(response: response));
      }
    });

  }
}
