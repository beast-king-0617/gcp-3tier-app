package config

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

type Config struct {
	Addr            string
	Version         string
	DatabaseURL     string
	DBMaxOpenConns  int
	DBMaxIdleConns  int
	DBConnMaxLifetime time.Duration
	ShutdownTimeout time.Duration
}

func Load() (Config, error) {
	cfg := Config{
		Addr:            getenv("ADDR", ":8080"),
		Version:         getenv("APP_VERSION", "0.1.0"),
		DatabaseURL:     os.Getenv("DATABASE_URL"),
		DBMaxOpenConns:  getenvInt("DB_MAX_OPEN_CONNS", 10),
		DBMaxIdleConns:  getenvInt("DB_MAX_IDLE_CONNS", 5),
		DBConnMaxLifetime: getenvDuration("DB_CONN_MAX_LIFETIME", 30*time.Minute),
		ShutdownTimeout: getenvDuration("SHUTDOWN_TIMEOUT", 15*time.Second),
	}

	if cfg.DatabaseURL == "" {
		host := getenv("DB_HOST", "")
		port := getenv("DB_PORT", "5432")
		user := getenv("DB_USER", "myapp")
		pass := os.Getenv("DB_PASSWORD")
		name := getenv("DB_NAME", "myapp")
		sslmode := getenv("DB_SSLMODE", "require")

		if host == "" || pass == "" {
			return cfg, fmt.Errorf("DATABASE_URL or DB_HOST+DB_PASSWORD required")
		}
		cfg.DatabaseURL = fmt.Sprintf(
			"postgres://%s:%s@%s:%s/%s?sslmode=%s",
			user, pass, host, port, name, sslmode,
		)
	}

	return cfg, nil
}

func getenv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func getenvInt(key string, fallback int) int {
	v := os.Getenv(key)
	if v == "" {
		return fallback
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		return fallback
	}
	return n
}

func getenvDuration(key string, fallback time.Duration) time.Duration {
	v := os.Getenv(key)
	if v == "" {
		return fallback
	}
	d, err := time.ParseDuration(v)
	if err != nil {
		return fallback
	}
	return d
}
