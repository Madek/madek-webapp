import { defineConfig } from 'eslint/config'
import globals from 'globals'
import js from '@eslint/js'
import pluginReact from 'eslint-plugin-react'
import eslintPluginPrettierRecommended from 'eslint-plugin-prettier/recommended'

export default defineConfig([
  { files: ['**/*.{js,mjs,cjs,jsx}'] },
  {
    files: ['**/*.{js,mjs,cjs,jsx}'],
    languageOptions: {
      parserOptions: {
        ecmaFeatures: {
          jsx: true
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
    rules: {
      'no-console': 'warn'
    }
  },
  { files: ['**/*.{js,mjs,cjs,jsx}'], plugins: { js }, extends: ['js/recommended'] },

  pluginReact.configs.flat.recommended,
  {
    files: ['**/*.{js,jsx,tsx}'],
    settings: {
      react: {
        version: 'detect'
      }
    },
    rules: {
      'react/prop-types': 'off',
      'react/no-string-refs': 'warn',
      'react/no-find-dom-node': 'warn',
      'react/no-is-mounted': 'warn'
    }
  },
  eslintPluginPrettierRecommended
])
