# Frontend (React + NGINX)

## Behavior

- Builds a static React SPA with Vite
- Served by unprivileged NGINX on port 8080
- Calls backend at `VITE_API_BASE_URL` or same-origin `/api/...` (Gateway path)

## Local development

```bash
npm install
npm run dev
```

With backend on `:8080`, Vite proxies `/api`.

## Docker

```bash
docker build -t frontend:local .
docker run --rm -p 8080:8080 frontend:local
```
