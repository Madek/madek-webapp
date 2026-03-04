import { globToNested } from '../../lib/glob-to-nested.js'

// import.meta.glob is resolved at build time by Vite (like bulk-require was by Browserify)
// { eager: true } means synchronous loading (required for SSR compatibility)
const modules = import.meta.glob(['./*.jsx', './**/*.jsx'], { eager: true })

export default globToNested(modules)
