class ApiConfig {

  // URL del backend. Se inyecta al compilar para producción.
  // Si no se pasa ninguna, usa la IP local por defecto.
  static const String API_PROJECT = String.fromEnvironment(
    'API_URL',
    defaultValue: '10.85.7.23:3000',
  );

  /// Host limpio, sin esquema ('https://', 'http://', '//') ni barras finales.
  static String get _cleanHost {
    String host = API_PROJECT.trim();
    // Elimina de forma robusta 'https://', 'http://', '//', 'https:' o 'http:' al inicio
    host = host.replaceAll(RegExp(r'^(https?:)?//+'), '');
    // Elimina cualquier barra inclinada al final
    host = host.replaceAll(RegExp(r'/+$'), '');
    return host;
  }

  /// Determina si se debe utilizar HTTPS.
  /// Usamos https si la URL original empezaba con https://, si contiene onrender.com
  /// o si no es localhost ni una dirección IP local estándar.
  static bool get _useHttps =>
      API_PROJECT.startsWith('https://') ||
      API_PROJECT.contains('onrender.com') ||
      (!_cleanHost.contains('localhost') &&
          !RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}').hasMatch(_cleanHost));

  /// URL base ('http://host' o 'https://host'), sin barra final.
  /// Útil para construir manualmente URLs (imágenes, sockets, etc.).
  static String get baseUrl => '${_useHttps ? 'https' : 'http'}://$_cleanHost';

  /// Construye una URI de forma segura y limpia.
  /// Evita FormatException eliminando esquemas duplicados ('https://', 'http://', '//')
  /// y decide si utilizar Uri.https o Uri.http según el entorno.
  static Uri buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    // Normalizar barras iniciales en la ruta
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    if (_useHttps) {
      return Uri.https(_cleanHost, path, queryParameters);
    } else {
      return Uri.http(_cleanHost, path, queryParameters);
    }
  }

}