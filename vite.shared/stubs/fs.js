// Stub for Node.js 'fs' module in browser
export default {}
export const readFileSync = () => {
  throw new Error('fs.readFileSync not available in browser')
}
export const writeFileSync = () => {
  throw new Error('fs.writeFileSync not available in browser')
}
