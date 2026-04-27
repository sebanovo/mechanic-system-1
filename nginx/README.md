# 🚀 Guía para construir y subir imágenes Docker (Flutter, Angular, API)

Esta guía muestra cómo construir y subir imágenes a Docker Hub usando variables genéricas:

* `TU_USUARIO`
* `1.0.0`

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
  -t TU_USUARIO/mechanic-flutter-web:1.0.0 \
  -f mechanic_mobile/Dockerfile.prod \
  ./mechanic_mobile
```

## 🚀 Push

```bash
docker push TU_USUARIO/mechanic-flutter-web:1.0.0
```

---

# 🟢 3. Angular Web

## 🔨 Build

```bash
docker build \
  -t TU_USUARIO/mechanic-web:1.0.0 \
  -f mechanic-web/Dockerfile.prod \
  ./mechanic-web
```

## 🚀 Push

```bash
docker push TU_USUARIO/mechanic-web:1.0.0
```

---

# 🔵 4. API (Spring Boot)

## 🔨 Build

```bash
docker build \
  -t TU_USUARIO/mechanic-api:1.0.0 \
  -f mechanic-api/Dockerfile.prod \
  ./mechanic-api
```

## 🚀 Push

```bash
docker push TU_USUARIO/mechanic-api:1.0.0
```

---

# 🧪 5. Verificar imágenes locales

```bash
docker images
```

Deberías ver:

```
TU_USUARIO/mechanic-flutter-web   1.0.0
TU_USUARIO/mechanic-web           1.0.0
TU_USUARIO/mechanic-api           1.0.0
```

---

# 🐳 6. Uso en docker-compose (producción)

```yaml
services:
  serv-mechanic-api:
    image: TU_USUARIO/mechanic-api:1.0.0

  serv-mechanic-web:
    image: TU_USUARIO/mechanic-web:1.0.0

  serv-mechanic-flutter-web:
    image: TU_USUARIO/mechanic-flutter-web:1.0.0
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
docker build -t TU_USUARIO/servicio:1.0.0 -f ruta/Dockerfile.prod ./ruta
docker push TU_USUARIO/servicio:1.0.0
```

---

# 🎯 Ejemplo real

```bash
docker build -t sebastiandevjs/mechanic-api:1.0.0 -f mechacnic-api/Dockerfile.prod ./mechacnic-api
docker push sebastiandevjs/mechanic-api:1.0.0
```


# 1. Build de todas las imágenes
docker build -t sebastiandevjs/mech-api:1.0.0       ./mechanic-api    -f ./mechanic-api/Dockerfile.prod
docker build -t sebastiandevjs/mech-worker:1.0.0    ./mechanic-api    -f ./mechanic-api/Dockerfile.prod
docker build -t sebastiandevjs/mech-web:1.0.0       ./mechanic-web    -f ./mechanic-web/Dockerfile.prod
docker build -t sebastiandevjs/mech-flutter-web:1.0.0 ./mechanic_mobile -f ./mechanic_mobile/Dockerfile.prod

# 2. Login en Docker Hub
docker login

# 3. Push de todas las imágenes
docker push sebastiandevjs/mech-api:1.0.0
docker push sebastiandevjs/mech-worker:1.0.0
docker push sebastiandevjs/mech-web:1.0.0
docker push sebastiandevjs/mech-flutter-web:1.0.0
---
