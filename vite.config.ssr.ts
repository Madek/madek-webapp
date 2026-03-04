import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  publicDir: false, // Disable public folder copying for SSR bundle
  resolve: {
    alias: {
      '~': path.resolve(__dirname, 'app/javascript')
    }
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
        entryFileNames: 'bundle-react-server-side.js',
        // Inline everything (ExecJS can't import/require external modules)
        inlineDynamicImports: true
      }
    },
    // Don't externalize anything - ExecJS needs everything bundled
    commonjsOptions: {
      include: [/node_modules/],
      transformMixedEsModules: true
    },
    outDir: path.resolve(__dirname, 'public/assets/bundles'),
    emptyOutDir: false, // Don't delete other files in the bundles directory
    sourcemap: false // ExecJS doesn't support source maps
  }
})
