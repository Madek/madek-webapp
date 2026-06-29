/**
 * virtual-noop-plugin.mjs
 *
 * Vite plugin that provides a virtual no-op module.
 * Used as a dummy entry point so Rollup has a valid (empty) entry to process
 * while the actual bundling is done by esbuild in custom plugins.
 */

export const virtualNoopPlugin = {
  name: 'virtual-noop',
  resolveId(id) {
    if (id === 'virtual:noop') return id
  },
  load(id) {
    if (id === 'virtual:noop') return 'export default {}'
  }
}
