/**
 * Split and interpolate string with expressions of the form '%{key}'.
 * E.g. "hello %{x}!", {x: 'world'} -> ['hello ', 'world', '!']
 * @param {string} str
 * @param {object} subsistutions
 * @returns array
 */
export default function interpolateSplit(str, subsistutions = {}) {
  const parts = str.split(/(%{[^}]+})/).map(part => {
    const match = part.match(/%{([^}]+)}/)
    return match && match[1] ? match[1] : part
  })
  return parts.map(x => subsistutions[x] || x)
}
