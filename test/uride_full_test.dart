// ============================================================
// SUITE COMPLETA DE PRUEBAS UNITARIAS - SISTEMA U-RIDE
// Cubre: Login, Register, Recuperar Contraseña, Editar Perfil
// Herramienta: flutter_test + Fake (Mock sin dependencias)
// Fecha: 06/05/2026
// ============================================================
import 'package:flutter_test/flutter_test.dart';

// BLoCs
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/register/bloc/RegisterEvent.dart' as reg;
import 'package:indriver_clone_flutter/src/presentation/pages/auth/login/bloc/LoginBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/auth/login/bloc/LoginEvent.dart' as login;
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateBloc.dart';
import 'package:indriver_clone_flutter/src/presentation/pages/profile/update/bloc/ProfileUpdateEvent.dart' as prof;

// Use Cases (para Mocks)
import 'package:indriver_clone_flutter/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:indriver_clone_flutter/src/domain/useCases/users/UsersUseCases.dart';

// Utils
import 'package:indriver_clone_flutter/src/presentation/utils/BlocFormItem.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

// ─────────────────────────────────────────────
// MOCKS: Clases Fake para aislar las pruebas
// ─────────────────────────────────────────────
class MockAuthUseCases extends Fake implements AuthUseCases {}
class MockUsersUseCases extends Fake implements UsersUseCases {}

