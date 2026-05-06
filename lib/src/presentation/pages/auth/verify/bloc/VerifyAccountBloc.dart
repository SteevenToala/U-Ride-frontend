import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/verify/bloc/VerifyAccountEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/verify/bloc/VerifyAccountState.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';

class VerifyAccountBloc extends Bloc<VerifyAccountEvent, VerifyAccountState> {
  AuthUseCases authUseCases;

  VerifyAccountBloc(this.authUseCases) : super(const VerifyAccountState()) {
    on<VerifyAccountInitEvent>((event, emit) {
      emit(state.copyWith(
        email: event.email,
        formKey: GlobalKey<FormState>(),
      ));
    });

    on<CodeChanged>((event, emit) {
      emit(state.copyWith(
        code: BlocFormItem(
          value: event.code.value,
          error: event.code.value.length < 6 ? 'El código debe tener 6 dígitos' : null,
        ),
      ));
    });

    on<VerifyAccountSubmit>((event, emit) async {
      if (state.formKey!.currentState!.validate()) {
        emit(state.copyWith(response: Loading()));
        Resource response = await authUseCases.verifyAccount.run(state.email, state.code.value);
        emit(state.copyWith(response: response));
      }
    });
  }
}
