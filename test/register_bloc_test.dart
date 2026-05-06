import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterEvent.dart';
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/auth/AuthUseCases.dart';

// Usamos Fake para evitar errores de implementación
class MockAuthUseCases extends Fake implements AuthUseCases {}

void main() {
  group('RegisterBloc Validation Tests', () {
    late RegisterBloc registerBloc;

    setUp(() {
      registerBloc = RegisterBloc(MockAuthUseCases()); 
    });

    test('Initial state should have empty fields', () {
      expect(registerBloc.state.name.value, '');
      expect(registerBloc.state.email.value, '');
    });

    test('NameChanged event should update state and show error if empty', () async {
      registerBloc.add(NameChanged(name: const BlocFormItem(value: '')));
      await registerBloc.stream.first;
      expect(registerBloc.state.name.error, contains('nombre'));
      
      registerBloc.add(NameChanged(name: const BlocFormItem(value: 'Juan')));
      await registerBloc.stream.first;
      expect(registerBloc.state.name.value, 'Juan');
      expect(registerBloc.state.name.error, null);
    });

    test('Password validation should require at least 6 characters', () async {
      registerBloc.add(PasswordChanged(password: const BlocFormItem(value: '123')));
      await registerBloc.stream.first;
      expect(registerBloc.state.password.error, contains('6 caracteres'));

      registerBloc.add(PasswordChanged(password: const BlocFormItem(value: '123456')));
      await registerBloc.stream.first;
      expect(registerBloc.state.password.error, null);
    });
  });
}
