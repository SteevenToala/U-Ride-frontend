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
  final formKey = GlobalKey<FormState>();

  RegisterBloc(this.authUseCases) : super(RegisterState()) {
    on<RegisterInitEvent>((event, emit) {
      emit(RegisterState(formKey: formKey));
    });

    on<PickImage>((event, emit) async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(state.copyWith(image: image, formKey: formKey));
      }
    });

    on<TakePhoto>((event, emit) async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        emit(state.copyWith(image: image, formKey: formKey));
      }
    });

    on<SaveUserSession>((event, emit) async {
      await authUseCases.saveUserSession.run(event.authResponse);
    });

    on<NameChanged>((event, emit) {
      emit(
        state.copyWith(
          name: BlocFormItem(
            value: event.name.value,
            error: event.name.value.isEmpty ? 'Ingresa el nombre' : null
          ),
          selectedFacultad: state.selectedFacultad
        )
      );
    });

    on<LastnameChanged>((event, emit) {
      emit(
        state.copyWith(
          lastname: BlocFormItem(
            value: event.lastname.value,
            error: event.lastname.value.isEmpty ? 'Ingresa el apellido' : null
          ),
          selectedFacultad: state.selectedFacultad
        )
      );
    });

    on<EmailChanged>((event, emit) {
      emit(
        state.copyWith(
          email: BlocFormItem(
            value: event.email.value,
            error: event.email.value.isEmpty 
              ? 'Ingresa el email' 
              : !event.email.value.contains('.edu')
                ? 'Debe ser un correo institucional (.edu)'
                : null
          ),
          selectedFacultad: state.selectedFacultad
        )
      );
    });

    on<PhoneChanged>((event, emit) {
      emit(
        state.copyWith(
          phone: BlocFormItem(
            value: event.phone.value,
            error: event.phone.value.isEmpty ? 'Ingresa el telefono' : null
          ),
          selectedFacultad: state.selectedFacultad
        )
      );
    });

    on<CareerChanged>((event, emit) {
      emit(
        state.copyWith(
          career: BlocFormItem(
            value: event.career.value,
            error: event.career.value.isEmpty ? 'Selecciona tu carrera' : null
          ),
          selectedFacultad: state.selectedFacultad // Explicitly preserve
        )
      );
    });

    on<FacultadChanged>((event, emit) {
      emit(
        state.copyWith(
          selectedFacultad: event.facultad,
          career: const BlocFormItem(value: ''),
        )
      );
    });


    on<ReferenceZoneChanged>((event, emit) {
      emit(
        state.copyWith(
          referenceZone: BlocFormItem(
            value: event.referenceZone.value,
            error: event.referenceZone.value.isEmpty ? 'Ingresa tu zona (ej. Conocoto)' : null
          ),
          selectedFacultad: state.selectedFacultad
        )
      );
    });

    on<PasswordChanged>((event, emit) {
      emit(
        state.copyWith(
          password: BlocFormItem(
            value: event.password.value,
            error: event.password.value.isEmpty 
              ? 'Ingresa el Password' 
              : event.password.value.length < 6 
                ? 'Mas de 6 caracteres' 
                : null
          ),
          selectedFacultad: state.selectedFacultad
        )
      );
    });

    on<ConfirmPasswordChanged>((event, emit) {
      emit(
        state.copyWith(
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
          selectedFacultad: state.selectedFacultad
        )
      );
    });

    on<FormSubmit>((event, emit) async {
      emit(
        state.copyWith(
          response: Loading(),
          formKey: formKey
        )
      );
      User userToRegister = event.user ?? state.toUser();
      Resource response = await authUseCases.register.run(userToRegister, state.image);
      emit(
        state.copyWith(
          response: response,
          formKey: formKey
        )
      );
    });

    on<FormReset>((event, emit) {
      state.formKey?.currentState?.reset();
    });

    on<TogglePasswordVisibility>((event, emit) {
      emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible, formKey: formKey));
    });

    on<ToggleConfirmPasswordVisibility>((event, emit) {
      emit(state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible, formKey: formKey));
    });
  }
}