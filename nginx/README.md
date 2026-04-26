# 🚀 Guía para construir y subir imágenes Docker (Flutter, Angular, API)

Esta guía muestra cómo construir y subir imágenes a Docker Hub usando variables genéricas:

* `TU_USUARIO`
* `VERSION`

---

# 🔐 1. Login en Docker Hub

```bash
docker login
```

---

# 🐳 2. Flutter Web

## 🔨 Build

```bash
docker build \
  -t TU_USUARIO/mechanic-flutter-web:VERSION \
  -f mechanic_mobile/Dockerfile.prod \
  ./mechanic_mobile
```

## 🚀 Push

```bash
docker push TU_USUARIO/mechanic-flutter-web:VERSION
```

---

# 🟢 3. Angular Web

## 🔨 Build

```bash
docker build \
  -t TU_USUARIO/mechanic-web:VERSION \
  -f mechanic-web/Dockerfile.prod \
  ./mechanic-web
```

## 🚀 Push

```bash
docker push TU_USUARIO/mechanic-web:VERSION
```

---

# 🔵 4. API (Spring Boot)

## 🔨 Build

```bash
docker build \
  -t TU_USUARIO/mechanic-api:VERSION \
  -f mechanic-api/Dockerfile.prod \
  ./mechanic-api
```

## 🚀 Push

```bash
docker push TU_USUARIO/mechanic-api:VERSION
```

---

# 🧪 5. Verificar imágenes locales

```bash
docker images
```

Deberías ver:

```
TU_USUARIO/mechanic-flutter-web   VERSION
TU_USUARIO/mechanic-web           VERSION
TU_USUARIO/mechanic-api           VERSION
```

---

# 🐳 6. Uso en docker-compose (producción)

```yaml
services:
  serv-mechanic-api:
    image: TU_USUARIO/mechanic-api:VERSION

  serv-mechanic-web:
    image: TU_USUARIO/mechanic-web:VERSION

  serv-mechanic-flutter-web:
    image: TU_USUARIO/mechanic-flutter-web:VERSION
```

---

# 🚀 7. Despliegue en servidor

```bash
docker compose pull
docker compose up -d
```

---

# 🧠 Buenas prácticas

* Usa versiones fijas (`1.0.0`, `1.0.1`, etc.)
* No sobrescribas versiones ya publicadas
* Usa `latest` solo en desarrollo si lo necesitas

---

# 🧾 Resumen rápido

```bash
docker build -t TU_USUARIO/servicio:VERSION -f ruta/Dockerfile.prod ./ruta
docker push TU_USUARIO/servicio:VERSION
```

---

# 🎯 Ejemplo real

```bash
docker build -t sebastiandevjs/mechanic-api:1.0.0 -f finance-api/Dockerfile.prod ./finance-api
docker push sebastiandevjs/mechanic-api:1.0.0
```

---
