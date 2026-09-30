import { useCallback, useEffect, useState } from 'react'

const apiBase = (import.meta.env.VITE_API_BASE_URL || '').replace(/\/$/, '')

async function fetchJSON(path) {
  const res = await fetch(`${apiBase}${path}`)
  if (!res.ok) {
    throw new Error(`${path} failed: ${res.status}`)
  }
  return res.json()
}

export default function App() {
  const [version, setVersion] = useState(null)
  const [users, setUsers] = useState([])
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(true)

  const load = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const [v, u] = await Promise.all([
        fetchJSON('/api/v1/version'),
        fetchJSON('/api/v1/users'),
      ])
      setVersion(v)
      setUsers(u.users || [])
    } catch (err) {
      setError(err.message || 'Failed to load API')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    load()
  }, [load])

  return (
    <main className="page">
      <header className="hero">
        <p className="brand">myapp</p>
        <h1>Three-tier demo</h1>
        <p className="lede">
          React frontend calling the Go API backed by Cloud SQL PostgreSQL.
        </p>
      </header>

      <section className="panel">
        <div className="panel-head">
          <h2>API status</h2>
          <button type="button" onClick={load} disabled={loading}>
            Refresh
          </button>
        </div>
        {loading && <p>Loading…</p>}
        {error && <p className="error">{error}</p>}
        {!loading && !error && version && (
          <dl className="meta">
            <div>
              <dt>Service</dt>
              <dd>{version.service}</dd>
            </div>
            <div>
              <dt>Version</dt>
              <dd>{version.version}</dd>
            </div>
            <div>
              <dt>API base</dt>
              <dd>{apiBase || '(same origin / gateway)'}</dd>
            </div>
          </dl>
        )}
      </section>

      <section className="panel">
        <h2>Users</h2>
        {!loading && !error && (
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id}>
                  <td>{user.id}</td>
                  <td>{user.name}</td>
                  <td>{user.email}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </main>
  )
}
