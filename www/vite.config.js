import { defineConfig } from 'vite'
import { resolve } from 'node:path'

const root = import.meta.dirname

// Multi-page site: every HTML page must be listed as a build input,
// otherwise Vite only builds index.html. Static runtime assets
// (mascot artwork, legal markdown) live in public/ and are copied to
// dist/ as-is.
export default defineConfig({
  appType: 'mpa',
  build: {
    rollupOptions: {
      input: {
        index: resolve(root, 'index.html'),
        about: resolve(root, 'about.html'),
        contact: resolve(root, 'contact.html'),
        legal: resolve(root, 'legal.html'),
      },
    },
  },
})
