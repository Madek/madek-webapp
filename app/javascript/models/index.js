/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import f from 'active-lodash'

const modules = import.meta.glob('./*.js', { eager: true })

const Models = {}
for (const [path, mod] of Object.entries(modules)) {
  const filename = path.replace('./', '').replace(/\.js$/, '')
  if (filename === 'index') continue
  // Convert kebab-case filename to PascalCase key (matching original behavior)
  const key = f.capitalize(f.camelCase(filename))
  Models[key] = mod.default !== undefined ? mod.default : mod
}

export default Models
