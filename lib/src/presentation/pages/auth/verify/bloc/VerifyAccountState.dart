import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';

class VerifyAccountState extends Equatable {
  final String email;
  final BlocFormItem code;
  final GlobalKey<FormState>? formKey;
  final Resource? response;

  const VerifyAccountState({
    this.email = '',
    this.code = const BlocFormItem(error: 'Ingresa el código'),
    this.formKey,
    this.response,
  });

  VerifyAccountState copyWith({
    String? email,
    BlocFormItem? code,
    GlobalKey<FormState>? formKey,
    Resource? response,
  }) {
    return VerifyAccountState(
      email: email ?? this.email,
      code: code ?? this.code,
      formKey: formKey ?? this.formKey,
      response: response ?? this.response,
    );
  }

  @override
  List<Object?> get props => [email, code, response];
}
