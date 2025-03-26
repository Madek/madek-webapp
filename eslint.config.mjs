import globals from 'globals'
import { defineConfig } from 'eslint/config'
import js from '@eslint/js'
import react from 'eslint-plugin-react'
import eslintPluginPrettierRecommended from 'eslint-plugin-prettier/recommended'

export default defineConfig({
  files: ['**/*.{js,jsx,mjs,cjs}'],
  plugins: {
    js,
    react
  },
  languageOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    parserOptions: {
      ecmaFeatures: {
        impliedStrict: true,
        jsx: true,
        experimentalObjectRestSpread: true
      }
    },
    globals: {
      ...globals.browser,
      ...globals.commonjs,
      $: 'readonly',
      APP_CONFIG: 'readonly',
      __dirname: 'readonly'
    }
  },
  settings: {
    react: {
      version: 'detect'
    }
  },
  rules: {
    'react/prop-types': 'off',
    'react/no-string-refs': 'warn',
    'react/no-find-dom-node': 'warn',
    'react/no-is-mounted': 'warn',
    'no-console': 'warn',
    ...js.configs.recommended.rules
  },
  ...eslintPluginPrettierRecommended
})
