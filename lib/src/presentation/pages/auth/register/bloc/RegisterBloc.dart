import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterState.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {

  AuthUseCases authUseCases;
  RegisterBloc(this.authUseCases) : super(RegisterState(formKey: GlobalKey<FormState>())) {
    on<RegisterInitEvent>((event, emit) {
      // No longer resetting everything here to prevent image loss
      emit(state.copyWith(formKey: state.formKey));
    });

    on<PickImage>((event, emit) async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(state.copyWith(image: image));
      }
    });

    on<TakePhoto>((event, emit) async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        emit(state.copyWith(image: image));
      }
    });

    on<SaveUserSession>((event, emit) async {
      await authUseCases.saveUserSession.run(event.authResponse);
    });

    on<NameChanged>((event, emit) {
      emit(state.copyWith(
          name: BlocFormItem(
            value: event.name.value,
            error: event.name.value.isEmpty ? 'Ingresa el nombre' : null
          ),
          response: null // Clear response on change to avoid toast loops
      ));
    });

    on<LastnameChanged>((event, emit) {
      emit(state.copyWith(
          lastname: BlocFormItem(
            value: event.lastname.value,
            error: event.lastname.value.isEmpty ? 'Ingresa el apellido' : null
          ),
          response: null
      ));
    });

    on<EmailChanged>((event, emit) {
      final emailValue = event.email.value;
      String? error;
      if (emailValue.isEmpty) {
        error = 'Ingresa el email';
      } else if (!emailValue.contains('@uta.edu.ec')) {
        error = 'Debe ser institucional (@uta.edu.ec)';
      }
      
      emit(state.copyWith(
          email: BlocFormItem(value: emailValue, error: error),
          response: null
      ));
    });

    on<PhoneChanged>((event, emit) {
      final phoneValue = event.phone.value;
      String? error;
      if (phoneValue.isEmpty) {
        error = 'Ingresa el teléfono';
      } else if (!RegExp(r'^[0-9]+$').hasMatch(phoneValue)) {
        error = 'Solo números';
      } else if (phoneValue.length < 10) {
        error = 'Mínimo 10 dígitos';
      }

      emit(state.copyWith(
          phone: BlocFormItem(value: phoneValue, error: error),
          response: null
      ));
    });

    on<CareerChanged>((event, emit) {
      emit(state.copyWith(
          career: BlocFormItem(
            value: event.career.value,
            error: event.career.value.isEmpty ? 'Selecciona tu carrera' : null
          ),
          response: null
      ));
    });

    on<FacultadChanged>((event, emit) {
      emit(state.copyWith(
          selectedFacultad: event.facultad,
          career: const BlocFormItem(value: ''),
          response: null
      ));
    });

    on<ReferenceZoneChanged>((event, emit) {
      emit(state.copyWith(
          referenceZone: BlocFormItem(
            value: event.referenceZone.value,
            error: event.referenceZone.value.isEmpty ? 'Ingresa tu zona (ej. Conocoto)' : null
          ),
          response: null
      ));
    });

    on<PasswordChanged>((event, emit) {
      emit(state.copyWith(
          password: BlocFormItem(
            value: event.password.value,
            error: event.password.value.isEmpty 
              ? 'Ingresa el Password' 
              : event.password.value.length < 6 
                ? 'Mas de 6 caracteres' 
                : null
          ),
          response: null
      ));
    });

    on<ConfirmPasswordChanged>((event, emit) {
      emit(state.copyWith(
          confirmPassword: BlocFormItem(
            value: event.confirmPassword.value,
            error: event.confirmPassword.value.isEmpty 
              ? 'Confirma el password' 
              : event.confirmPassword.value.length < 6 
                ? 'Mas de 6 caracteres' 
                : event.confirmPassword.value != state.password.value 
                  ? 'Los password no coinciden'
                  : null
          ),
          response: null
      ));
    });

    on<FormSubmit>((event, emit) async {
      emit(
        state.copyWith(
          response: Loading(),
        )
      );
      User userToRegister = event.user ?? state.toUser();
      Resource response = await authUseCases.register.run(userToRegister, state.image);
      emit(
        state.copyWith(
          response: response,
        )
      );
    });

    on<FormReset>((event, emit) {
      state.formKey?.currentState?.reset();
      emit(RegisterState(formKey: state.formKey)); // Emit fresh state but keep same formKey
    });

    on<ResetResponse>((event, emit) {
      emit(state.copyWith(response: null));
    });

    on<TogglePasswordVisibility>((event, emit) {
      emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
    });

    on<ToggleConfirmPasswordVisibility>((event, emit) {
      emit(state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible));
    });
  }
}