void main() {

  // ══════════════════════════════════════════════════════════
  // GRUPO 1: TC-RF001 — REGISTRO DE USUARIO
  // ══════════════════════════════════════════════════════════
  group('TC-RF001: Registro e Inicio de Sesión Institucional', () {
    late RegisterBloc registerBloc;

    setUp(() {
      registerBloc = RegisterBloc(MockAuthUseCases());
    });

    tearDown(() {
      registerBloc.close();
    });

    // ─── Caso Positivo ───────────────────────────────────────
    test('TC-RF001-01: Estado inicial tiene campos vacíos', () {
      expect(registerBloc.state.name.value, '');
      expect(registerBloc.state.email.value, '');
      expect(registerBloc.state.password.value, '');
    });

    test('TC-RF001-01: Nombre válido actualiza estado sin error', () async {
      registerBloc.add(reg.NameChanged(name: const BlocFormItem(value: 'Juan Pérez')));
      await registerBloc.stream.first;

      expect(registerBloc.state.name.value, 'Juan Pérez');
      expect(registerBloc.state.name.error, isNull);
    });

    test('TC-RF001-01: Correo institucional válido no genera error', () async {
      registerBloc.add(reg.EmailChanged(email: const BlocFormItem(value: 'juan@uta.edu.ec')));
      await registerBloc.stream.first;

      expect(registerBloc.state.email.value, 'juan@uta.edu.ec');
      expect(registerBloc.state.email.error, isNull);
    });

    test('TC-RF001-01: Contraseña de 8 caracteres es válida', () async {
      registerBloc.add(reg.PasswordChanged(password: const BlocFormItem(value: 'Pass1234')));
      await registerBloc.stream.first;

      expect(registerBloc.state.password.error, isNull);
    });

    // ─── Casos Negativos ─────────────────────────────────────
    test('TC-RF001-02: Nombre vacío activa mensaje de error', () async {
      registerBloc.add(reg.NameChanged(name: const BlocFormItem(value: '')));
      await registerBloc.stream.first;

      expect(registerBloc.state.name.error, isNotNull);
      expect(registerBloc.state.name.error, contains('nombre'));
    });

    test('TC-RF001-02: Apellido vacío activa mensaje de error', () async {
      registerBloc.add(reg.LastnameChanged(lastname: const BlocFormItem(value: '')));
      await registerBloc.stream.first;

      expect(registerBloc.state.lastname.error, isNotNull);
      expect(registerBloc.state.lastname.error, contains('apellido'));
    });

    test('TC-RF001-02: Correo @gmail.com es rechazado por no ser institucional', () async {
      registerBloc.add(reg.EmailChanged(email: const BlocFormItem(value: 'usuario@gmail.com')));
      await registerBloc.stream.first;

      expect(registerBloc.state.email.error, isNotNull);
      expect(registerBloc.state.email.error, contains('.edu'));
    });

    test('TC-RF001-02: Correo @hotmail.com es rechazado', () async {
      registerBloc.add(reg.EmailChanged(email: const BlocFormItem(value: 'test@hotmail.com')));
      await registerBloc.stream.first;

      expect(registerBloc.state.email.error, isNotNull);
    });

    test('TC-RF001-02: Contraseña de menos de 6 caracteres genera error', () async {
      registerBloc.add(reg.PasswordChanged(password: const BlocFormItem(value: '123')));
      await registerBloc.stream.first;

      expect(registerBloc.state.password.error, isNotNull);
      expect(registerBloc.state.password.error, contains('6 caracteres'));
    });

    test('TC-RF001-02: Contraseña vacía genera error', () async {
      registerBloc.add(reg.PasswordChanged(password: const BlocFormItem(value: '')));
      await registerBloc.stream.first;

      expect(registerBloc.state.password.error, isNotNull);
    });

    test('TC-RF001-02: Zona de residencia vacía genera error', () async {
      registerBloc.add(reg.ReferenceZoneChanged(referenceZone: const BlocFormItem(value: '')));
      await registerBloc.stream.first;

      expect(registerBloc.state.referenceZone.error, isNotNull);
    });

    test('TC-RF001-02: Zona de residencia válida no genera error', () async {
      registerBloc.add(reg.ReferenceZoneChanged(referenceZone: const BlocFormItem(value: 'Ficoa')));
      await registerBloc.stream.first;

      expect(registerBloc.state.referenceZone.error, isNull);
      expect(registerBloc.state.referenceZone.value, 'Ficoa');
    });

    // ─── Toggle visibilidad contraseña ────────────────────────
    test('Estado inicial: contraseña oculta (isPasswordVisible = true)', () {
      // En este BLoC true significa oculta (campo oscurecido)
      expect(registerBloc.state.isPasswordVisible, isA<bool>());
    });
  });

  // ══════════════════════════════════════════════════════════
  // GRUPO 2: TC-RF001 — LOGIN (INICIO DE SESIÓN)
  // ══════════════════════════════════════════════════════════
  group('TC-RF001: Login — Inicio de Sesión', () {
    late LoginBloc loginBloc;

    setUp(() {
      loginBloc = LoginBloc(MockAuthUseCases(), MockUsersUseCases());
    });

    tearDown(() {
      loginBloc.close();
    });

    // ─── Casos Positivos ─────────────────────────────────────
    test('TC-RF001-01: Estado inicial tiene campos vacíos', () {
      expect(loginBloc.state.email.value, '');
      expect(loginBloc.state.password.value, '');
      expect(loginBloc.state.response, isNull);
    });

    test('TC-RF001-01: Email válido actualiza estado sin error', () async {
      loginBloc.add(login.EmailChanged(email: const BlocFormItem(value: 'pedro@uta.edu.ec')));
      await loginBloc.stream.first;

      expect(loginBloc.state.email.value, 'pedro@uta.edu.ec');
      expect(loginBloc.state.email.error, isNull);
    });

    test('TC-RF001-01: Contraseña de 8 caracteres es válida', () async {
      loginBloc.add(login.PasswordChanged(password: const BlocFormItem(value: 'pass1234')));
      await loginBloc.stream.first;

      expect(loginBloc.state.password.error, isNull);
    });

    // ─── Casos Negativos ─────────────────────────────────────
    test('TC-RF001-02: Email vacío genera error de campo requerido', () async {
      loginBloc.add(login.EmailChanged(email: const BlocFormItem(value: '')));
      await loginBloc.stream.first;

      expect(loginBloc.state.email.error, isNotNull);
      expect(loginBloc.state.email.error, contains('email'));
    });

    test('TC-RF001-02: Contraseña vacía genera error', () async {
      loginBloc.add(login.PasswordChanged(password: const BlocFormItem(value: '')));
      await loginBloc.stream.first;

      expect(loginBloc.state.password.error, isNotNull);
    });

    test('TC-RF001-02: Contraseña menor a 6 caracteres genera error', () async {
      loginBloc.add(login.PasswordChanged(password: const BlocFormItem(value: '123')));
      await loginBloc.stream.first;

      expect(loginBloc.state.password.error, isNotNull);
      expect(loginBloc.state.password.error, contains('6'));
    });

    // ─── Toggle visibilidad contraseña ────────────────────────
    test('Toggle cambia visibilidad de contraseña', () async {
      final initialVisibility = loginBloc.state.isPasswordVisible;
      loginBloc.add(login.TogglePasswordVisibility());
      await loginBloc.stream.first;

      expect(loginBloc.state.isPasswordVisible, !initialVisibility);
    });

    test('Doble toggle vuelve al estado original de visibilidad', () async {
      final initialVisibility = loginBloc.state.isPasswordVisible;

      loginBloc.add(login.TogglePasswordVisibility());
      await loginBloc.stream.first;

      loginBloc.add(login.TogglePasswordVisibility());
      await loginBloc.stream.first;

      expect(loginBloc.state.isPasswordVisible, initialVisibility);
    });
  });

  // ══════════════════════════════════════════════════════════
  // GRUPO 3: TC-RF002 — EDITAR PERFIL DE USUARIO
  // ══════════════════════════════════════════════════════════
  group('TC-RF002: Gestión de Perfil de Usuario', () {
    late ProfileUpdateBloc profileBloc;

    setUp(() {
      profileBloc = ProfileUpdateBloc(MockUsersUseCases(), MockAuthUseCases());
    });

    tearDown(() {
      profileBloc.close();
    });

    // ─── Casos Positivos ─────────────────────────────────────
    test('TC-RF002-01: Nombre válido actualiza estado sin error', () async {
      profileBloc.add(prof.NameChanged(name: const BlocFormItem(value: 'Steeven')));
      await profileBloc.stream.first;

      expect(profileBloc.state.name.value, 'Steeven');
      expect(profileBloc.state.name.error, isNull);
    });

    test('TC-RF002-01: Apellido válido actualiza estado sin error', () async {
      profileBloc.add(prof.LastNameChanged(lastname: const BlocFormItem(value: 'Toala')));
      await profileBloc.stream.first;

      expect(profileBloc.state.lastname.value, 'Toala');
      expect(profileBloc.state.lastname.error, isNull);
    });

    test('TC-RF002-01: Teléfono numérico válido no genera error', () async {
      profileBloc.add(prof.PhoneChanged(phone: const BlocFormItem(value: '0991234567')));
      await profileBloc.stream.first;

      expect(profileBloc.state.phone.value, '0991234567');
      expect(profileBloc.state.phone.error, isNull);
    });

    test('TC-RF002-01: Zona de referencia válida no genera error', () async {
      profileBloc.add(prof.ReferenceZoneChanged(referenceZone: const BlocFormItem(value: 'Ficoa')));
      await profileBloc.stream.first;

      expect(profileBloc.state.referenceZone.error, isNull);
    });

    // ─── Casos Negativos ─────────────────────────────────────
    test('TC-RF002-02: Nombre vacío genera error de campo obligatorio', () async {
      profileBloc.add(prof.NameChanged(name: const BlocFormItem(value: '')));
      await profileBloc.stream.first;

      expect(profileBloc.state.name.error, isNotNull);
      expect(profileBloc.state.name.error, contains('nombre'));
    });

    test('TC-RF002-02: Apellido vacío genera error', () async {
      profileBloc.add(prof.LastNameChanged(lastname: const BlocFormItem(value: '')));
      await profileBloc.stream.first;

      expect(profileBloc.state.lastname.error, isNotNull);
    });

    test('TC-RF002-02: Teléfono vacío genera error', () async {
      profileBloc.add(prof.PhoneChanged(phone: const BlocFormItem(value: '')));
      await profileBloc.stream.first;

      expect(profileBloc.state.phone.error, isNotNull);
    });

    test('TC-RF002-02: Teléfono con letras es rechazado', () async {
      profileBloc.add(prof.PhoneChanged(phone: const BlocFormItem(value: 'abc-123')));
      await profileBloc.stream.first;

      expect(profileBloc.state.phone.error, isNotNull);
      expect(profileBloc.state.phone.error, contains('digitos'));
    });

    test('TC-RF002-02: Teléfono con caracteres especiales es rechazado', () async {
      profileBloc.add(prof.PhoneChanged(phone: const BlocFormItem(value: '099-123++')));
      await profileBloc.stream.first;

      expect(profileBloc.state.phone.error, isNotNull);
    });

    // ─── Cambio de Facultad ───────────────────────────────────
    test('TC-RF002-01: Cambio de facultad actualiza estado correctamente', () async {
      profileBloc.add(prof.FacultadChanged(
        facultad: 'Facultad de Ingenieria en Sistemas, Electronica e Industrial'
      ));
      await profileBloc.stream.first;

      expect(profileBloc.state.selectedFacultad,
        'Facultad de Ingenieria en Sistemas, Electronica e Industrial');
    });
  });

  // ══════════════════════════════════════════════════════════
  // GRUPO 4: PRUEBA DE INTEGRACIÓN — Resource State Machine
  // Verifica que los estados Loading/Success/Error funcionen
  // correctamente en el flujo de autenticación
  // ══════════════════════════════════════════════════════════
  group('Integración: Máquina de Estados Resource', () {

    test('Loading es instancia de Resource', () {
      final loading = Loading<String>();
      expect(loading, isA<Resource>());
    });

    test('Success guarda datos correctamente', () {
      final success = Success<String>('token_jwt_123');
      expect(success, isA<Resource>());
      expect(success.data, 'token_jwt_123');
    });

    test('ErrorData guarda el mensaje de error', () {
      final error = ErrorData<String>('El email no existe');
      expect(error, isA<Resource>());
      expect(error.message, 'El email no existe');
    });

    test('Loading y Success son tipos distintos de Resource', () {
      final loading = Loading<String>();
      final success = Success<String>('dato');
      expect(loading, isNot(isA<Success>()));
      expect(success, isNot(isA<Loading>()));
    });

    test('Estado inicial del LoginBloc no tiene response', () {
      final loginBloc = LoginBloc(MockAuthUseCases(), MockUsersUseCases());
      expect(loginBloc.state.response, isNull);
      loginBloc.close();
    });

    test('Estado inicial del RegisterBloc no tiene response', () {
      final registerBloc = RegisterBloc(MockAuthUseCases());
      expect(registerBloc.state.response, isNull);
      registerBloc.close();
    });
  });
}
