import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterEvent.dart' as reg;
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateEvent.dart' as prof;
import 'package:indriver_clone_flutter/src/domain/useCases/users/UsersUseCases.dart';

class MockAuthUseCases extends Fake implements AuthUseCases {}
class MockUsersUseCases extends Fake implements UsersUseCases {}

void main() {
  group('TC-RF001: Registro e Inicio de Sesión Institucional', () {
    late RegisterBloc registerBloc;

    setUp(() {
      registerBloc = RegisterBloc(MockAuthUseCases()); 
    });

    test('TC-RF001-01: Registro Exitoso (Datos Válidos)', () async {
      // Añadimos el evento y esperamos a que el Stream emita el nuevo estado
      registerBloc.add(reg.NameChanged(name: const BlocFormItem(value: 'Estudiante')));
      await registerBloc.stream.first;
      
      expect(registerBloc.state.name.value, 'Estudiante');
      
      registerBloc.add(reg.EmailChanged(email: const BlocFormItem(value: 'estudiante@uta.edu.ec')));
      await registerBloc.stream.first;

      expect(registerBloc.state.email.value, 'estudiante@uta.edu.ec');
      expect(registerBloc.state.email.error, null);
    });

    test('TC-RF001-02: Rechazo de Correo No Institucional', () async {
      registerBloc.add(reg.EmailChanged(email: const BlocFormItem(value: 'usuario@gmail.com')));
      await registerBloc.stream.first;
      
      expect(registerBloc.state.email.error, contains('.edu'));
    });
  });

  group('TC-RF002: Gestión de Perfil de Usuario', () {
    late ProfileUpdateBloc profileUpdateBloc;

    setUp(() {
      profileUpdateBloc = ProfileUpdateBloc(MockUsersUseCases(), MockAuthUseCases());
    });

    test('TC-RF002-02: Validación de Campos Obligatorios (Nombre Vacío)', () async {
      profileUpdateBloc.add(prof.NameChanged(name: const BlocFormItem(value: '')));
      await profileUpdateBloc.stream.first;
      
      expect(profileUpdateBloc.state.name.error, contains('Ingresa'));
    });

    test('TC-RF002-02: Validación de Formato de Teléfono', () async {
      profileUpdateBloc.add(prof.PhoneChanged(phone: const BlocFormItem(value: 'abc')));
      await profileUpdateBloc.stream.first;
      
      expect(profileUpdateBloc.state.phone.error, isNotNull);
    });
  });
}
