import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'
import { nodePolyfills } from 'vite-plugin-node-polyfills'

export default defineConfig({
  plugins: [
    react(),
    nodePolyfills({
      // Polyfill all Node.js built-ins (Option B - comprehensive approach)
      // This prevents issues with any dependency that might use Node.js APIs
      globals: {
        Buffer: true,
        global: true,
        process: true
      }
    })
  ],
  publicDir: false, // Disable public folder copying for SSR bundle
  resolve: {
    alias: {
      '~': path.resolve(__dirname, 'app/javascript')
    },
    // Prefer browser builds over Node.js builds for SSR in ExecJS
    // ExecJS doesn't have Node.js built-ins, so we need browser-compatible code
    conditions: ['browser', 'module', 'import', 'default']
  },
  build: {
    ssr: true,
    rollupOptions: {
      input: path.resolve(__dirname, 'app/javascript/react-server-side-vite.js'),
      output: {
        // ExecJS needs a self-contained script, NOT ESM modules.
        // IIFE wraps everything in an immediately-invoked function.
        format: 'iife',
        name: 'SSRBundle',
        // Output different filenames for dev vs production
        entryFileNames:
          process.env.NODE_ENV === 'production'
            ? 'bundle-react-server-side.js'
            : 'dev-bundle-react-server-side.js',
        // Inline everything (ExecJS can't import/require external modules)
        inlineDynamicImports: true
      },
      // No external modules - all Node.js built-ins are polyfilled by vite-plugin-node-polyfills
      external: []
    },
    // Don't externalize anything - ExecJS needs everything bundled
    commonjsOptions: {
      include: [/node_modules/],
      transformMixedEsModules: true
    },
    outDir: path.resolve(__dirname, 'public/assets/bundles'),
    emptyOutDir: false, // Don't delete other files in the bundles directory
    sourcemap: false // ExecJS doesn't support source maps
  },
  // Force Vite to bundle all dependencies instead of treating them as external
  ssr: {
    noExternal: true
  }
})
