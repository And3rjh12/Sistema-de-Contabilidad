# Sistema de Registro Diario — Guía de Instalación

## Archivos entregados
- `database.sql` — Esquema completo de PostgreSQL
- `main.py` — Backend FastAPI (Python)
- `.env.example` — Variables de entorno (renombrar a .env)
- `index.html` — Frontend completo (React)

---

## PASO 1 — Instalar PostgreSQL
Descarga desde https://www.postgresql.org/download/
- Crea una base de datos: `registro_diario`
- Ejecuta el archivo `database.sql` en pgAdmin o psql:
  ```
  psql -U postgres -d registro_diario -f database.sql
  ```

---

## PASO 2 — Configurar el Backend

1. Instala Python 3.10+ desde https://python.org
2. Instala las dependencias:
   ```bash
   pip install fastapi uvicorn sqlalchemy psycopg2-binary python-jose passlib[bcrypt] python-dotenv
   ```
3. Copia `.env.example` como `.env` y llena tus datos:
   ```
   DATABASE_URL=postgresql://postgres:TU_PASSWORD@localhost:5432/registro_diario
   SECRET_KEY=clave-larga-aleatoria-segura
   ```
4. Ejecuta el backend:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```
5. Verifica en: http://localhost:8000/docs (documentación automática)

---

## PASO 3 — Configurar el Frontend

1. Abre `index.html` en un editor de texto
2. Busca la línea:
   ```js
   const API = "http://localhost:8000";
   ```
3. Si el backend está en otro servidor, cambia esa URL
4. Abre `index.html` en cualquier navegador (Chrome, Firefox)

Para servir en red (para las sucursales), usa:
```bash
# Python simple server
python -m http.server 3000
```
Luego las sucursales acceden a: `http://IP_DEL_SERVIDOR:3000`

---

## Credenciales por defecto
- Email: `admin@empresa.com`
- Password: `Admin1234`
⚠️ Cámbia la contraseña después del primer login

---

## Flujo de uso

### Como Administrador:
1. Login → Dashboard (total del día por sucursal)
2. Crear sucursales → Panel "Sucursales"
3. Crear usuarios → Panel "Usuarios" (asignar sucursal a cada uno)
4. Ver reportes semanales/mensuales → Panel "Reportes"

### Como Usuario de Sucursal:
1. Login → Registro del día
2. Seleccionar servicio → Ingresar valor → Guardar
3. Repetir para cada transacción del día
4. Ver total acumulado en la barra superior
5. Ver historial en "Mi caja"

---

## Producción (cuando tengas servidor)
- Backend: Usa `gunicorn` + `nginx` en lugar de uvicorn directo
- Frontend: Usa React con Vite para compilar como SPA
- Base de datos: PostgreSQL en servidor dedicado
- HTTPS: Usa Let's Encrypt (certbot)
