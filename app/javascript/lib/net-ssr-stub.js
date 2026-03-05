/**
 * Minimal net module stub for SSR (Server-Side Rendering)
 *
 * This stub provides just enough of the Node.js net API to allow
 * libraries like 'forever-agent' (used by 'request', used by 'ampersand-sync')
 * to initialize without errors during SSR in ExecJS environment.
 *
 * Real network operations won't work (they're not needed in SSR),
 * but this prevents module initialization errors.
 */

// Stub for createConnection - returns a mock socket that does nothing
function createConnection() {
  // Return a mock socket object with minimal EventEmitter-like API
  const mockSocket = {
    on: function () {
      return this
    },
    once: function () {
      return this
    },
    emit: function () {
      return this
    },
    removeListener: function () {
      return this
    },
    destroy: function () {
      return this
    },
    end: function () {
      return this
    },
    write: function () {
      return this
    },
    pipe: function () {
      return this
    }
  }
  return mockSocket
}

// Export for ES modules
export { createConnection }
export default { createConnection }
