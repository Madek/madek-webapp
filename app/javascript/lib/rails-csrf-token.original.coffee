module.exports = getRailsCSRFToken= ()->
  document?.querySelector?('meta[name="csrf-token"]')?.getAttribute?('content')
