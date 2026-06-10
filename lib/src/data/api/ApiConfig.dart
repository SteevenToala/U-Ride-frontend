class ApiConfig {

  // URL del backend. Se inyecta al compilar para producción.
  // Si no se pasa ninguna, usa la IP local por defecto.
  static const String API_PROJECT = String.fromEnvironment(
    'API_URL',
    defaultValue: '192.168.100.10:3000',
  );

  /// Construye una URI de forma segura y limpia.
  /// Evita FormatException eliminando esquemas duplicados ('https://', 'http://', '//')
  /// y decide si utilizar Uri.https o Uri.http según el entorno.
  static Uri buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    // 1. Limpiar el host de esquemas
    String cleanHost = API_PROJECT
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('//', '');
    
    // Normalizar barras iniciales en la ruta
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    // 2. Determinar si se debe utilizar HTTPS
    // Usamos https si la URL original empezaba con https://, si contiene onrender.com
    // o si no es localhost ni una dirección IP local estándar.
    bool useHttps = API_PROJECT.startsWith('https://') || 
                    API_PROJECT.contains('onrender.com') ||
                    (!cleanHost.contains('localhost') && !RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}').hasMatch(cleanHost));

    if (useHttps) {
      return Uri.https(cleanHost, path, queryParameters);
    } else {
      return Uri.http(cleanHost, path, queryParameters);
    }
  }

}