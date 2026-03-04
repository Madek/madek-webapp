import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [RubyPlugin(), react()],
  resolve: {
    alias: {
      '~': path.resolve(__dirname, 'app/javascript')
    }
  },
  server: {
    fs: {
      allow: [
        // Allow importing translations CSV from config/
        path.resolve(__dirname, 'config/locale'),
        // Allow importing stylesheets from app/assets
        path.resolve(__dirname, 'app/assets'),
        // Allow node_modules
        path.resolve(__dirname, 'node_modules'),
        // Allow the default source code dir
        path.resolve(__dirname, 'app/javascript')
      ]
    }
  },
  // Pre-bundle CJS dependencies so Vite's dev server can handle them
  optimizeDeps: {
    include: [
      'react',
      'react-dom',
      'react-dom/server',
      'jquery',
      'active-lodash',
      'ampersand-app',
      'ampersand-model',
      'ampersand-rest-collection',
      'prop-types',
      'classnames',
      'react-bootstrap',
      'react-day-picker',
      'react-file-drop',
      'react-waypoint',
      'video.js',
      'moment',
      'lodash',
      'xhr',
      'history',
      'linkify-string',
      'linkifyjs',
      'hashblot',
      'babyparse',
      'async',
      'uuid-validate',
      'any_sha1',
      'local-links'
    ]
  },
  css: {
    preprocessorOptions: {
      sass: {
        // Inject image-url() function replacement for Sprockets compatibility
        additionalData: `
@function image-url($path)
  @return url("../images/" + $path)
`,
        loadPaths: [
          path.resolve(__dirname, 'app/assets/stylesheets'),
          path.resolve(__dirname, 'node_modules')
        ]
      },
      scss: {
        // Same for SCSS syntax files
        additionalData: `
@function image-url($path) {
  @return url("../images/" + $path);
}
`,
        loadPaths: [
          path.resolve(__dirname, 'app/assets/stylesheets'),
          path.resolve(__dirname, 'node_modules')
        ]
      }
    }
  },
  build: {
    sourcemap: true
  }
})
