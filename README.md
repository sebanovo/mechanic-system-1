#  Sistema de auxiliar mecanico

### Servicios (Docker)

|    Servicio     | Tecnología        | Puerto | Descripción   |
|-----------------|-------------------|--------|---------------|
| serv-mech-web   | Angular           | 4200   | Interfaz web  |
| serv-mech-api   | Python            | 8000   | FAST API      |
| ser-mech-db     | PostgreSQL        | 5432   | Base de datos |

---

### 🧯 Comandos Docker

Ejecutar
```bash
cp .env.sample .env
```
```bash

# Iniciar servicios
docker compose up --build

# Iniciar servicios en background
docker compose up --build -d

# Ver logs
docker compose logs -f

# Detener servicios
docker compose down

# Resetear base de datos
docker compose down -v
```

## 🧯 Ejecutar DevContainer en VSCode

### ⚠️ instalar devcontainer en VSCODE

1. **En VSCode**  
   Abrir `mechanic-api` o `mechanic-web`.

2. **En otra ventana Ejecutar la base de datos (solo para finance-api)**  

   ```bash
   docker compose up --build serv-mech-db

3. **Abrir el Command Palette**  
- Presiona `Ctrl + Shift + P`.
- Busca y selecciona la opción `Dev Containers: Reopen in Container.`

5. **Ejecutar proyectos**
- En `mechanic-api`

   ```bash
   uvicorn app.main:app  ---reload
   ```
- En `mechanic-web`
   ```bash
   npm start
   ```
- Listo !!!

last modified: 3/04/2026
