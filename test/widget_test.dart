import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

void main() {
  test('Prueba básica de Smoke - Inicialización de Resource', () {
    final resource = Success<String>('U-Ride Test');
    expect(resource, isA<Resource<String>>());
    expect(resource.data, 'U-Ride Test');
  });
}
