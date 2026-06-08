class ApiConfig {

  // URL del backend. Se inyecta al compilar para producción.
  // Si no se pasa ninguna, usa la IP local por defecto.
  static const String API_PROJECT = String.fromEnvironment(
    'API_URL',
    defaultValue: '192.168.100.10:3000',
  );

}