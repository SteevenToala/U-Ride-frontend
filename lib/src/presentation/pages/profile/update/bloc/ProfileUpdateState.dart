import 'package:image_picker/image_picker.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';

class ProfileUpdateState extends Equatable {

  final int id;
  final BlocFormItem name;
  final BlocFormItem lastname;
  final BlocFormItem phone;
  final BlocFormItem career;
  final BlocFormItem referenceZone;
  final String? selectedFacultad;
  final Resource? response;
  final XFile? image;
  final GlobalKey<FormState>? formKey;

  ProfileUpdateState({
    this.id = 0,
    this.name = const BlocFormItem(error: 'Ingresa el nombre'),
    this.lastname = const BlocFormItem(error: 'Ingresa el apellido'),
    this.phone = const BlocFormItem(error: 'Ingresa el telefono'),
    this.career = const BlocFormItem(),
    this.referenceZone = const BlocFormItem(),
    this.selectedFacultad,
    this.formKey,
    this.response,
    this.image
  });

  toUser() => User(
    name: name.value, 
    lastname: lastname.value, 
    phone: phone.value,
    career: career.value,
    referenceZone: referenceZone.value
  );

  ProfileUpdateState copyWith({
    int? id,
    BlocFormItem? name,
    BlocFormItem? lastname,
    BlocFormItem? phone,
    BlocFormItem? career,
    BlocFormItem? referenceZone,
    String? selectedFacultad,
    XFile? image,
    GlobalKey<FormState>? formKey,
    Resource? response
  }) {
    return ProfileUpdateState(
      id: id ?? this.id,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      phone: phone ?? this.phone,
      career: career ?? this.career,
      referenceZone: referenceZone ?? this.referenceZone,
      selectedFacultad: selectedFacultad ?? this.selectedFacultad,
      image: image ?? this.image,
      formKey: formKey,
      response: response
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id, name, lastname, phone, career, referenceZone, selectedFacultad, response, image];

}