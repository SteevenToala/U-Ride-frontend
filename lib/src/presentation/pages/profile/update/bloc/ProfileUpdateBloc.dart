// Removed dart:io import to support Web

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/users/UsersUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateState.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';

class ProfileUpdateBloc extends Bloc<ProfileUpdateEvent, ProfileUpdateState> {
  static const Map<String, List<String>> _facultadCarreras = {
    'Facultad de Ingenieria en Sistemas, Electronica e Industrial': [
      'Software',
      'Tecnologias de la Informacion',
      'Telecomunicaciones',
      'Ingenieria Industrial',
      'Automatizacion y Robotica'
    ],
    'Facultad de Ingenieria Civil y Mecanica': [
      'Ingenieria Civil',
      'Mecanica'
    ],
    'Facultad de Ciencias Administrativas': [
      'Administracion de Empresas',
      'Mercadotecnia',
      'Marketing Digital'
    ],
    'Facultad de Contabilidad y Auditoria': [
      'Contabilidad y Auditoria',
      'Economia',
      'Auditoria y Gestion Financiera'
    ],
    'Facultad de Ciencias de la Salud': [
      'Medicina',
      'Enfermeria',
      'Fisioterapia',
      'Laboratorio Clinico',
      'Nutricion y Dietetica',
      'Psicologia Clinica'
    ],
    'Facultad de Diseno y Arquitectura': [
      'Arquitectura',
      'Diseno Grafico',
      'Diseno Industrial',
      'Diseno Textil e Indumentaria'
    ],
    'Facultad de Ciencia e Ingenieria en Alimentos y Biotecnologia': [
      'Alimentos',
      'Biotecnologia'
    ],
    'Facultad de Ciencias Agropecuarias': [
      'Agronomia',
      'Medicina Veterinaria'
    ],
    'Facultad de Jurisprudencia y Ciencias Sociales': [
      'Derecho',
      'Trabajo Social',
      'Comunicacion'
    ],
    'Facultad de Ciencias Humanas y de la Educacion': [
      'Educacion Basica',
      'Educacion Inicial',
      'Psicopedagogia',
      'Turismo',
      'Hospitalidad y Hosteria',
      'Pedagogia de los Idiomas Nacionales y Extranjeros',
      'Pedagogia de la Actividad Fisica y el Deporte',
      'Pedagogia de la Lengua y Literatura',
      'Pedagogia de la Historia y Ciencias Sociales'
    ]
  };

  AuthUseCases authUseCases;
  UsersUseCases usersUseCases;
  final formKey = GlobalKey<FormState>();

  ProfileUpdateBloc(this.usersUseCases, this.authUseCases): super(ProfileUpdateState()) {
    on<ProfileUpdateInitEvent>((event, emit) {
      String? initialFacultad;
      if (event.user?.career != null) {
        for (var entry in _facultadCarreras.entries) {
          if (entry.value.contains(event.user!.career)) {
            initialFacultad = entry.key;
            break;
          }
        }
      }

      emit(
        ProfileUpdateState(
          id: event.user?.id ?? 0,
          name: BlocFormItem(value: event.user?.name ?? ''),
          lastname: BlocFormItem(value: event.user?.lastname ?? ''),
          phone: BlocFormItem(value: event.user?.phone ?? ''),
          career: BlocFormItem(value: event.user?.career ?? ''),
          referenceZone: BlocFormItem(value: event.user?.referenceZone ?? ''),
          selectedFacultad: initialFacultad,
          formKey: formKey,
          image: null,
          response: null,
        )
      );
    });
    on<NameChanged>((event, emit) {
      emit(
        state.copyWith(
          name: BlocFormItem(
            value: event.name.value,
            error: event.name.value.isEmpty ? 'Ingresa el nombre' : null
          ),
          formKey: formKey
        )
      );
    });
    on<LastNameChanged>((event, emit) {
      emit(
        state.copyWith(
          lastname: BlocFormItem(
            value: event.lastname.value,
            error: event.lastname.value.isEmpty ? 'Ingresa el apellido' : null
          ),
          formKey: formKey
        )
      );
    });
    on<PhoneChanged>((event, emit) {
      emit(
        state.copyWith(
          phone: BlocFormItem(
            value: event.phone.value,
            error: event.phone.value.isEmpty 
              ? 'Ingresa el telefono' 
              : !RegExp(r'^[0-9]+$').hasMatch(event.phone.value) 
                ? 'El numero debe ser solo digitos' 
                : null
          ),
          formKey: formKey
        )
      );
    });
    on<CareerChanged>((event, emit) {
      emit(
        state.copyWith(
          career: BlocFormItem(
            value: event.career.value,
            error: null
          ),
          formKey: formKey
        )
      );
    });
    on<FacultadChanged>((event, emit) {
      emit(
        state.copyWith(
          selectedFacultad: event.facultad,
          career: BlocFormItem(value: ''), // Reset career when faculty changes
          formKey: formKey
        )
      );
    });
    on<ReferenceZoneChanged>((event, emit) {
      emit(
        state.copyWith(
          referenceZone: BlocFormItem(
            value: event.referenceZone.value,
            error: null
          ),
          formKey: formKey
        )
      );
    });
    on<PickImage>((event, emit) async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) { // SI EL USUARIO SELECCIONO UNA IMAGEN
        emit(
           state.copyWith(
            image: image,
            formKey: formKey
          )
        );
      }
    });
    on<TakePhoto>((event, emit) async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) { // SI EL USUARIO SELECCIONO UNA IMAGEN
        emit(
           state.copyWith(
            image: image,
            formKey: formKey
          )
        );
      }
    });
    on<UpdateUserSession>((event, emit) async {
      AuthResponse authResponse = await authUseCases.getUserSession.run();
      authResponse.user.name = event.user.name;
      authResponse.user.lastname = event.user.lastname;
      authResponse.user.phone = event.user.phone;
      authResponse.user.image = event.user.image;
      authResponse.user.career = event.user.career;
      authResponse.user.referenceZone = event.user.referenceZone;
      await authUseCases.saveUserSession.run(authResponse);
    });
    on<FormSubmit>((event, emit) async {
      print('Name: ${state.name.value}');
      print('LastName: ${state.lastname.value}');
      print('Phone: ${state.phone.value}');
      emit(
        state.copyWith(
          response: Loading(),
          formKey: formKey
        )
      );
      Resource response = await usersUseCases.update.run(state.id, state.toUser(), state.image);
      emit(
        state.copyWith(
          response: response,
          formKey: formKey
        )
      );
    });
  }

}