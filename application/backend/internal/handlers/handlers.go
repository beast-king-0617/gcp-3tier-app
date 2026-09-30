package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"

	appdb "github.com/myapp/backend/internal/db"
)

type API struct {
	DB         *sql.DB
	AppVersion string
}

func (a *API) Health(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func (a *API) Ready(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	if err := appdb.Ready(ctx, a.DB); err != nil {
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{
			"status": "not_ready",
			"error":  "database unavailable",
		})
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "ready"})
}

func (a *API) Version(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{
		"version": a.AppVersion,
		"service": "backend",
	})
}

func (a *API) Users(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	users, err := appdb.ListUsers(ctx, a.DB)
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]string{
			"error": "failed to list users",
		})
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"users": users,
		"count": len(users),
	})
}

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}
