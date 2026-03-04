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
        // Output different filenames for dev vs production
        entryFileNames:
          process.env.NODE_ENV === 'production'
            ? 'bundle-react-server-side.js'
            : 'dev-bundle-react-server-side.js',
        // Inline everything (ExecJS can't import/require external modules)
        inlineDynamicImports: true,
        // Provide empty objects for Node.js built-in modules
        // These will be passed as IIFE parameters to satisfy the function signature
        globals: {
          stream: '{}',
          url: '{}',
          util: '{}',
          net: '{}',
          crypto: '{}',
          buffer: '{}',
          http: '{}',
          https: '{}',
          zlib: '{}',
          querystring: '{}',
          assert: '{}',
          path: '{}',
          tls: '{}',
          fs: '{}',
          events: '{}'
        }
      },
      // CRITICAL: Node.js built-in modules must be external (can't bundle for browser)
      // They will be provided as empty objects via globals in IIFE invocation
      external: [
        'stream',
        'url',
        'util',
        'net',
        'crypto',
        'buffer',
        'http',
        'https',
        'zlib',
        'querystring',
        'assert',
        'path',
        'tls',
        'fs',
        'events'
      ]
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
