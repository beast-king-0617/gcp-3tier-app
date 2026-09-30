# Backend API (Go)

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Liveness |
| GET | `/ready` | Readiness (DB ping) |
| GET | `/api/v1/version` | Service version |
| GET | `/api/v1/users` | List users from PostgreSQL |

## Local run

```bash
export DATABASE_URL='postgres://myapp:myapp@localhost:5432/myapp?sslmode=disable'
go mod tidy
go test ./...
go run ./cmd/server
```

## Docker

```bash
docker build -t backend:local .
```
