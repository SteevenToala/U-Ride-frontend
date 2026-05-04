# Etapa 1: Compilación de Flutter Web
FROM instrumentisto/flutter:3.24.0 AS build

WORKDIR /app

# Copiar configuración de dependencias
COPY pubspec.* ./
RUN flutter pub get

# Copiar el resto del código
COPY . .

# Construir para web
RUN flutter build web --release

# Etapa 2: Servir con Nginx
FROM nginx:1.25-alpine

# Eliminar default de Nginx
RUN rm -rf /etc/nginx/conf.d/*

# Copiar la build de flutter a Nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Configuración básica para SPA (Flutter Web)
RUN echo "server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files \$uri \$uri/ /index.html; \
    } \
}" > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
